import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:puntodventa/pantalla_crear_orden.dart';

class OrderManagementScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  OrderManagementScreen({super.key});

  Future<void> _borrarOrden(String ordenId, List productos) async {
    for (var producto in productos) {
      DocumentSnapshot productoSnapshot = await _firestore.collection('productos').doc(producto['id']).get();
      var cantidadActual = productoSnapshot['cantidad'];
      await _firestore.collection('productos').doc(producto['id']).update({
        'cantidad': cantidadActual + producto['cantidad'],
      });
    }
    await _firestore.collection('ordenes').doc(ordenId).delete();
  }

  Future<void> _crearOrden(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CrearOrdenScreen()),
    );
  }

  Future<void> _editarOrden(BuildContext context, Map<String, dynamic> orden) async {
    final numeroController = TextEditingController(text: orden['numero'].toString());
    final totalController = TextEditingController(text: orden['total'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Orden'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: numeroController,
                decoration: const InputDecoration(labelText: 'Número de Orden'),
              ),
              TextField(
                controller: totalController,
                decoration: const InputDecoration(labelText: 'Total'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Verificar que no haya un número de orden duplicado
                final querySnapshot = await _firestore
                    .collection('ordenes')
                    .where('numero', isEqualTo: int.tryParse(numeroController.text))
                    .get();

                if (querySnapshot.docs.isNotEmpty && querySnapshot.docs.first.id != orden['id']) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('El número de orden ya existe.')),
                  );
                } else {
                  // Verificar que no haya productos con cantidad <= 0
                  bool cantidadInvalida = false;
                  for (var producto in orden['productos']) {
                    if (producto['cantidad'] <= 0) {
                      cantidadInvalida = true;
                      break;
                    }
                  }

                  if (cantidadInvalida) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No se permiten productos con cantidad 0 o negativa.')),
                    );
                  } else {
                    await _firestore.collection('ordenes').doc(orden['id']).update({
                      'numero': int.tryParse(numeroController.text) ?? orden['numero'],
                      'total': double.tryParse(totalController.text) ?? orden['total'],
                    });
                    Navigator.of(context).pop();
                  }
                }
              },
              child: const Text('Guardar Cambios'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _generarTicketPDF(BuildContext context, Map<String, dynamic> orden) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Ticket de Orden #${orden['numero']}', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Text('Productos:', style: pw.TextStyle(fontSize: 18)),
              ...orden['productos'].map<pw.Widget>((producto) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Producto: ${producto['nombre']}'),
                    pw.Text('Cantidad: ${producto['cantidad']}'),
                    pw.Text('Precio: \$${producto['precio']}'),
                    pw.SizedBox(height: 10),
                  ],
                );
              }).toList(),
              pw.Divider(),
              pw.Text('Total: \$${orden['total']}', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    await _guardarPDFConFilePicker(context, pdf);
  }

  Future<void> _guardarPDFConFilePicker(BuildContext context, pw.Document pdf) async {
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Guardar archivo PDF',
      fileName: 'ticket_orden.pdf',
    );

    if (outputFile != null) {
      final file = File(outputFile);

      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF guardado en $outputFile')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guardado cancelado.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Órdenes')),
      body: StreamBuilder(
        stream: _firestore.collection('ordenes').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var ordenes = snapshot.data!.docs;

          if (ordenes.isEmpty) {
            return const Center(child: Text('No hay órdenes disponibles.'));
          }

          return ListView.builder(
            itemCount: ordenes.length,
            itemBuilder: (context, index) {
              var orden = ordenes[index];

              final Map<String, dynamic>? ordenData = orden.data() as Map<String, dynamic>?;

              return ListTile(
                title: Text('Orden ${ordenData?['numero'] ?? 'desconocida'}'),
                subtitle: Text('Total: \$${ordenData?['total'] ?? 0}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.picture_as_pdf),
                      onPressed: () {
                        if (ordenData != null) {
                          _generarTicketPDF(context, ordenData);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Error al generar el ticket.')),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        if (ordenData != null) {
                          _editarOrden(context, ordenData);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        bool confirmar = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmar eliminación'),
                            content: const Text('¿Estás seguro de que deseas borrar esta orden?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Borrar'),
                              ),
                            ],
                          ),
                        );

                        if (confirmar == true) {
                          await _borrarOrden(orden.id, List.from(orden['productos']));
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _crearOrden(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
