import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';

class CategoryService {
  final String apiUrl = "http://localhost:3000/Catgmateriels"; 

  Future<List<Category>> getCategories() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((m) => Category.fromJson(m)).toList();
    } else {
      throw Exception('Erreur de chargement des catégories');
    }
  }
}
