// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import './../models/Materiel.dart';
import './../services/materielService.dart';

class MaterielPage extends StatefulWidget {
  // ignore: use_super_parameters
  const MaterielPage({Key? key}) : super(key: key);

  @override
  _MaterielPageState createState() => _MaterielPageState();
}

class _MaterielPageState extends State<MaterielPage> {
  late Future<List<Materiel>> _futureMateriels;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _futureMateriels = MaterielService.getAllMateriels();
    });
  }

  void _showMaterielForm({Materiel? materiel}) {
    final nomController = TextEditingController(text: materiel?.nom ?? '');
    final prixController = TextEditingController(text: materiel?.prixJournalier.toString() ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Wrap(
          children: [
            Center(
              child: Text(
                materiel == null ? 'Ajouter un matériel' : 'Modifier le matériel',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: nomController,
              decoration: const InputDecoration(labelText: 'Nom', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: prixController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Prix journalier', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(materiel == null ? Icons.add : Icons.edit),
              onPressed: () async {
                if (nomController.text.trim().isEmpty || prixController.text.trim().isEmpty) return;

                final prix = double.tryParse(prixController.text) ?? 0;

                if (materiel == null) {
                  await MaterielService.addMateriel({'nom': nomController.text, 'prix_journalier': prix});
                } else {
                  await MaterielService.updateMateriel(materiel.id, {'nom': nomController.text, 'prix_journalier': prix});
                }

                Navigator.pop(context);
                _refresh();
              },
              label: Text(materiel == null ? 'Ajouter' : 'Modifier'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer le matériel'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce matériel ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await MaterielService.deleteMateriel(id);
              _refresh();
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(  backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Matériels disponibles'),
        centerTitle: false,
         elevation: 2,
        backgroundColor: Colors.indigo,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMaterielForm(),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Materiel>>(
        future: _futureMateriels,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erreur lors du chargement'));
          }

          final materiels = snapshot.data!;
          if (materiels.isEmpty) {
            return const Center(child: Text('Aucun matériel disponible.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: materiels.length,
            itemBuilder: (context, index) {
              final m = materiels[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  leading: m.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(m.imageUrl!, width: 60, height: 60, fit: BoxFit.cover),
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.build, color: Colors.teal, size: 30),
                        ),
                  title: Text(
                    m.nom,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text('${m.prixJournalier.toStringAsFixed(2)} DT/jour'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.orange), onPressed: () => _showMaterielForm(materiel: m)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmDelete(m.id)),
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
