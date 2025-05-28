import 'package:flutter/material.dart';
import 'package:location/Admin/pages/login_page.dart';
import 'package:location/pages/MaterielListPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String? nom;
  String? email;
  String? motDePasse;
  int? userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId');
    if (userId != null) {
      final url = Uri.parse('http://localhost:3000/getUser/$userId');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['success']) {
          setState(() {
            nom = result['user']['nom'];
            email = result['user']['email'];
            motDePasse = ""; // Sécurité : ne jamais afficher le vrai mot de passe
            isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  Future<void> _modifierUser() async {
    if (userId == null || nom == null || email == null) return;
    final url = Uri.parse('http://localhost:3000/modifierUser/$userId');
    final body = {
      'nom': nom,
      'email': email,
    };
    if (motDePasse != null && motDePasse!.isNotEmpty) {
      body['motDePasse'] = motDePasse;
    }
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (!mounted) return;
    final result = jsonDecode(response.body);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['success'] == true
            ? 'Profil mis à jour avec succès'
            : result['message'] ?? 'Erreur inconnue'),
      ),
    );
  }

Future<void> _deleteUser() async {
  if (userId == null) return;

  final confirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Supprimer le compte"),
      content: const Text("Êtes-vous sûr de vouloir supprimer votre compte ?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Supprimer")),
      ],
    ),
  );

  if (confirm == true) {
    final url = Uri.parse('http://localhost:3000/deleteUser/$userId');
    final response = await http.delete(url);

    if (!mounted) return;

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Affiche le snackbar puis attend la fin de l'affichage avant de naviguer
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Compte supprimé avec succès"),
          duration: Duration(seconds: 2),
        ),
      );

      // Attendre la durée du SnackBar avant de rediriger
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de la suppression du compte")),
      );
    }
  }
}

  void _showEditDialog() {
    final nomCtrl = TextEditingController(text: nom);
    final emailCtrl = TextEditingController(text: email);
    final passwordCtrl = TextEditingController(text: "");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Modifier le profil"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                nom = nomCtrl.text;
                email = emailCtrl.text;
                motDePasse = passwordCtrl.text;
              });
              Navigator.pop(context);
              _modifierUser();
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => MaterielListPage()),
            );
          },
        ),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blue.shade200,
                        child: Text(
                          nom?.substring(0, 1).toUpperCase() ?? '?',
                          style: const TextStyle(fontSize: 40, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        nom ?? 'Nom inconnu',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        email ?? 'Email inconnu',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: _showEditDialog,
                        icon: const Icon(Icons.edit),
                        label: const Text('Modifier le profil'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.blueGrey,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton.icon(
                        onPressed: _deleteUser,
                        icon: const Icon(Icons.delete_forever),
                        label: const Text('Supprimer mon compte'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.red.shade600,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
