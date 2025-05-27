import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';
import './../models/Materiel.dart';

class MaterielService {
  static const String baseUrl = 'http://localhost:3000';
  static const String getUrl = '$baseUrl/materiels';
  static const String addUrl = '$baseUrl/ajoutmateriels'; // ✅ URL d'ajout correcte

  static Future<List<Materiel>> getAllMateriels() async {
    final response = await http.get(Uri.parse(getUrl));
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => Materiel.fromJson(e)).toList();
    } else {
      throw Exception('Erreur chargement matériels');
    }
  }


  static Future<bool> updateMaterielWithImage({
  required int id,
  required String nom,
  required double prixJournalier,
  required int categorie_id,
  String? description,
  bool? disponible,
  File? imageFile,
  XFile? webImage,
}) async {
  try {
    final uri = Uri.parse('$baseUrl/modifmateriels/$id');
    final request = http.MultipartRequest('PUT', uri);

    request.fields['nom'] = nom;
    request.fields['prix_journalier'] = prixJournalier.toString();
    request.fields['categorie_id'] = categorie_id.toString();
    if (description != null) request.fields['description'] = description;
    if (disponible != null) request.fields['disponible'] = disponible.toString();

    if (kIsWeb && webImage != null) {
      final bytes = await webImage.readAsBytes();
      final mimeType = lookupMimeType(webImage.name) ?? 'image/jpeg';
      request.files.add(http.MultipartFile.fromBytes(
        'image_url',
        bytes,
        filename: basename(webImage.name),
        contentType: MediaType.parse(mimeType),
      ));
    } else if (imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image_url',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    final response = await request.send();
    if (response.statusCode == 200) {
      return true;
    } else {
      final res = await response.stream.bytesToString();
      print('Erreur backend: ${response.statusCode} $res');
      return false;
    }
  } catch (e) {
    print('Erreur modification: $e');
    return false;
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
    XFile? webImage,
  }) async {
    try {
      var uri = Uri.parse(addUrl); // ✅ Utilise /ajoutmateriels
      var request = http.MultipartRequest('POST', uri);
      request.fields['nom'] = nom;
      request.fields['prix_journalier'] = prixJournalier.toString();
      request.fields['categorie_id'] = categorie_id.toString();

      if (kIsWeb && webImage != null) {
        final bytes = await webImage.readAsBytes();
        final mimeType = lookupMimeType(webImage.name) ?? 'image/jpeg';

        request.files.add(http.MultipartFile.fromBytes(
          'image_url',
          bytes,
          filename: basename(webImage.name),
          contentType: MediaType.parse(mimeType),
        ));
      } else if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image_url',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      } else {
        throw Exception("L'image est requise.");
      }

      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final res = await response.stream.bytesToString();
        print('Erreur backend: ${response.statusCode} $res');
        return false;
      }
    } catch (e) {
      print('Erreur lors de l\'ajout: $e');
      return false;
    }
  }
}
