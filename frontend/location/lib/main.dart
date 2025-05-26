import 'package:flutter/material.dart';
import 'pages/Materiel_list_page.dart';
import './Admin/pages/admin_reservations_page.dart';
import './pages/Inscription.dart';
import 'Admin/pages/MaterielPage.dart';
void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Location de Matériels',
      theme: ThemeData(primarySwatch: Colors.green),
      home: MaterielPage(),
    ),
  );
}
