import 'dart:convert';
import 'dart:io';
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



  static Future<void> updateMateriel(
    int id,
    Map<String, dynamic> updates,
  ) async {
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
static Future<bool> addMaterielWithImage({
  required String nom,
  required double prixJournalier,
  required int categorie_id,
  File? imageFile,
}) async {
  final uri = Uri.parse('$baseUrl/ajoutmateriels');
  final request = http.MultipartRequest('POST', uri);

  request.fields['nom'] = nom;
  request.fields['prix_journalier'] = prixJournalier.toString();
  request.fields['categorie_id'] = categorie_id.toString();
  request.fields['disponible'] = 'true';

  if (imageFile != null) {
    request.files.add(await http.MultipartFile.fromPath('image_url', imageFile.path));
  }

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 201) {
    return true;
  } else {
    print('Erreur ajout: ${response.statusCode} ${response.body}');
    return false;
  }
}
}
