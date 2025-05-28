// ignore_for_file: file_names

class Materiel {
  final int id;
  final String nom;
  final String? description;
  final String? imageUrl;
  final double prixJournalier;
  final bool disponible;
  final int? categorieId;

  Materiel({
    required this.id,
    required this.nom,
    this.description,
    this.imageUrl,
    required this.prixJournalier,
    required this.disponible,
    this.categorieId,
  });

  factory Materiel.fromJson(Map<String, dynamic> json) {
    return Materiel(
      id: json['id'],
      nom: json['nom'],
      description: json['description'],
      imageUrl: json['image_url'],
      prixJournalier: double.parse(json['prix_journalier'].toString()),
      disponible: json['disponible'] == 1 || json['disponible'] == true,
      categorieId: json['categorie_id'],
    );
  }
}
