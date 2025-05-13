class Reservation {
  final int id;
  final String nomMateriel;
  final String nomUtilisateur;
  final String dateDebut;
  final String dateFin;
  final double prix;
  final double total;
  String statut;

  Reservation({
    required this.id,
    required this.nomMateriel,
    required this.nomUtilisateur,
    required this.dateDebut,
    required this.dateFin,
    required this.prix,
    required this.total,
    required this.statut,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      nomMateriel: json['nom_materiel'],
      nomUtilisateur: json['nom_utilisateur'],
      dateDebut: json['date_debut'],
      dateFin: json['date_fin'],
     prix: double.tryParse(json['prix'].toString()) ?? 0.0,
total: double.tryParse(json['total'].toString()) ?? 0.0,

      statut: json['statut'] ?? 'en_attente',
    );
  }
}
