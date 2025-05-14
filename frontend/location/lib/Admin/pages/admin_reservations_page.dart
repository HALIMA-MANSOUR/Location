// ignore_for_file: library_private_types_in_public_api

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import './../models/reservation.dart';
import './../services/api_service.dart';


void showLongFlutterToast(String message) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 3, 
    backgroundColor: Colors.redAccent,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}


class AdminReservationsPage extends StatefulWidget {
  const AdminReservationsPage({super.key});

  @override
  _AdminReservationsPageState createState() => _AdminReservationsPageState();
}

class _AdminReservationsPageState extends State<AdminReservationsPage> {
  late Future<List<Reservation>> reservations;

  @override
  void initState() {
    super.initState();
    reservations = ApiService.fetchReservations();
  }

void updateStatus(Reservation reservation, String newStatus) async {
  try {
    await ApiService.updateReservationStatus(reservation.id, newStatus);
  showLongFlutterToast('Statut mis à jour en "$newStatus"');

    setState(() {
      reservation.statut = newStatus;
    });
  } catch (e) {
   showLongFlutterToast(e.toString().replaceAll(RegExp(r'^(Exception: )?'), ''));


  }
}


  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmee':
        return Colors.green;
      case 'annulee':
        return Colors.red;
      case 'terminee':
        return Colors.blue;
          case 'payee':
        return const Color.fromARGB(255, 243, 33, 180);
      case 'en_attente':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Liste des Réservations')),
      body: FutureBuilder<List<Reservation>>(
        future: reservations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final r = data[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${r.nomMateriel} - ${r.nomUtilisateur}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('Du ${r.dateDebut} au ${r.dateFin}'),
                      Text('Total: ${r.total} DT'),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Statut:', style: TextStyle(fontWeight: FontWeight.w500)),
    DropdownButton<String>(
  value: r.statut,
  style: TextStyle(color: _getStatusColor(r.statut)),
  dropdownColor: Colors.white,
  items: ['confirmee', 'terminee','payee' ,'annulee', 'en_attente']
      .map((status) {
    return DropdownMenuItem<String>(
      value: status,
      child: Text(
        status,
        style: TextStyle(color: _getStatusColor(status)),
      ),
    );
  }).toList(),
  onChanged: (newStatus) {
    if (newStatus != null && newStatus != r.statut) {
      updateStatus(r, newStatus);
    }
  },
)
 ],
                      ),
                    ],
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
