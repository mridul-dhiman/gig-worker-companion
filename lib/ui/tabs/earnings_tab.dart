import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/professions.dart';
import '../../l10n/strings.dart';
import '../../models/models.dart';
import '../../state/app_state.dart';
import '../home_shell.dart';
import '../theme.dart';
import '../widgets.dart';

class EarningsTab extends StatelessWidget {
  const EarningsTab({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final s = state;
    final l = s.lang;
    final c = context.sc;
    final t = Theme.of(context).textTheme;
    final tt = s.totals;
    final e = s.earn;
    return TabBody(state: s, sourceKey: 'earn', children: [
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        FieldLabel(tr(l, 'tellDay')),
        TextField(controller: s.logCtrl, minLines: 3, maxLines: 6),
        const Gap(10),
        FilledButton(onPressed: s.busy == null ? s.calculate : null, child: Text(tr(l, 'calc'))),
      ]),
      if (s.busy == 'earn')
        Thinking(lang: l, retryN: s.retryN)
      else ...[
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          FieldLabel(tr(l, 'todayNet')),
          Text(inr(tt.net),
              style: AppFonts.display(l, size: 52, weight: FontWeight.w800, color: c.ink)
                  .copyWith(fontFeatures: const [FontFeature.tabularFigures()], height: 1)),
          const Gap(12),
          _SplitBar(net: tt.net, expense: tt.expense, deduction: tt.deduction),
          const Gap(6),
          _LedgerRow(label: tr(l, 'fromNote'), value: inr(e.gross)),
          if (tt.cashIn > 0) _LedgerRow(label: '+ ${tr(l, 'cashLine')}', value: inr(tt.cashIn)),
          if (tt.smsIn > 0) _LedgerRow(label: '+ ${tr(l, 'smsLine')}', value: inr(tt.smsIn)),
          _LedgerRow(label: tr(l, 'exp'), value: '− ${inr(tt.expense)}', key_: c.muted.withValues(alpha: .55)),
          _LedgerRow(label: tr(l, 'ded'), value: '− ${inr(tt.deduction)}', key_: c.bad),
          _LedgerRow(label: tr(l, 'takehome'), value: inr(tt.net), key_: c.good, bold: true),
          if (e.summary.isNotEmpty) ...[const Gap(10), Text(e.summary, style: t.bodyMedium)],
        ]),
        if (e.deduction > 0 && e.deductionWhy.isNotEmpty)
          Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            decoration: BoxDecoration(
              color: c.badBg,
              borderRadius: BorderRadius.circular(14),
              border: Border(left: BorderSide(color: c.bad, width: 4)),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.warning_amber_rounded, color: c.bad),
              const Gap(10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${tr(l, 'unfair')}: ${inr(e.deduction)}',
                      style: t.bodyLarge!.copyWith(color: c.bad, fontWeight: FontWeight.w700)),
                  Text(e.deductionWhy, style: t.bodyMedium),
                ]),
              ),
            ]),
          ),
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (e.deduction > 0) ...[
            NextStepButton(
              label: tr(l, 'contest', {'x': inr(e.deduction)}),
              sub: tr(l, 'contestSub'),
              onTap: s.contestDeduction,
            ),
            const Gap(10),
          ],
          NextStepButton(
            label: tr(l, 'schemes'),
            sub: tr(l, 'schemesSub', {'x': inr(s.monthlyEstimate)}),
            onTap: s.checkSchemes,
            quiet: true,
          ),
        ]),
      ],
      _CashSection(state: s),
      _SmsSection(state: s),
      _WeekChart(state: s),
    ]);
  }
}

class _SplitBar extends StatelessWidget {
  const _SplitBar({required this.net, required this.expense, required this.deduction});
  final int net, expense, deduction;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final parts = [(max(net, 0), c.good), (expense, c.muted.withValues(alpha: .55)), (deduction, c.bad)]
        .where((p) => p.$1 > 0)
        .toList();
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: SizedBox(
        height: 14,
        child: parts.isEmpty
            ? ColoredBox(color: c.sunken)
            : Row(children: [for (final (v, col) in parts) Expanded(flex: v, child: ColoredBox(color: col))]),
      ),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({required this.label, required this.value, this.key_, this.bold = false});
  final String label, value;
  final Color? key_;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.line))),
      child: Row(children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: key_ ?? Colors.transparent, borderRadius: BorderRadius.circular(3)),
        ),
        const Gap(10),
        Expanded(child: Text(label, style: t.bodyMedium!.copyWith(fontWeight: bold ? FontWeight.w700 : null))),
        Text(value, style: AppFonts.mono(size: 15, color: c.ink, weight: bold ? FontWeight.w600 : FontWeight.w500)),
      ]),
    );
  }
}

class _CashSection extends StatefulWidget {
  const _CashSection({required this.state});
  final AppState state;

  @override
  State<_CashSection> createState() => _CashSectionState();
}

class _CashSectionState extends State<_CashSection> {
  final amount = TextEditingController();
  EntryDir dir = EntryDir.gotMoney;
  String? label;

  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  void _add() {
    final a = int.tryParse(amount.text) ?? 0;
    if (a <= 0) return;
    final s = widget.state;
    final labels = dir == EntryDir.gotMoney ? s.prof.cashIn : s.prof.cashOut;
    s.addCash(dir, a, label ?? labels.first);
    amount.clear();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final l = s.lang;
    final c = context.sc;
    final t = Theme.of(context).textTheme;
    final labels = dir == EntryDir.gotMoney ? s.prof.cashIn : s.prof.cashOut;
    final chosen = labels.contains(label) ? label! : labels.first;
    final entries = s.todayCash;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionTitle(tr(l, 'cashT')),
      Text(tr(l, 'cashSub'), style: t.bodySmall),
      const Gap(10),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: c.sunken, borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SegmentedButton<EntryDir>(
            segments: [
              ButtonSegment(value: EntryDir.gotMoney, label: Text('+ ${tr(l, 'got')}')),
              ButtonSegment(value: EntryDir.spentMoney, label: Text('− ${tr(l, 'spent')}')),
            ],
            selected: {dir},
            showSelectedIcon: false,
            onSelectionChanged: (v) => setState(() {
              dir = v.first;
              label = null;
            }),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((st) => st.contains(WidgetState.selected)
                  ? (dir == EntryDir.gotMoney ? c.good : c.ink)
                  : c.surface),
              foregroundColor:
                  WidgetStateProperty.resolveWith((st) => st.contains(WidgetState.selected) ? c.surface : c.ink),
            ),
          ),
          const Gap(10),
          Row(children: [
            Expanded(
              child: TextField(
                controller: amount,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                style: AppFonts.mono(size: 18, color: c.ink),
                decoration: InputDecoration(prefixText: '₹ ', hintText: '0', labelText: tr(l, 'amount')),
                onSubmitted: (_) => _add(),
              ),
            ),
            const Gap(8),
            FilledButton(
              onPressed: _add,
              style: FilledButton.styleFrom(minimumSize: const Size(88, 52)),
              child: Text(tr(l, 'add')),
            ),
          ]),
          const Gap(10),
          ChoiceChips<String>(
            values: labels,
            selected: chosen,
            label: (v) => v,
            onSelect: (v) => setState(() => label = v),
          ),
          if (s.prof.id == 'delivery') ...[const Gap(10), Text(tr(l, 'codNote'), style: t.bodySmall)],
        ]),
      ),
      for (final e in entries)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.line))),
          child: Row(children: [
            _DirDot(dir: e.dir),
            const Gap(10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.label, style: t.bodyMedium),
                Text(TimeOfDay.fromDateTime(e.at).format(context), style: t.bodySmall),
              ]),
            ),
            Text(inr(e.amount), style: AppFonts.mono(size: 15, color: c.ink)),
            IconButton(
              tooltip: '${tr(l, 'remove')} ${e.label}',
              onPressed: () => s.removeCash(e),
              icon: Icon(Icons.close, size: 18, color: c.muted),
            ),
          ]),
        ),
    ]);
  }
}

class _DirDot extends StatelessWidget {
  const _DirDot({required this.dir, this.flag = false});
  final EntryDir? dir;
  final bool flag;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final (fg, bg, txt) = flag
        ? (c.bad, c.badBg, '!')
        : dir == EntryDir.gotMoney
            ? (c.good, c.goodBg, '+')
            : (c.hold, c.holdBg, '−');
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Text(txt, style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 15)),
    );
  }
}

class _SmsSection extends StatefulWidget {
  const _SmsSection({required this.state});
  final AppState state;

  @override
  State<_SmsSection> createState() => _SmsSectionState();
}

class _SmsSectionState extends State<_SmsSection> {
  final paste = TextEditingController();
  String? err;

  @override
  void dispose() {
    paste.dispose();
    super.dispose();
  }

  void _read() {
    final ok = widget.state.readSms(paste.text);
    setState(() => err = ok ? null : tr(widget.state.lang, 'smsNone'));
    if (ok) paste.clear();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final l = s.lang;
    final c = context.sc;
    final t = Theme.of(context).textTheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionTitle(tr(l, 'smsT'), trailing: Icon(Icons.sms_outlined, color: c.muted)),
      const Gap(4),
      Text(tr(l, 'smsWeb'), style: t.bodyMedium),
      const Gap(10),
      TextField(
        controller: paste,
        minLines: 2,
        maxLines: 4,
        style: AppFonts.mono(size: 13, color: c.ink),
        decoration: const InputDecoration(hintText: 'Rs.60.00 received in A/c XX4410 from … via UPI'),
      ),
      if (err != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(err!, style: t.bodyMedium!.copyWith(color: c.bad))),
      const Gap(8),
      Row(children: [
        Expanded(child: FilledButton(onPressed: _read, child: Text(tr(l, 'smsRead')))),
        const Gap(8),
        Expanded(
          child: OutlinedButton(
            onPressed: s.loadSampleSms,
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            child: Text(tr(l, 'smsSample'), textAlign: TextAlign.center),
          ),
        ),
      ]),
      const Gap(6),
      Text(tr(l, 'smsPrivacy'), style: t.bodySmall),
      for (final e in s.sms) ...[const Gap(10), _SmsCard(state: s, e: e)],
    ]);
  }
}

class _SmsCard extends StatelessWidget {
  const _SmsCard({required this.state, required this.e});
  final AppState state;
  final SmsEntry e;

  @override
  Widget build(BuildContext context) {
    final s = state;
    final l = s.lang;
    final c = context.sc;
    final t = Theme.of(context).textTheme;
    final quiet = e.kind == SmsKind.duplicate || e.status == SmsStatus.ignored;
    Widget status(IconData? icon, String text, Color col) => Row(children: [
          if (icon != null) ...[Icon(icon, size: 16, color: col), const Gap(6)],
          Flexible(child: Text(text, style: t.bodyMedium!.copyWith(color: col, fontWeight: FontWeight.w600))),
        ]);
    final List<Widget> foot;
    if (e.kind == SmsKind.payout) {
      foot = [
        if (e.flagAmount > 0) ...[
          status(Icons.warning_amber_rounded, e.flagReason, c.bad),
          const Gap(8),
          NextStepButton(label: tr(l, 'disputeIt', {'x': inr(e.flagAmount)}), onTap: () => s.disputeSms(e)),
        ],
      ];
    } else if (e.kind == SmsKind.duplicate) {
      foot = [status(Icons.check, tr(l, 'dup'), c.muted)];
    } else if (e.status == SmsStatus.added) {
      foot = [status(Icons.check, tr(l, 'added'), c.good)];
    } else if (e.status == SmsStatus.ignored) {
      foot = [status(null, tr(l, 'ignored'), c.muted)];
    } else {
      foot = [
        if (e.kind == SmsKind.personal) ...[status(Icons.info_outline, tr(l, 'personal'), c.muted), const Gap(8)],
        Row(children: [
          Expanded(child: FilledButton(onPressed: () => s.setSmsStatus(e, SmsStatus.added), style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(42)), child: Text(tr(l, 'add')))),
          const Gap(8),
          Expanded(child: OutlinedButton(onPressed: () => s.setSmsStatus(e, SmsStatus.ignored), child: Text(tr(l, 'ignore')))),
        ]),
      ];
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: quiet ? Colors.transparent : c.surface,
        border: Border.all(color: c.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(e.sender, style: AppFonts.mono(size: 12, color: c.muted)),
        const Gap(6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: c.sunken,
            borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12), bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12), topLeft: Radius.circular(4)),
          ),
          child: Text(e.text, style: AppFonts.mono(size: 12.5, color: c.ink.withValues(alpha: e.status == SmsStatus.ignored ? .55 : 1))),
        ),
        const Gap(8),
        Row(children: [
          _DirDot(dir: e.dir, flag: e.kind == SmsKind.payout),
          const Gap(10),
          Expanded(
            child: Text(e.kind == SmsKind.payout ? tr(l, 'payout') : e.label,
                style: t.bodyMedium!.copyWith(fontWeight: FontWeight.w600)),
          ),
          Text(inr(e.amount), style: AppFonts.mono(size: 15, color: c.ink)),
        ]),
        if (foot.isNotEmpty) ...[const Gap(8), ...foot],
      ]),
    );
  }
}

class _WeekChart extends StatelessWidget {
  const _WeekChart({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final s = state;
    final l = s.lang;
    final c = context.sc;
    final t = Theme.of(context).textTheme;
    final now = DateTime.now();
    final days = [for (var i = 6; i >= 0; i--) now.subtract(Duration(days: i))];
    final values = [for (final d in days) s.history[AppState.dayKey(d)]];
    final maxV = values.whereType<int>().fold<int>(1, max);
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SectionTitle(tr(l, 'week')),
      const Gap(10),
      SizedBox(
        height: 130,
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text(
                    values[i] == null ? '–' : (i == 6 || values[i]! == maxV ? inr(values[i]!) : ''),
                    style: t.bodySmall!.copyWith(fontSize: 11, fontWeight: FontWeight.w700, color: i == 6 ? c.ink : c.muted),
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    softWrap: false,
                  ),
                  const Gap(4),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: values[i] == null ? 0.02 : max(0.04, max(values[i]!, 0) / maxV),
                        child: Container(
                          decoration: BoxDecoration(
                            color: i == 6 ? c.marigold : c.line,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Gap(4),
                  Text(i == 6 ? 'Today' : names[days[i].weekday - 1], style: t.bodySmall!.copyWith(fontSize: 11)),
                ]),
              ),
            ),
        ]),
      ),
      if (s.history.length <= 1) ...[const Gap(6), Text(tr(l, 'weekEmpty'), style: t.bodySmall)],
    ]);
  }
}
