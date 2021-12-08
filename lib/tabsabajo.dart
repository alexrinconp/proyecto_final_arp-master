import 'package:flutter/material.dart';
import 'gimnasio.dart';
import 'alberca.dart';
import 'tennis.dart';
import 'contacto.dart';
import 'reservar.dart';
import 'residente.dart';

class tabsabajo extends StatefulWidget {
  @override
  _tabsabajoState createState() => _tabsabajoState();
}

class _tabsabajoState extends State<tabsabajo> {
  int mi_indice = 0;
  final pantallas = [
    gimnasio(),
    alberca(),
    tennis(),
    reservar(),
    contacto(),
    residente()
  ];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(primaryColor: Colors.blueGrey),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: IndexedStack(index: mi_indice, children: pantallas),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.blueGrey,
            selectedItemColor: Colors.white,
            iconSize: 30,
            currentIndex: mi_indice,
            onTap: (index) => setState(() => mi_indice = index),
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.bike_scooter), label: 'Gimnasio'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.bathroom), label: 'Alberca'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.sports_baseball), label: 'Tennis'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.access_alarm), label: 'Reservar'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.contact_page), label: 'Contacto'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.emoji_people), label: 'Residente'),
            ],
          ),
        ));
  }
}
