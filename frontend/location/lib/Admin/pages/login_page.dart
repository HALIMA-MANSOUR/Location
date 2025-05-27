// ignore_for_file: library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:location/Admin/pages/dashboard_admin.dart';
import 'package:location/pages/Inscription.dart';
import 'package:location/pages/MaterielListPage.dart';
import 'package:location/pages/Profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String motDePasse = '';
  bool isLoading = false;

Future<void> loginUser() async {
  setState(() {
    isLoading = true;
  });

  final url = Uri.parse('http://localhost:3000/loginUser');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'mot_de_passe': motDePasse,
      }),
    );

    final result = jsonDecode(response.body);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? 'Erreur inconnue')),
    );

    if (response.statusCode == 200 && result['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('role', result['user']['role']); // sauvegarde le rôle

      // Redirection selon le rôle
      if (result['user']['role'] == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardAdmin()),
        );
      } else if (result['user']['role'] == 'client') {
        final userId = result['user']['id']; 

  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('userId', userId);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfilPage()),
        );
      } else {
        // Au cas où rôle inconnu, rester sur la page ou afficher une erreur
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rôle utilisateur inconnu')),
        );
      }
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la connexion : $e")),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Retour',
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => MaterielListPage()),
            );
          },
        ),
        title: const Text('Connexion'),
        backgroundColor: Colors.blueAccent,
   
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Connexion',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Connectez-vous pour continuer à réserver.',
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildInputField(
                      label: 'Adresse Email',
                      icon: Icons.email,
                      onChanged: (val) => email = val,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      label: 'Mot de passe',
                      icon: Icons.lock,
                      obscure: true,
                      onChanged: (val) => motDePasse = val,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                loginUser();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              'Se connecter',
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterPage()),
                        );
                      },
                      child: const Text(
                        "Pas encore de compte ? S'inscrire",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required Function(String) onChanged,
    bool obscure = false,
  }) {
    return TextFormField(
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (val) =>
          val == null || val.isEmpty ? 'Ce champ est requis' : null,
      onChanged: onChanged,
    );
  }
}
