import 'package:flutter/material.dart';
import 'package:puntodventa/pantalla_reporte_inventario.dart';
import 'package:puntodventa/pantalla_reporte_ventas.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reportes')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SalesReportScreen()),
                );
              },
              child: const Text('Reporte de Ventas'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InventoryReportScreen()),
                );
              },
              child: const Text('Reporte de Inventario'),
            ),
          ],
        ),
      ),
    );
  }
}
