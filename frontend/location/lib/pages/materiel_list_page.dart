// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../models/materiel.dart';
import '../services/materiel_service.dart';
import 'package:location/pages/ReservationPage.dart';


class MaterielListPage extends StatefulWidget {
  const MaterielListPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MaterielListPageState createState() => _MaterielListPageState();
}

class _MaterielListPageState extends State<MaterielListPage> {
  late Future<List<Materiel>> materiels;

  @override
  void initState() {
    super.initState();
    materiels = MaterielService().getMateriels();
  }

  // Fonction pour afficher un dialogue de réservation
  void _showReservationDialog(Materiel materiel) async {
    DateTime? dateDebut;
    DateTime? dateFin;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Réserver ${materiel.nom}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      dateDebut = selectedDate;
                    });
                  }
                },
                child: Text(
                  dateDebut == null
                      ? 'Choisir la date de début'
                      : 'Date de début : ${dateDebut!.toLocal()}'.split(' ')[0],
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (dateDebut == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Veuillez d’abord choisir la date de début')),
                    );
                    return;
                  }

                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: dateDebut!.add(const Duration(days: 1)),
                    firstDate: dateDebut!.add(const Duration(days: 1)),
                    lastDate: DateTime(2101),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      dateFin = selectedDate;
                    });
                  }
                },
                child: Text(
                  dateFin == null
                      ? 'Choisir la date de fin'
                      : 'Date de fin : ${dateFin!.toLocal()}'.split(' ')[0],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                if (dateDebut != null && dateFin != null) {
                  // Appeler l'API pour réserver
                  MaterielService().createReservation(
                    materiel.id,
                    dateDebut!.toIso8601String(),
                    dateFin!.toIso8601String(),
                  ).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Réservation de ${materiel.nom} réussie!')),
                    );
                    Navigator.of(context).pop(); // Fermer le dialogue
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Erreur lors de la réservation')),
                    );
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez sélectionner des dates valides')),
                  );
                }
              },
              child: const Text('Réserver'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des matériels'),
        actions: [
          IconButton(
            icon: const Icon(Icons.book_online), // Icône pour ouvrir la page des réservations
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReservationPage()), // Navigation vers la page des réservations
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Materiel>>(
        future: materiels,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final m = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: m.imageUrl.isNotEmpty
                        ? Image.network(
                            m.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const  Icon(Icons.broken_image, size: 40);
                            },
                          )
                        : const Icon(Icons.image_not_supported, size: 40),
                    title: Text(m.nom),
                    subtitle: Text(
                      "${m.prixJournalier.toStringAsFixed(2)} DT/jour\n${m.description}",
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon:const Icon(Icons.book_online),
                      onPressed: () {
                        _showReservationDialog(m); // Appel du dialogue de réservation
                      },
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
