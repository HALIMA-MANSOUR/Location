// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:location/Admin/pages/dashboard_admin.dart';
import 'package:location/Admin/pages/login_page.dart';
import 'package:location/pages/Profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/materiel.dart';
import '../services/materiel_service.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class MaterielListPage extends StatefulWidget {
  const MaterielListPage({super.key});

  @override
  MaterielListPageState createState() => MaterielListPageState();
}

class MaterielListPageState extends State<MaterielListPage> {
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

  Future<void> _showReservationDialog(Materiel materiel) async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez vous connecter pour réserver un matériel.')),
      );
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
      return;
    }

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
                          .createReservation(
                            materiel.id,
                            dateDebut!.toIso8601String(),
                            dateFin!.toIso8601String(),
                            materiel.prixJournalier,
                            total!,
                          )
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Matériels disponibles'),
        centerTitle: true,
       
        elevation: 2,
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Profil / Connexion',
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

              if (isLoggedIn) {
                final role = prefs.getString('role') ?? 'client';

                if (role == 'admin') {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardAdmin()));
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilPage()));
                }
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
              }
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
  padding: const EdgeInsets.all(12),
  itemCount: snapshot.data!.length,
  itemBuilder: (context, index) {
    final m = snapshot.data![index];
    return Card(
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => _showReservationDialog(m),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: m.imageUrl.isNotEmpty
                    ? Image.network(
                        m.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      )
                    : const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.nom,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      m.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${m.prixJournalier.toStringAsFixed(2)} DT/jour",
                            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_month, color: Colors.indigo),
                tooltip: 'Réserver',
                onPressed: () => _showReservationDialog(m),
              ),
            ],
          ),
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
