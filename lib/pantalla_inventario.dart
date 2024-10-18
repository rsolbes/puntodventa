import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pantalla_editar_producto.dart';

class InventoryScreen extends StatefulWidget {
  InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? categoriaSeleccionada;

  Future<void> _eliminarProducto(String productoId) async {
    await _firestore.collection('productos').doc(productoId).delete();
  }

  Future<void> _agregarOActualizarProducto(Map<String, dynamic> nuevoProducto) async {
    var productosExistentes = await _firestore
        .collection('productos')
        .where('nombre', isEqualTo: nuevoProducto['nombre'])
        .get();

    if (productosExistentes.docs.isNotEmpty) {
      var productoExistente = productosExistentes.docs.first;
      int cantidadExistente = productoExistente['cantidad'];
      await _firestore.collection('productos').doc(productoExistente.id).update({
        'cantidad': cantidadExistente + nuevoProducto['cantidad'],
      });
    } else {
      await _firestore.collection('productos').add(nuevoProducto);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('productos').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              var categorias = snapshot.data!.docs
                  .map((doc) => doc['categoria'] ?? 'Sin categoría')
                  .toSet()
                  .toList();
              categorias.insert(0, 'Todas');
              
              return DropdownButton<String>(
                value: categoriaSeleccionada,
                hint: const Text('Filtrar por categoría'),
                onChanged: (value) {
                  setState(() {
                    categoriaSeleccionada = value == 'Todas' ? null : value;
                  });
                },
                items: categorias.map<DropdownMenuItem<String>>((categoria) {
                  return DropdownMenuItem<String>(
                    value: categoria,
                    child: Text(categoria),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _firestore.collection('productos').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var productos = snapshot.data!.docs;

          if (categoriaSeleccionada != null) {
            productos = productos.where((producto) => producto['categoria'] == categoriaSeleccionada).toList();
          }

          return ListView.builder(
            itemCount: productos.length,
            itemBuilder: (context, index) {
              var producto = productos[index];
              return ListTile(
                leading: producto['imagen'] != null && producto['imagen'].isNotEmpty
                    ? Image.network(
                        producto['imagen'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image_not_supported, size: 50);
                        },
                      )
                    : const Icon(Icons.image, size: 50),
                title: Text(producto['nombre']),
                subtitle: Text('Cantidad: ${producto['cantidad']} \nCategoría: ${producto['categoria'] ?? 'Sin categoría'}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditProductScreen(product: producto)),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        bool confirmar = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmar eliminación'),
                            content: const Text('¿Estás seguro de que deseas eliminar este producto?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );

                        if (confirmar == true) {
                          await _eliminarProducto(producto.id);
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditProductScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
