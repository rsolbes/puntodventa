import 'package:flutter/material.dart';
import 'package:puntodventa/pantalla_gestion_ordenes.dart';
import 'package:puntodventa/pantalla_inventario.dart';
import 'package:puntodventa/pantalla_reportes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => InventoryScreen()));
              },
              child: const Text('Gestionar Inventario'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => OrderManagementScreen()));
              },
              child: const Text('Gestionar Órdenes'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportScreen()));
              },
              child: const Text('Reportes'),
            ),
          ],
        ),
      ),
    );
  }
}
