import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'venta_detalles_screen.dart';

class SalesReportScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SalesReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reporte de Ventas')),
      body: StreamBuilder(
        stream: _firestore.collection('ordenes').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          var ordenes = snapshot.data!.docs;
          double totalVentas = 0;
          for (var orden in ordenes) {
            totalVentas += orden['total'];
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Total de ventas: \$${totalVentas.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: ordenes.length,
                  itemBuilder: (context, index) {
                    var orden = ordenes[index];
                    return ListTile(
                      title: Text('Orden ${orden['numero']}'),
                      subtitle: Text('Total: \$${orden['total']}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VentaDetallesScreen(orden: orden.data() as Map<String, dynamic>),
                          ),
                        );
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
