import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/professions.dart';
import '../l10n/strings.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import 'theme.dart';
import 'widgets.dart';

/// Four steps: language + phone, OTP, work type, about you.
/// When [editing] is true the worker is changing work type from the profile,
/// so it starts at step 3 and keeps their details.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.state, this.editing = false, this.onCancel});
  final AppState state;
  final bool editing;
  final VoidCallback? onCancel;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  /// No SMS gateway in the web demo; Firebase phone auth slots in here.
  static const demoOtp = '482913';

  late int step = widget.editing ? 3 : 1;
  final phone = TextEditingController();
  final otp = TextEditingController();
  final name = TextEditingController();
  final age = TextEditingController();
  String place = 'Delhi';
  String? profId;
  bool touched = false;
  String? err;

  AppState get s => widget.state;
  AppLang get l => s.lang;

  @override
  void initState() {
    super.initState();
    final p = s.profile;
    if (p != null) {
      phone.text = p.phone;
      name.text = p.name;
      age.text = '${p.age}';
      place = p.state;
      profId = p.professionId;
      touched = true;
    }
  }

  @override
  void dispose() {
    for (final c in [phone, otp, name, age]) {
      c.dispose();
    }
    super.dispose();
  }

  void _back() {
    if (widget.editing && step == 3) {
      widget.onCancel?.call();
      return;
    }
    setState(() {
      step--;
      err = null;
    });
  }

  void _sendOtp() {
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(phone.text)) {
      setState(() => err = tr(l, 'errPhone'));
      return;
    }
    setState(() {
      err = null;
      step = 2;
      otp.clear();
    });
  }

  void _verify() {
    if (otp.text != demoOtp) {
      setState(() => err = tr(l, 'obWrongOtp'));
      return;
    }
    setState(() {
      err = null;
      step = 3;
    });
  }

  void _pickProfession(String id) {
    setState(() {
      profId = id;
      if (!touched) {
        final pr = professions[id]!;
        name.text = pr.sampleName;
        age.text = '${pr.sampleAge}';
        place = pr.sampleState;
      }
    });
  }

  void _finish() {
    final a = int.tryParse(age.text) ?? 0;
    if (name.text.trim().isEmpty || a < 14 || a > 80) {
      setState(() => err = tr(l, 'errName'));
      return;
    }
    s.completeOnboarding(Profile(
      name: name.text.trim(),
      age: a,
      state: place,
      phone: phone.text,
      professionId: profId!,
    ));
    widget.onCancel?.call();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      body: Column(children: [
        Container(
          width: double.infinity,
          color: c.bar,
          padding: EdgeInsets.fromLTRB(20, 22 + MediaQuery.paddingOf(context).top, 20, 18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Wordmark(color: c.onBar),
                  const Spacer(),
                  Text(tr(l, 'step', {'a': step, 'b': 4}),
                      style: t.bodySmall!.copyWith(color: c.onBar.withValues(alpha: .75), fontWeight: FontWeight.w600)),
                ]),
                const Gap(14),
                Row(children: [
                  for (var i = 1; i <= 4; i++)
                    Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(right: i < 4 ? 6 : 0),
                        decoration: BoxDecoration(
                          color: i <= step ? c.marigold : c.onBar.withValues(alpha: .18),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                ]),
                if (step == 1) ...[
                  const Gap(16),
                  Text(tr(l, 'obWelcome'), style: AppFonts.display(l, size: 30, weight: FontWeight.w800, color: c.onBar)),
                  const Gap(6),
                  Text(tr(l, 'obWelcomeSub'), style: t.bodyMedium!.copyWith(color: c.onBar.withValues(alpha: .8))),
                ],
              ]),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 32),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  if (step > 1)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _back,
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: Text(tr(l, 'back')),
                        style: TextButton.styleFrom(foregroundColor: c.marigoldInk, padding: EdgeInsets.zero),
                      ),
                    ),
                  ..._stepBody(context),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  List<Widget> _stepBody(BuildContext context) {
    final c = context.sc;
    final t = Theme.of(context).textTheme;
    final error = err == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(err!, style: t.bodyMedium!.copyWith(color: c.bad, fontWeight: FontWeight.w600)),
          );
    switch (step) {
      case 1:
        return [
          FieldLabel(tr(l, 'obLang')),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.6,
            children: [
              for (final lang in AppLang.values)
                _Tile(
                  selected: lang == l,
                  onTap: () {
                    s.setLang(lang);
                    setState(() {});
                  },
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(lang.native, style: AppFonts.display(lang, size: 19, color: c.ink)),
                    Text(lang.sample, style: AppFonts.body(lang, size: 13, color: c.muted)),
                  ]),
                ),
            ],
          ),
          const Gap(18),
          FieldLabel(tr(l, 'obPhone')),
          TextField(
            controller: phone,
            keyboardType: TextInputType.phone,
            autofillHints: const [AutofillHints.telephoneNumberNational],
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
            style: AppFonts.mono(size: 18, color: c.ink),
            decoration: InputDecoration(prefixText: '+91  ', hintText: '98765 43210', prefixStyle: AppFonts.mono(size: 18, color: c.muted)),
            onSubmitted: (_) => _sendOtp(),
          ),
          error,
          const Gap(14),
          FilledButton(onPressed: _sendOtp, child: Text(tr(l, 'obSend'))),
          const Gap(10),
          Text(tr(l, 'obPrivacy'), style: t.bodySmall),
        ];
      case 2:
        return [
          Text(tr(l, 'obOtpT'), style: t.titleLarge),
          const Gap(4),
          Text('${tr(l, 'obOtp')} +91 ${phone.text}', style: t.bodyMedium!.copyWith(color: c.muted)),
          const Gap(16),
          TextField(
            controller: otp,
            autofocus: true,
            keyboardType: TextInputType.number,
            autofillHints: const [AutofillHints.oneTimeCode],
            textAlign: TextAlign.center,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
            style: AppFonts.mono(size: 30, color: c.ink).copyWith(letterSpacing: 12),
            decoration: InputDecoration(hintText: '••••••', semanticCounterText: tr(l, 'obOtpT')),
            onSubmitted: (_) => _verify(),
          ),
          error,
          const Gap(10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: c.sunken, borderRadius: BorderRadius.circular(10)),
            child: Text(tr(l, 'obDemo', {'c': demoOtp}), style: t.bodyMedium!.copyWith(fontWeight: FontWeight.w600)),
          ),
          const Gap(14),
          FilledButton(onPressed: _verify, child: Text(tr(l, 'obVerify'))),
        ];
      case 3:
        return [
          Text(tr(l, 'obWork'), style: t.titleLarge),
          const Gap(4),
          Text(tr(l, 'obWorkSub'), style: t.bodyMedium!.copyWith(color: c.muted)),
          const Gap(16),
          for (final pr in professions.values) ...[
            _Tile(
              selected: profId == pr.id,
              onTap: () => _pickProfession(pr.id),
              child: Row(children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: profId == pr.id ? c.marigold : c.sunken,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(professionIcon(pr.id), color: profId == pr.id ? c.onMarigold : c.ink, size: 26),
                ),
                const Gap(12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(pr.title(l), style: AppFonts.display(l, size: 18, color: c.ink)),
                    Text(pr.subtitle(l), style: t.bodySmall!.copyWith(fontSize: 14)),
                  ]),
                ),
                Icon(profId == pr.id ? Icons.check_circle : Icons.circle_outlined,
                    color: profId == pr.id ? c.marigold : c.line),
              ]),
            ),
            const Gap(10),
          ],
          const Gap(4),
          FilledButton(
            onPressed: profId == null ? null : () => setState(() => step = 4),
            child: Text(tr(l, 'obNext')),
          ),
        ];
      default:
        return [
          Text(tr(l, 'obAbout'), style: t.titleLarge),
          const Gap(4),
          Text(tr(l, 'obWhy'), style: t.bodyMedium!.copyWith(color: c.muted)),
          const Gap(16),
          FieldLabel(tr(l, 'obName')),
          TextField(
            controller: name,
            autofillHints: const [AutofillHints.name],
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => touched = true,
          ),
          const Gap(12),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              width: 100,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                FieldLabel(tr(l, 'obAge')),
                TextField(
                  controller: age,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                  onChanged: (_) => touched = true,
                ),
              ]),
            ),
            const Gap(10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                FieldLabel(tr(l, 'obState')),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: place,
                  items: [for (final st in states) DropdownMenuItem(value: st, child: Text(st))],
                  onChanged: (v) => setState(() {
                    place = v!;
                    touched = true;
                  }),
                ),
              ]),
            ),
          ]),
          error,
          const Gap(16),
          FilledButton.icon(
            onPressed: _finish,
            style: FilledButton.styleFrom(backgroundColor: c.marigold, foregroundColor: c.onMarigold),
            icon: const Icon(Icons.arrow_forward),
            iconAlignment: IconAlignment.end,
            label: Text(tr(l, 'obStart')),
          ),
        ];
    }
  }
}

IconData professionIcon(String id) => switch (id) {
      'delivery' => Icons.pedal_bike,
      'driver' => Icons.local_taxi_outlined,
      _ => Icons.construction,
    };

class _Tile extends StatelessWidget {
  const _Tile({required this.selected, required this.onTap, required this.child});
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? Color.alphaBlend(c.marigold.withValues(alpha: .14), c.surface) : c.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: selected ? c.marigold : c.line, width: 1.5),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(padding: const EdgeInsets.all(12), child: child),
        ),
      ),
    );
  }
}

class Wordmark extends StatelessWidget {
  const Wordmark({super.key, required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(width: 9, height: 9, decoration: BoxDecoration(color: context.sc.marigold, shape: BoxShape.circle)),
        const SizedBox(width: 7),
        Text('Saathi', style: AppFonts.display(AppLang.en, size: 24, weight: FontWeight.w800, color: color)),
        const SizedBox(width: 6),
        Text('साथी', style: AppFonts.body(AppLang.hi, size: 14, weight: FontWeight.w500, color: color.withValues(alpha: .7))),
      ]);
}
