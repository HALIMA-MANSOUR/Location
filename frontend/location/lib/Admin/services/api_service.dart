import 'dart:convert';
import 'package:http/http.dart' as http;
import './../models/reservation.dart';

const String baseUrl = 'http://172.20.10.8:3000'; 

class ApiService {
  static Future<List<Reservation>> fetchReservations() async {
    final response = await http.get(Uri.parse('$baseUrl/reservations'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => Reservation.fromJson(item)).toList();
    } else {
      throw Exception('Échec du chargement des réservations');
    }
  }

static Future<void> updateReservationStatus(int id, String statut) async {
  final response = await http.put(
    Uri.parse('$baseUrl/reservations/$id'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'statut': statut}),
  );

  if (response.statusCode != 200) {

    final Map<String, dynamic> responseData = json.decode(response.body);
    final errorMessage = responseData['message'] ?? 'Erreur inconnue';

 
    throw Exception(errorMessage);
  }
}
}
