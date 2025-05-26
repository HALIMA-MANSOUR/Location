import 'dart:convert';
import 'package:http/http.dart' as http;
import './../models/Materiel.dart';

class MaterielService {
  static const String baseUrl = 'http://localhost:3000';

  static Future<List<Materiel>> getAllMateriels() async {
    final response = await http.get(Uri.parse('$baseUrl/materiels'));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => Materiel.fromJson(e)).toList();
    } else {
      throw Exception('Erreur chargement matériels');
    }
  }

  static Future<void> addMateriel(Map<String, dynamic> materiel) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ajoutmateriels'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(materiel),
    );
    if (response.statusCode != 201) {
      throw Exception('Erreur ajout matériel');
    }
  }

  static Future<void> updateMateriel(int id, Map<String, dynamic> updates) async {
    final response = await http.put(
      Uri.parse('$baseUrl/modifmateriels/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updates),
    );
    if (response.statusCode != 200) {
      throw Exception('Erreur modification matériel');
    }
  }

  static Future<void> deleteMateriel(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/dletemateriel/$id'));
    if (response.statusCode != 200) {
      throw Exception('Erreur suppression matériel');
    }
  }
}
