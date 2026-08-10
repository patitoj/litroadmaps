import 'package:flutter_test/flutter_test.dart';
import 'package:roadmap_app/main.dart'; // Asegurate de que el nombre coincida con tu proyecto

void main() {
  testWidgets('La aplicación carga y muestra el buscador', (WidgetTester tester) async {
    // Levantamos nuestra aplicación real
    await tester.pumpWidget(const RoadmapApp());

    // Verificamos que el título principal esté en la pantalla
    expect(find.text('Descubrí tu próxima lectura'), findsOneWidget);
  });
}
