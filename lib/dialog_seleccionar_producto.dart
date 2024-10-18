import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DialogSeleccionarProducto extends StatefulWidget {
  @override
  _DialogSeleccionarProductoState createState() => _DialogSeleccionarProductoState();
}

class _DialogSeleccionarProductoState extends State<DialogSeleccionarProducto> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int cantidad = 1;
  String? productoSeleccionadoId;
  Map<String, dynamic>? productoSeleccionado;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar Producto'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          StreamBuilder(
            stream: _firestore.collection('productos').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              var productos = snapshot.data!.docs;
              return DropdownButton<String>(
                isExpanded: true,
                value: productoSeleccionadoId,
                hint: const Text('Selecciona un producto'),
                items: productos.map<DropdownMenuItem<String>>((producto) {
                  return DropdownMenuItem<String>(
                    value: producto.id,
                    child: Text(producto['nombre']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    productoSeleccionadoId = value;
                    productoSeleccionado = productos.firstWhere((p) => p.id == value).data();
                  });
                },
              );
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Cantidad'),
            initialValue: '1',
            onChanged: (value) {
              cantidad = int.tryParse(value) ?? 1;
            },
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: productoSeleccionado != null && cantidad > 0
              ? () async {
                  if (productoSeleccionado!['cantidad'] >= cantidad) {
                    await _firestore.collection('productos').doc(productoSeleccionadoId).update({
                      'cantidad': productoSeleccionado!['cantidad'] - cantidad,
                    });

                    Navigator.pop(context, {
                      'id': productoSeleccionadoId,
                      'nombre': productoSeleccionado!['nombre'],
                      'precio': productoSeleccionado!['precio'],
                      'cantidad': cantidad,
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('No hay suficiente inventario disponible.'),
                    ));
                  }
                }
              : null,
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}