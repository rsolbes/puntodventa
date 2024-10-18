import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryReportScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  InventoryReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reporte de Inventario')),
      body: StreamBuilder(
        stream: _firestore.collection('productos').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          var productos = snapshot.data!.docs;
          double valorTotalInventario = 0;

          for (var producto in productos) {
            valorTotalInventario += producto['cantidad'] * producto['precio'];
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Valor total del inventario: \$${valorTotalInventario.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    var producto = productos[index];
                    double valorProducto = producto['cantidad'] * producto['precio'];
                    return ListTile(
                      title: Text(producto['nombre']),
                      subtitle: Text('Cantidad: ${producto['cantidad']} | Valor: \$${valorProducto.toStringAsFixed(2)}'),
                      onTap: () {
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
