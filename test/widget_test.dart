import 'package:flutter_test/flutter_test.dart';

import 'package:wavelet/main.dart';

void main() {
  testWidgets('Wavelet renders the main shell', (WidgetTester tester) async {
    await tester.pumpWidget(const WaveletApp());

    expect(find.text('Wavelet'), findsOneWidget);
    expect(find.text('Good listening'), findsOneWidget);
  });
}
