import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class residente extends StatefulWidget {
  _residenteState createState() => _residenteState();
}

class _residenteState extends State<residente> {
  final TextEditingController _depactr = TextEditingController();
  final TextEditingController _mantenimientoctr = TextEditingController();
  final TextEditingController _nombrectr = TextEditingController();
  CollectionReference _residentes =
      FirebaseFirestore.instance.collection('residentes');
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _depactr.text = documentSnapshot['depa'];
      _nombrectr.text = documentSnapshot['nombre'];
      _mantenimientoctr.text = documentSnapshot['mantenimiento'];
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _depactr,
                  decoration: const InputDecoration(labelText: 'Depa'),
                ),
                TextField(
                  controller: _mantenimientoctr,
                  decoration: const InputDecoration(
                    labelText: 'mantenimiento',
                  ),
                ),
                TextField(
                  controller: _nombrectr,
                  decoration: const InputDecoration(
                    labelText: 'nombre',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.redAccent),
                  child: Text(action == 'Create' ? 'Insertar' : 'Actualizar'),
                  onPressed: () async {
                    final String? depa = _depactr.text;
                    final String? mantenimiento = _mantenimientoctr.text;
                    final String? nombre = _nombrectr.text;
                    if (depa != null &&
                        mantenimiento != null &&
                        nombre != null) {
                      if (action == 'create') {
                        // Persist a new product to Firestore
                        await _residentes.add({
                          "depa": depa,
                          "mantenimiento": mantenimiento,
                          "nombre": nombre
                        });
                      }
                      if (action == 'update') {
                        // Update the product
                        await _residentes.doc(documentSnapshot!.id).update({
                          "depa": depa,
                          "mantenimiento": mantenimiento,
                          "nombre": nombre
                        });
                      } // Clear the text fields
                      _depactr.text = '';
                      _mantenimientoctr.text = '';
                      _nombrectr.text = '';
                      // Hide the bottom sheet
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          );
        });
  }

  Future<void> _deleteProduct(String productId) async {
    await _residentes.doc(productId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Borraste un residente exitosamente')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Residente'),
        backgroundColor: Colors.blueGrey,
      ),
      backgroundColor: Colors.blueGrey[100],
      // Using StreamBuilder to display all productos from Firestore in real-time
      body: StreamBuilder(
        stream: _residentes.orderBy("depa").snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Column(
                      children: [
                        Text(documentSnapshot['depa'],
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(documentSnapshot['nombre']),
                        Text(documentSnapshot['mantenimiento']),
                      ],
                    ),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          // Press this button to edit a single product
                          IconButton(
                              icon: Icon(Icons.edit),
                              color: Colors.redAccent,
                              onPressed: () =>
                                  _createOrUpdate(documentSnapshot)),
                          // This icon button is used to delete a single product
                          IconButton(
                              icon: Icon(Icons.delete),
                              color: Colors.redAccent,
                              onPressed: () =>
                                  _deleteProduct(documentSnapshot.id)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      // Add new product
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdate(),
        child: Icon(Icons.add),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}
