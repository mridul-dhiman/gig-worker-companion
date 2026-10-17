import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/professions.dart';
import '../../l10n/strings.dart';
import '../../state/app_state.dart';
import '../home_shell.dart';
import '../theme.dart';
import '../widgets.dart';

class GrievanceTab extends StatelessWidget {
  const GrievanceTab({super.key, required this.state});
  final AppState state;

  String _recName(AppLang l, Recipient r) => tr(l, switch (r) {
        Recipient.platform => 'recPlatform',
        Recipient.contractor => 'recContractor',
        Recipient.labour => 'recLabour',
        Recipient.court => 'recCourt',
      });

  @override
  Widget build(BuildContext context) {
    final s = state;
    final l = s.lang;
    final c = context.sc;
    final t = Theme.of(context).textTheme;
    final letter = s.letter;
    return TabBody(state: s, sourceKey: 'draft', children: [
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        FieldLabel(tr(l, 'whatHappened')),
        TextField(controller: s.disputeCtrl, minLines: 3, maxLines: 8),
        const Gap(12),
        FieldLabel(tr(l, 'sendTo')),
        ChoiceChips<Recipient>(
          values: Recipient.values,
          selected: s.recipient,
          label: (r) => _recName(l, r),
          onSelect: s.setRecipient,
        ),
      ]),
      _ProofSection(state: s),
      FilledButton(onPressed: s.busy == null ? s.draft : null, child: Text(tr(l, 'draft'))),
      if (s.busy == 'draft')
        Thinking(lang: l, retryN: s.retryN)
      else if (letter != null) ...[
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SectionTitle(tr(l, 'simple')),
          const Gap(10),
          PlainBox(letter.explanation),
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SectionTitle(tr(l, 'formal')),
          const Gap(10),
          Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            decoration: BoxDecoration(
              color: c.surface,
              border: Border.all(color: c.line),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('To: ${letter.to}', style: AppFonts.mono(size: 12, color: c.muted)),
              Text('Subject: ${letter.subject}', style: AppFonts.mono(size: 12, color: c.muted)),
              Divider(color: c.line, height: 20),
              SelectableText(letter.body, style: t.bodyMedium!.copyWith(height: 1.55)),
            ]),
          ),
          const Gap(8),
          OutlinedButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: letter.fullText));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(l, 'copied'))));
              }
            },
            icon: const Icon(Icons.copy, size: 18),
            label: Text(tr(l, 'copy')),
          ),
        ]),
      ],
    ]);
  }
}

class _ProofSection extends StatelessWidget {
  const _ProofSection({required this.state});
  final AppState state;

  Future<void> _pick(BuildContext context, ImageSource source) async {
    final file = await ImagePicker().pickImage(source: source, maxWidth: 1600, imageQuality: 85);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final name = file.name.isEmpty ? 'photo.jpg' : file.name;
    final mime = file.mimeType ??
        (name.toLowerCase().endsWith('.png')
            ? 'image/png'
            : name.toLowerCase().endsWith('.webp')
                ? 'image/webp'
                : 'image/jpeg');
    await state.attachProof(bytes, mime, name);
  }

  @override
  Widget build(BuildContext context) {
    final s = state;
    final l = s.lang;
    final c = context.sc;
    final t = Theme.of(context).textTheme;
    final p = s.proof;
    Widget pickButton(IconData icon, String label, ImageSource src) => Expanded(
          child: OutlinedButton(
            onPressed: s.busy == null ? () => _pick(context, src) : null,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(76),
              side: BorderSide(color: c.muted, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon),
              const Gap(4),
              Text(label, textAlign: TextAlign.center),
            ]),
          ),
        );
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionTitle(tr(l, 'proofT')),
      const Gap(6),
      if (s.busy == 'proof')
        Thinking(lang: l, retryN: s.retryN, label: tr(l, 'reading'))
      else if (p != null) ...[
        Row(children: [
          Container(
            width: 64,
            height: 84,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: c.sunken,
              border: Border.all(color: c.line),
              borderRadius: BorderRadius.circular(8),
            ),
            child: p.bytes != null ? Image.memory(p.bytes!, fit: BoxFit.cover) : Icon(Icons.image_outlined, color: c.muted),
          ),
          const Gap(12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.fileName, style: AppFonts.mono(size: 13, color: c.ink)),
              Text(p.kind, style: t.bodySmall!.copyWith(fontSize: 14)),
            ]),
          ),
        ]),
        const Gap(10),
        if (!p.readOk)
          Text(tr(l, 'proofFail'), style: t.bodyMedium!.copyWith(color: c.muted))
        else ...[
          FieldLabel(tr(l, 'readT')),
          TermList(p.facts),
          const Gap(10),
          if (s.proofUsed)
            Row(children: [
              Icon(Icons.check, color: c.good, size: 18),
              const Gap(6),
              Text(tr(l, 'factsAdded'), style: t.bodyMedium!.copyWith(color: c.good, fontWeight: FontWeight.w700)),
            ])
          else
            NextStepButton(label: tr(l, 'useFacts'), onTap: s.useProofFacts, quiet: true),
        ],
        const Gap(12),
      ] else
        Text(tr(l, 'proofSub'), style: t.bodyMedium!.copyWith(color: c.muted)),
      const Gap(8),
      Row(children: [
        pickButton(Icons.photo_camera_outlined, tr(l, 'scan'), ImageSource.camera),
        const Gap(8),
        pickButton(Icons.image_outlined, tr(l, 'upload'), ImageSource.gallery),
      ]),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: s.busy == null ? s.useSampleProof : null,
          style: TextButton.styleFrom(foregroundColor: c.marigoldInk, padding: const EdgeInsets.symmetric(vertical: 8)),
          child: Text(tr(l, 'proofSample')),
        ),
      ),
    ]);
  }
}
