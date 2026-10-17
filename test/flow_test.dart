import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saathi_ai/l10n/strings.dart';
import 'package:saathi_ai/main.dart';
import 'package:saathi_ai/models/models.dart';
import 'package:saathi_ai/state/app_state.dart';
import 'package:saathi_ai/ui/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Signs up as a delivery partner with no API key (so every answer comes from
/// the fallback engine) and walks the connected "Next Step" flows.
void main() {
  setUp(() {
    AppFonts.useGoogleFonts = false;
    SharedPreferences.setMockInitialValues({});
  });

  Future<AppState> signUp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final state = AppState();
    await state.load();
    await tester.pumpWidget(SaathiApp(state: state));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '9876504410');
    await tester.tap(find.text('Send OTP'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '482913');
    await tester.tap(find.text('Verify and continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delivery partner'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start using Saathi'));
    await tester.pumpAndSettle();
    return state;
  }

  testWidgets('sign-up lands on Earnings with the take-home worked out', (tester) async {
    final state = await signUp(tester);
    expect(state.profile!.name, 'Rajesh Kumar');
    expect(find.text('Namaste, Rajesh'), findsWidgets);
    expect(find.text('₹730'), findsWidgets);
    expect(find.text('Contest ₹180 deduction'), findsOneWidget);
  });

  testWidgets('Earnings → Complaint carries the deduction', (tester) async {
    final state = await signUp(tester);
    await tester.tap(find.text('Contest ₹180 deduction'));
    await tester.pumpAndSettle();
    expect(state.tab, 1);
    expect(state.disputeCtrl.text, startsWith('₹180 was cut from my pay.'));
    expect(state.letter!.body, contains('Rajesh Kumar'));
  });

  testWidgets('cash and SMS entries change the take-home', (tester) async {
    final state = await signUp(tester);
    state.addCash(EntryDir.gotMoney, 40, 'Cash tip');
    state.loadSampleSms();
    final tip = state.sms.firstWhere((e) => e.amount == 60);
    state.setSmsStatus(tip, SmsStatus.added);
    await tester.pumpAndSettle();
    expect(state.totals.net, 730 + 40 + 60);
  });

  testWidgets('every tab renders and each hand-off switches tab', (tester) async {
    final state = await signUp(tester);
    state.checkSchemes();
    await tester.pumpAndSettle();
    expect(state.tab, 2);
    expect(find.text('e-Shram card'), findsOneWidget);

    state.docHelpFor(state.schemes.first);
    await tester.pumpAndSettle();
    expect(state.tab, 3);
    expect(state.doc!.type, 'Scheme checklist');

    state.replyToNotice();
    await tester.pumpAndSettle();
    expect(state.tab, 1);

    state.goTab(4);
    await tester.pumpAndSettle();
    state.reportHazard();
    await tester.pumpAndSettle();
    expect(state.tab, 1);
    expect(state.disputeCtrl.text, startsWith('Unsafe work condition'));
  });

  testWidgets('switching to Hindi translates the tab bar', (tester) async {
    final state = await signUp(tester);
    state.setLang(AppLang.hi);
    await tester.pumpAndSettle();
    expect(find.text('कमाई'), findsWidgets);
  });
}
