import 'package:flutter/material.dart';

class VentaDetallesScreen extends StatelessWidget {
  final Map<String, dynamic> orden;

  const VentaDetallesScreen({Key? key, required this.orden}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalles de la Orden ${orden['numero']}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Número de Orden: ${orden['numero']}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Total: \$${orden['total']}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            const Text('Productos:', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: orden['productos'].length,
                itemBuilder: (context, index) {
                  var producto = orden['productos'][index];
                  return ListTile(
                    title: Text(producto['nombre']),
                    subtitle: Text('Cantidad: ${producto['cantidad']} - Precio: \$${producto['precio']}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
