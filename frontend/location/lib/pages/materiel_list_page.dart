// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import '../models/materiel.dart';
import '../services/materiel_service.dart';
import 'package:location/pages/ReservationPage.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class MaterielListPage extends StatefulWidget {
  const MaterielListPage({super.key});

  @override
  _MaterielListPageState createState() => _MaterielListPageState();
}

class _MaterielListPageState extends State<MaterielListPage> {
  late Future<List<Materiel>> materiels;
  late Future<List<Category>> categories;
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    categories = CategoryService().getCategories();
    materiels = MaterielService().getMateriels();
  }

  void _filterMaterielsByCategory(int? categoryId) {
    setState(() {
      selectedCategoryId = categoryId;
      materiels = MaterielService().getMateriels(categoryId);
    });
  }

  void _showReservationDialog(Materiel materiel) {
    DateTime? dateDebut;
    DateTime? dateFin;
    double? total;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Réserver ${materiel.nom}', style: const TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(dateDebut == null
                        ? 'Choisir la date de début'
                        : 'Début : ${dateDebut!.toLocal()}'.split(' ')[0]),
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
                          dateFin = null;
                          total = null;
                        });
                      }
                    },
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.date_range_outlined),
                    label: Text(dateFin == null
                        ? 'Choisir la date de fin'
                        : 'Fin : ${dateFin!.toLocal()}'.split(' ')[0]),
                    onPressed: () async {
                      if (dateDebut == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Veuillez choisir la date de début d’abord')),
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
                          final nbJours = dateFin!.difference(dateDebut!).inDays;
                          total = nbJours * materiel.prixJournalier;
                        });
                      }
                    },
                  ),
                  if (total != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        'Total : ${total!.toStringAsFixed(2)} DT',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Annuler'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Réserver'),
                  onPressed: () {
                    if (dateDebut != null && dateFin != null && total != null) {
                      MaterielService()
                          .createReservation(materiel.id, dateDebut!.toIso8601String(), dateFin!.toIso8601String(), materiel.prixJournalier, total!)
                          .then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Réservation de ${materiel.nom} réussie!')),
                        );
                        Navigator.of(context).pop();
                      }).catchError((_) {
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
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Matériels disponibles'),
        centerTitle: false,
        elevation: 2,
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.book_online),
            tooltip: 'Mes réservations',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReservationPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FutureBuilder<List<Category>>(
              future: categories,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: DropdownButton<int>(
  isExpanded: true,
  underline: const SizedBox(),
  value: selectedCategoryId,
  hint: const Text("Filtrer par catégorie"),
  onChanged: (newValue) => _filterMaterielsByCategory(newValue),
  items: [
    const DropdownMenuItem<int>(
      value: null,
      child: Text("Toutes les catégories"),
    ),
    ...snapshot.data!.map((c) {
      return DropdownMenuItem<int>(
        value: c.id,
        child: Text(c.nom),
      );
    }),
  ],
),

                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text("Erreur: ${snapshot.error}");
                }
                return const CircularProgressIndicator();
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Materiel>>(
              future: materiels,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final m = snapshot.data![index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: m.imageUrl.isNotEmpty
                                ? Image.network(
                                    m.imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.broken_image, size: 40),
                                  )
                                : const Icon(Icons.image_not_supported, size: 40),
                          ),
                          title: Text(
                            m.nom,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${m.prixJournalier.toStringAsFixed(2)} DT/jour\n${m.description}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.calendar_month, color: Colors.indigo),
                            onPressed: () => _showReservationDialog(m),
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text("Erreur: ${snapshot.error}"));
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}
