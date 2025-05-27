import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import './../models/Materiel.dart';
import './../services/materielService.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class MaterielPage extends StatefulWidget {
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
    final categorieIdController = TextEditingController(text: materiel?.categorieId.toString() ?? '');

    File? selectedImage;
    XFile? webImage;
    final picker = ImagePicker();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(materiel == null ? 'Ajouter un matériel' : 'Modifier le matériel'),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomController,
                  decoration: const InputDecoration(labelText: 'Nom'),
                ),
                TextField(
                  controller: prixController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Prix journalier'),
                ),
                TextField(
                  controller: categorieIdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Catégorie ID'),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () async {
                    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        if (kIsWeb) {
                          webImage = pickedFile;
                        } else {
                          selectedImage = File(pickedFile.path);
                        }
                      });
                    }
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('Sélectionner une image'),
                ),
                if (selectedImage != null && !kIsWeb)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Image.file(
                      selectedImage!,
                      height: 100,
                    ),
                  ),
                if (webImage != null && kIsWeb)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Image.network(
                      webImage!.path,
                      height: 100,
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
        onPressed: () async {
  final nom = nomController.text;
  final prix = double.tryParse(prixController.text) ?? 0.0;
  final categorieId = int.tryParse(categorieIdController.text) ?? 0;

  if (materiel == null) {
    // Ajout
    final success = await MaterielService.addMaterielWithImage(
      nom: nom,
      prixJournalier: prix,
      categorie_id: categorieId,
      imageFile: kIsWeb ? null : selectedImage,
      webImage: kIsWeb ? webImage : null,
    );

    if (success) Navigator.pop(context);
  } else {
    // Modification
    final success = await MaterielService.updateMaterielWithImage(
      id: materiel.id,
      nom: nom,
      prixJournalier: prix,
      categorie_id: categorieId,
      imageFile: kIsWeb ? null : selectedImage,
      webImage: kIsWeb ? webImage : null,
    );

    if (success) Navigator.pop(context);
  }

  _refresh();
},
child: const Text('Enregistrer'),
          ),
        ],
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Matériels disponibles'),
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
            return const Center(child: Text('Erreur lors du chargement.'));
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  leading: m.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            m.imageUrl!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.build,
                            color: Colors.teal,
                            size: 30,
                          ),
                        ),
                  title: Text(
                    m.nom,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text('${m.prixJournalier.toStringAsFixed(2)} DT/jour'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => _showMaterielForm(materiel: m),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(m.id),
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
