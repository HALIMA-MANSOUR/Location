class Materiel {
  final int id;
  final String nom;
  final String description;
  final String imageUrl;
  final double prixJournalier;

  Materiel({
    required this.id,
    required this.nom,
    required this.description,
    required this.imageUrl,
    required this.prixJournalier,
  });

 factory Materiel.fromJson(Map<String, dynamic> json) {
 
  return Materiel(
    id: json['id'],
    nom: json['nom'],
    description: json['description'] ?? '',
    imageUrl: json['image_url'] ?? '',
   prixJournalier: _parseToDouble(json['prix_journalier']),

  );
}
static double _parseToDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is int) return value.toDouble();
  if (value is double) return value;
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

}
