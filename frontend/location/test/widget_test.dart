import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:location/pages/materiel_list_page.dart'; // Assure-toi que ce chemin est correct

void main() {
  testWidgets('Test que la page MaterielListPage se charge correctement', (WidgetTester tester) async {
    // Build notre application et déclenche un frame.
    await tester.pumpWidget(const MaterialApp(
      home: MaterielListPage(),
    ));

    // Vérifie que le texte 'Location de Matériels' est trouvé (cela doit être une partie de la page MaterielListPage).
    expect(find.text('Location de Matériels'), findsOneWidget);
    
    // Ajoute d'autres tests spécifiques ici, par exemple vérifier si une liste est présente.
  });
}
