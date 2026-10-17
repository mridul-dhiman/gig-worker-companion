import 'package:flutter/material.dart';

import '../../l10n/strings.dart';
import '../../state/app_state.dart';
import '../home_shell.dart';
import '../theme.dart';
import '../widgets.dart';

class DocumentsTab extends StatelessWidget {
  const DocumentsTab({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final s = state;
    final l = s.lang;
    final c = context.sc;
    final d = s.doc;
    return TabBody(state: s, sourceKey: 'doc', children: [
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        FieldLabel(tr(l, 'notice')),
        TextField(
          controller: s.docCtrl,
          minLines: 4,
          maxLines: 10,
          style: AppFonts.mono(size: 13, color: c.ink),
        ),
        const Gap(10),
        FilledButton(onPressed: s.busy == null ? s.decode : null, child: Text(tr(l, 'explain'))),
      ]),
      if (s.busy == 'doc')
        Thinking(lang: l, retryN: s.retryN)
      else if (d != null) ...[
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: c.ink, borderRadius: BorderRadius.circular(4)),
              child: Text(d.type.toUpperCase(),
                  style: AppFonts.body(l, size: 12, weight: FontWeight.w700, color: c.paper).copyWith(letterSpacing: .6)),
            ),
          ),
          const Gap(10),
          PlainBox(d.summary),
          if (d.deadline.isNotEmpty) ...[
            const Gap(10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: c.badBg, borderRadius: BorderRadius.circular(8)),
              child: Row(children: [
                Icon(Icons.schedule, color: c.bad),
                const Gap(10),
                Expanded(
                  child: Text('${tr(l, 'deadline')}: ${d.deadline}',
                      style: AppFonts.body(l, weight: FontWeight.w700, color: c.bad)),
                ),
              ]),
            ),
          ],
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SectionTitle(tr(l, 'steps')),
          const Gap(12),
          StepList(d.steps, lang: l),
        ]),
        if (d.terms.isNotEmpty)
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SectionTitle(tr(l, 'words')),
            const Gap(6),
            TermList(d.terms),
          ]),
        NextStepButton(label: tr(l, 'draftReply'), sub: tr(l, 'draftReplySub'), onTap: s.replyToNotice),
      ],
    ]);
  }
}
