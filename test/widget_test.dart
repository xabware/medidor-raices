import 'package:flutter_test/flutter_test.dart';
import 'package:medidor_raices/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MedidorRaicesApp());
    
    expect(find.text('Medidor de Raíces'), findsOneWidget);
  });
}
