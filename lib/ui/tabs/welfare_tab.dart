import 'package:flutter/material.dart';

import '../../data/professions.dart';
import '../../l10n/strings.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../home_shell.dart';
import '../theme.dart';
import '../widgets.dart';

class WelfareTab extends StatelessWidget {
  const WelfareTab({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final s = state;
    final l = s.lang;
    final c = context.sc;
    final t = Theme.of(context).textTheme;
    final schemes = s.schemes;
    return TabBody(state: s, sourceKey: 'welfare', children: [
      Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.ink, width: 2))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              FieldLabel(tr(l, 'monthly')),
              Text(inr(s.monthly), style: AppFonts.display(l, size: 34, weight: FontWeight.w800, color: c.ink)),
            ]),
          ),
          Text(
            '${tr(l, 'perDay', {'x': inr(s.monthly ~/ 26)})}\n${tr(l, 'obAge')} ${s.profile!.age} · ${s.profile!.state}',
            textAlign: TextAlign.right,
            style: t.bodySmall,
          ),
        ]),
      ),
      if (s.busy == 'welfare')
        Thinking(lang: l, retryN: s.retryN)
      else
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SectionTitle(tr(l, 'firstStep')),
          const Gap(10),
          PlainBox(s.welfareAdvice),
        ]),
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        for (final sc in schemes) ...[_SchemeCard(state: s, scheme: sc), const Gap(10)],
      ]),
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SectionTitle(tr(l, 'rights')),
        const Gap(6),
        for (final (law, plain) in s.prof.rights)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.line))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(law, style: AppFonts.mono(size: 13, color: c.muted)),
              Text(plain, style: t.bodyLarge),
            ]),
          ),
      ]),
      Text(tr(l, 'schemeNote'), style: t.bodySmall),
    ]);
  }
}

class _SchemeCard extends StatelessWidget {
  const _SchemeCard({required this.state, required this.scheme});
  final AppState state;
  final Scheme scheme;

  @override
  Widget build(BuildContext context) {
    final l = state.lang;
    final c = context.sc;
    final t = Theme.of(context).textTheme;
    final dim = scheme.status == SchemeStatus.notEligible;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dim ? Colors.transparent : c.surface,
        border: Border.all(color: c.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Text(scheme.name,
                style: AppFonts.display(l, size: 18, color: dim ? c.muted : c.ink)),
          ),
          const Gap(10),
          StatusPill(status: scheme.status, lang: l),
        ]),
        const Gap(6),
        Text(scheme.benefit, style: t.bodyMedium!.copyWith(color: dim ? c.muted : c.ink)),
        const Gap(4),
        Text(scheme.why, style: t.bodySmall!.copyWith(fontSize: 14)),
        if (!dim)
          TextButton.icon(
            onPressed: () => state.docHelpFor(scheme),
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: Text(tr(l, 'docHelp')),
            style: TextButton.styleFrom(
              foregroundColor: c.marigoldInk,
              padding: const EdgeInsets.only(top: 8),
              textStyle: AppFonts.body(l, size: 15, weight: FontWeight.w700),
            ),
          ),
      ]),
    );
  }
}
