// ignore: file_names

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  late Future<List<Map<String, dynamic>>> reservations;

  // Fonction pour récupérer les réservations depuis l'API
  Future<List<Map<String, dynamic>>> fetchReservations() async {
    final response = await http.get(Uri.parse('http://192.168.1.6:3000/consultereserv'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception('Erreur lors de la récupération des réservations');
    }
  }

  @override
  void initState() {
    super.initState();
    reservations = fetchReservations(); // Charger les réservations au démarrage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Réservations')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: reservations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune réservation à afficher.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final reservation = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(reservation['nom_materiel']),
                  subtitle: Text(
                    "Du ${reservation['date_debut']} au ${reservation['date_fin']}",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
