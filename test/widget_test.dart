import 'package:flutter_test/flutter_test.dart';
import 'package:punch_in_punch_out_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('renders the Punch In app', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const PunchInApp());
    await tester.pumpAndSettle();
    expect(find.text('Welcome back.'), findsOneWidget);
  });
}
