import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // 🔥 Import nécessaire
import '../models/materiel.dart';

class MaterielService {
  final String apiUrl = "http://localhost:3000/materiels"; 
  final String reservationUrl = "http://localhost:3000/locations";

  Future<List<Materiel>> getMateriels([int? categoryId]) async {
    String url = apiUrl;
    if (categoryId != null) {
      url += '?category_id=$categoryId'; // Adapté selon API
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((m) => Materiel.fromJson(m)).toList();
    } else {
      throw Exception('Erreur de chargement des matériels');
    }
  }

  // 🔄 Fonction corrigée pour récupérer user_id depuis SharedPreferences
  Future<void> createReservation(int materielId, String dateDebut, String dateFin, double prix, double total) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId'); // 🔥 Lecture dynamique

    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }

    final response = await http.post(
      Uri.parse(reservationUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'user_id': userId,
        'materiel_id': materielId,
        'date_debut': dateDebut,
        'date_fin': dateFin,
        'prix': prix,
        'total': total,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Erreur lors de la réservation');
    }
  }
}
