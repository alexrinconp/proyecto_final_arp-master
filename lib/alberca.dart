import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class alberca extends StatefulWidget {
  _albercaState createState() => _albercaState();
}

class _albercaState extends State<alberca> {
  final TextEditingController _areactr = TextEditingController(text: 'Alberca');
  final TextEditingController _fechactr = TextEditingController(
      text: DateTime(
              DateTime.now().day, DateTime.now().month, DateTime.now().year)
          .toString());
  final TextEditingController _horactr = TextEditingController();
  final TextEditingController _residentectr = TextEditingController();
  CollectionReference _reserva =
      FirebaseFirestore.instance.collection('reserva');
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _areactr.text = documentSnapshot['area'];
      _fechactr.text = documentSnapshot['fecha'];
      _horactr.text = documentSnapshot['hora'];
      _residentectr.text = documentSnapshot['residente'];
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
                  controller: _areactr,
                  decoration: const InputDecoration(labelText: 'Area'),
                ),
                TextField(
                  controller: _fechactr,
                  decoration: const InputDecoration(
                    labelText: 'Fecha',
                  ),
                ),
                TextField(
                  controller: _horactr,
                  decoration: const InputDecoration(
                    labelText: 'Hora',
                  ),
                ),
                TextField(
                  controller: _residentectr,
                  decoration: const InputDecoration(
                    labelText: 'Residente',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.redAccent),
                  child: Text(action == 'Create' ? 'Insertar' : 'Actualizar'),
                  onPressed: () async {
                    final String? area = _areactr.text;
                    final String? fecha = _fechactr.text;
                    final String? hora = _horactr.text;
                    final String? residente = _residentectr.text;
                    if (area != null &&
                        fecha != null &&
                        hora != null &&
                        residente != null) {
                      if (action == 'update') {
                        // Update the product
                        await _reserva.doc(documentSnapshot!.id).update({
                          "area": area,
                          "fecha": fecha,
                          "hora": hora,
                          "residente": residente
                        });
                      } // Clear the text fields
                      _areactr.text = '';
                      _fechactr.text = '';
                      _horactr.text = '';
                      _residentectr.text = '';
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
    await _reserva.doc(productId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Borraste una reserva exitosamente')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservas Alberca'),
        backgroundColor: Colors.blueGrey,
      ),
      backgroundColor: Colors.blueGrey[100],
      // Using StreamBuilder to display all productos from Firestore in real-time
      body: StreamBuilder(
        stream: _reserva
            .where("area", isEqualTo: 'Alberca')
            .where("fecha",
                isEqualTo: DateTime.now().day.toString() +
                    '/' +
                    DateTime.now().month.toString() +
                    '/' +
                    DateTime.now().year.toString())
            .snapshots(),
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
                        Text(documentSnapshot['area'],
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(documentSnapshot['fecha']),
                        Text(documentSnapshot['hora']),
                        Text(documentSnapshot['residente'],
                            style: TextStyle(fontWeight: FontWeight.bold)),
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
    );
  }
}
