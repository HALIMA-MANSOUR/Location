import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/materiel.dart';

class MaterielService {
  final String apiUrl = "http://localhost:3000/materiels"; 
  final String reservationUrl = "http://localhost:3000/locations";

  Future<List<Materiel>> getMateriels() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((m) => Materiel.fromJson(m)).toList();
    } else {
      throw Exception('Erreur de chargement des matériels');
    }
  }

  // Fonction pour créer une réservation avec prix
  Future<void> createReservation(int materielId, String dateDebut, String dateFin, double prix,double total) async {
    final response = await http.post(
      Uri.parse(reservationUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'user_id': 1,            // Toujours user_id=1 pour l'instant
        'materiel_id': materielId,
        'date_debut': dateDebut,
        'date_fin': dateFin,
        'prix': prix,   
        'total':total ,     
      }),
    );

    if (response.statusCode == 201) {
      // succès
    } else {
      throw Exception('Erreur lors de la réservation');
    }
  }
}
