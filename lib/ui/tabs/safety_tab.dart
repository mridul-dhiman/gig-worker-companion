import 'package:flutter/material.dart';

import '../../l10n/strings.dart';
import '../../state/app_state.dart';
import '../home_shell.dart';
import '../theme.dart';
import '../widgets.dart';

class SafetyTab extends StatelessWidget {
  const SafetyTab({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final s = state;
    final l = s.lang;
    final c = context.sc;
    final t = Theme.of(context).textTheme;
    final pr = s.prof;
    final hz = pr.hazards.firstWhere((h) => h.id == s.hazardId, orElse: () => pr.hazards.first);
    final done = s.checks.where((x) => x).length;
    return TabBody(state: s, sourceKey: null, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SectionTitle(tr(l, 'hazardQ')),
        const Gap(10),
        ChoiceChips<String>(
          values: [for (final h in pr.hazards) h.id],
          selected: hz.id,
          label: (id) => pr.hazards.firstWhere((h) => h.id == id).label,
          onSelect: s.setHazard,
          danger: true,
        ),
      ]),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.line), borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(hz.label, style: t.titleMedium),
          const Gap(6),
          for (final w in hz.whatToDo)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('•  ', style: t.bodyLarge),
                Expanded(child: Text(w, style: t.bodyMedium)),
              ]),
            ),
        ]),
      ),
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SectionTitle(tr(l, 'idRules')),
        const Gap(12),
        StepList(pr.idRules, lang: l),
      ]),
      NextStepButton(label: tr(l, 'report'), sub: tr(l, 'reportSub'), onTap: s.reportHazard),
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SectionTitle(
          tr(l, 'before'),
          trailing: Text(tr(l, 'done', {'a': done, 'b': s.checks.length}),
              style: t.bodySmall!.copyWith(fontWeight: FontWeight.w600)),
        ),
        const Gap(4),
        for (var i = 0; i < pr.safetyChecklist.length; i++)
          CheckboxListTile(
            value: s.checks[i],
            onChanged: (v) => s.toggleCheck(i, v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            activeColor: c.good,
            title: Text(
              pr.safetyChecklist[i],
              style: t.bodyMedium!.copyWith(
                color: s.checks[i] ? c.muted : c.ink,
                decoration: s.checks[i] ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
      ]),
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SectionTitle(tr(l, 'sos')),
        const Gap(10),
        Row(children: [
          for (final (i, (num, label)) in pr.sos.indexed) ...[
            if (i > 0) const Gap(8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                decoration: BoxDecoration(color: c.sunken, borderRadius: BorderRadius.circular(8)),
                child: Column(children: [
                  SelectableText(num, style: AppFonts.display(l, size: 22, weight: FontWeight.w800, color: c.ink)),
                  Text(label, style: t.bodySmall!.copyWith(fontSize: 12), textAlign: TextAlign.center),
                ]),
              ),
            ),
          ],
        ]),
      ]),
    ]);
  }
}
