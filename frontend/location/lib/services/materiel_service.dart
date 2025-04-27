import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/materiel.dart';

class MaterielService {
  final String apiUrl = "http://192.168.1.6:3000/materiels"; 
  final String reservationUrl = "http://192.168.1.6:3000/locations";

  Future<List<Materiel>> getMateriels() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((m) => Materiel.fromJson(m)).toList();
    } else {
      throw Exception('Erreur de chargement des matériels');
    }
  }

  // Fonction pour créer une réservation
  Future<void> createReservation(int materielId, String dateDebut, String dateFin) async {
    final response = await http.post(
      Uri.parse(reservationUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'user_id': 1, // L'ID utilisateur par défaut, tu peux changer selon les besoins
        'materiel_id': materielId,
        'date_debut': dateDebut,
        'date_fin': dateFin,
      }),
    );

    if (response.statusCode == 201) {
     
    } else {
      throw Exception('Erreur lors de la réservation');
    }
  }
}
