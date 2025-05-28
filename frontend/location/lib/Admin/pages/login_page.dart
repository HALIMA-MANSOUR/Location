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
                    final userId = result['user']['id'];
                    await prefs.setInt('userId', userId);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MaterielListPage()),
          );
        } else if (result['user']['role'] == 'client') {
          final userId = result['user']['id'];

          await prefs.setInt('userId', userId);
         Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => const MaterielListPage()),
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
      elevation: 0,
    ),
    backgroundColor: Colors.white,
    body: SafeArea(
      child: Center(  // Centre verticalement et horizontalement
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 400, // Limite la largeur max du formulaire
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
  child:
                  Text(
                    'Connexion',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                  ),),
                  const SizedBox(height: 8),
                  Text(
                    'Connectez-vous pour continuer à réserver.',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 36),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildInputField(
                          label: 'Adresse Email',
                          icon: Icons.email_outlined,
                          onChanged: (val) => email = val,
                        ),
                        const SizedBox(height: 20),
                        _buildInputField(
                          label: 'Mot de passe',
                          icon: Icons.lock_outline,
                          obscure: true,
                          onChanged: (val) => motDePasse = val,
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    loginUser();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 6,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Text(
                                  'Se connecter',
                                  style: TextStyle(fontSize: 18),
                                ),
                        ),
                        const SizedBox(height: 18),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RegisterPage()),
                            );
                          },
                          child: const Text(
                            "Pas encore de compte ? S'inscrire",
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
      validator: (val) =>
          val == null || val.isEmpty ? 'Ce champ est requis' : null,
      onChanged: onChanged,
    );
  }
}
