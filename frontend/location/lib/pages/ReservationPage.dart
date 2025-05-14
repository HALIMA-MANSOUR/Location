// ignore: duplicate_ignore
// ignore: file_names
// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  late Future<List<Map<String, dynamic>>> reservations;

  Future<List<Map<String, dynamic>>> fetchReservations() async {
    final response = await http.get(Uri.parse('http://localhost:3000/consultereserv'));

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
    reservations = fetchReservations();
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> reservation) {
    TextEditingController dateDebutController = TextEditingController(text: reservation['date_debut'].substring(0, 10));
    TextEditingController dateFinController = TextEditingController(text: reservation['date_fin'].substring(0, 10));
    double prixParJour = double.tryParse(reservation['prix_par_jour']?.toString() ?? '0') ?? 0;
    int nombreJours = _calculerNombreJours(dateDebutController.text, dateFinController.text);
    double total = prixParJour * nombreJours;

    void recalculerTotal() {
      setState(() {
        nombreJours = _calculerNombreJours(dateDebutController.text, dateFinController.text);
        total = prixParJour * nombreJours;
      });
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( // Important pour rafraîchir l'intérieur du dialogue
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Modifier Réservation'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: dateDebutController,
                    decoration: const InputDecoration(labelText: 'Date début (yyyy-MM-dd)'),
                    onChanged: (value) {
                      setState(() {
                        recalculerTotal();
                      });
                    },
                  ),
                  TextField(
                    controller: dateFinController,
                    decoration: const InputDecoration(labelText: 'Date fin (yyyy-MM-dd)'),
                    onChanged: (value) {
                      setState(() {
                        recalculerTotal();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('Nombre de jours : $nombreJours'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _updateReservation(
                      reservation['id'],
                      reservation['materiel_id'],
                      dateDebutController.text,
                      dateFinController.text,
                      prixParJour,
                      total,
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  int _calculerNombreJours(String dateDebut, String dateFin) {
    try {
      DateTime debut = DateTime.parse(dateDebut);
      DateTime fin = DateTime.parse(dateFin);
      int diff = fin.difference(debut).inDays + 1; // +1 pour inclure le jour de début
      return diff > 0 ? diff : 0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> _updateReservation(int id, int materielId, String dateDebut, String dateFin, double prix, double total) async {
    final url = Uri.parse('http://localhost:3000/modifreserv/$id');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'materiel_id': materielId,
        'date_debut': dateDebut,
        'date_fin': dateFin,
        'prix': prix,
        'total': total, // envoyer le nouveau total
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Réservation mise à jour avec succès')),
      );
      setState(() {
        reservations = fetchReservations();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${jsonDecode(response.body)['message']}')),
      );
    }
  }

  Future<String> _fetchClientToken() async {
    final response = await http.get(Uri.parse('http://localhost:3000/token'));
    
    if (response.statusCode == 200) {
      return response.body;  // Le token client généré par votre backend
    } else {
      throw Exception('Erreur de récupération du token');
    }
  }

  void _showPaymentDialog(BuildContext context, Map<String, dynamic> reservation) {
    // Récupérer le token de client depuis le backend
    _fetchClientToken().then((token) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Paiement'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Montant à payer: ${reservation['total']}'),
            ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Traitement du paiement après avoir obtenu le nonce
                  _processPayment(reservation, token);
                  Navigator.of(context).pop();
                },
                child: const Text('Payer'),
              ),
            ],
          );
        },
      );
    });
  }

  void _processPayment(Map<String, dynamic> reservation, String token) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/recupererCarteParId?email=alice@example.com&cardId=1'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'montant': reservation['total'].toString(),
           'locationId': reservation['id'], 
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
         setState(() {
          reservations = fetchReservations(); // force la mise à jour de la liste
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Paiement effectué avec succès ! Transaction ID : ${responseData['transactionId']}')),
        );
      } else {
        final errorMessage = jsonDecode(response.body)['message'] ?? 'Erreur inconnue';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du paiement : $errorMessage')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion : $e')),
      );
    }
  }
void _showDeleteConfirmationDialog(BuildContext context, int id) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Confirmation de suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette réservation ?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Ferme le dialogue sans faire de suppression
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteReservation(id);  // Appel de la méthode de suppression
              Navigator.of(context).pop(); // Ferme le dialogue après la suppression
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

  Future<void> _deleteReservation(int id) async {
    final response = await http.delete(Uri.parse('http://localhost:3000/deletelocation/$id'));

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Réservation supprimée avec succès')),
      );
      setState(() {
        reservations = fetchReservations();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression : ${jsonDecode(response.body)['message']}')),
      );
    }
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
                  title: Text(reservation['nom_materiel'] ?? ''),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Du ${reservation['date_debut'].substring(0, 10)} au ${reservation['date_fin'].substring(0, 10)}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Affichage du statut
                      Text(
                        'Statut: ${reservation['statut'] ?? 'Inconnu'}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ],
                  ),
                trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    if (reservation['statut'] == 'en_attente') ...[
      // Affichage du bouton "Modifier"
      IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () {
          _showEditDialog(context, reservation);
        },
      ),
      // Affichage du bouton "Supprimer"
      IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
         _showDeleteConfirmationDialog(context, reservation['id']);
        },
      ),
    ],
    if (reservation['statut'] == 'confirmee') ...[
      // Affichage du bouton "Payer"
      IconButton(
        icon: const Icon(Icons.payment),
        onPressed: () {
          _showPaymentDialog(context, reservation);
        },
      ),
    ],
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
