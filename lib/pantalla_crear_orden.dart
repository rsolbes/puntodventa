import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:puntodventa/dialog_seleccionar_producto.dart';

class CrearOrdenScreen extends StatefulWidget {
  @override
  _CrearOrdenScreenState createState() => _CrearOrdenScreenState();
}

class _CrearOrdenScreenState extends State<CrearOrdenScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _numeroController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> productosSeleccionados = [];
  double totalOrden = 0;

  Future<void> _crearOrden() async {
    if (_formKey.currentState!.validate() && productosSeleccionados.isNotEmpty) {
      final querySnapshot = await _firestore
          .collection('ordenes')
          .where('numero', isEqualTo: int.tryParse(_numeroController.text))
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El número de orden ya existe.')),
        );
        return;
      }

      for (var producto in productosSeleccionados) {
        if (producto['cantidad'] <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se permiten productos con cantidad 0 o negativa.')),
          );
          return;
        }
      }

      await _firestore.collection('ordenes').add({
        'numero': int.tryParse(_numeroController.text),
        'total': totalOrden,
        'productos': productosSeleccionados,
        'fecha': Timestamp.now(),
      });
      Navigator.pop(context);
    }
  }

  Future<void> _agregarProducto() async {
    var resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => DialogSeleccionarProducto(),
    );

    if (resultado != null) {
      if (resultado['cantidad'] > 0) {
        setState(() {
          productosSeleccionados.add(resultado);
          totalOrden += resultado['precio'] * resultado['cantidad'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La cantidad debe ser mayor que 0.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Orden')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _numeroController,
                decoration: const InputDecoration(labelText: 'Número de Orden'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Introduce el número de la orden';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _agregarProducto,
                child: const Text('Agregar Producto'),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: productosSeleccionados.length,
                  itemBuilder: (context, index) {
                    var producto = productosSeleccionados[index];
                    return ListTile(
                      title: Text('${producto['nombre']} (x${producto['cantidad']})'),
                      subtitle: Text('Subtotal: \$${producto['precio'] * producto['cantidad']}'),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text('Total: \$${totalOrden.toStringAsFixed(2)}'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _crearOrden,
                child: const Text('Crear Orden'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
