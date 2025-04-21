import 'package:flutter/material.dart';
import '../models/materiel.dart';
import '../services/materiel_service.dart';

class MaterielListPage extends StatefulWidget {
  @override
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

    // Affichage du dialogue de réservation avec sélecteurs de date
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
        SnackBar(content: Text('Veuillez d’abord choisir la date de début')),
      );
      return;
    }

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: dateDebut!.add(Duration(days: 1)),
      firstDate: dateDebut!.add(Duration(days: 1)),
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
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                if (dateDebut != null && dateFin != null) {
                  // Appeler l'API pour réserver
                  MaterielService().createReservation(materiel.id, dateDebut!.toIso8601String(), dateFin!.toIso8601String())
                      .then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Réservation de ${materiel.nom} réussie!')),
                        );
                        Navigator.of(context).pop(); // Fermer le dialogue
                      }).catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur lors de la réservation')),
                        );
                      });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Veuillez sélectionner des dates valides')),
                  );
                }
              },
              child: Text('Réserver'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Liste des matériels')),
      body: FutureBuilder<List<Materiel>>(
        future: materiels,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final m = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    leading: m.imageUrl.isNotEmpty
                        ? Image.network(
                            m.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.broken_image, size: 40);
                            },
                          )
                        : Icon(Icons.image_not_supported, size: 40),
                    title: Text(m.nom),
                    subtitle: Text(
                      "${m.prixJournalier.toStringAsFixed(2)} DT/jour\n${m.description}",
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: Icon(Icons.book_online),
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
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
