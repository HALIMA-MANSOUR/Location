import 'package:flutter/material.dart';
import 'pages/materiel_list_page.dart';
import './Admin/pages/admin_reservations_page.dart';


void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Location de Matériels',
      theme: ThemeData(primarySwatch: Colors.green),
      home:  const MaterielListPage(),
    ),
  );
}
