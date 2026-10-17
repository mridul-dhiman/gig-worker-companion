import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/models.dart';
import 'theme.dart';

/// Small uppercase label above inputs and result blocks.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text.toUpperCase(),
          style: Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w700, letterSpacing: .6),
        ),
      );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: Text(text, style: Theme.of(context).textTheme.titleMedium)),
          ?trailing,
        ],
      );
}

/// Marigold "Next Step" button that hands context to another tab.
class NextStepButton extends StatelessWidget {
  const NextStepButton({super.key, required this.label, this.sub, required this.onTap, this.quiet = false});
  final String label;
  final String? sub;
  final VoidCallback onTap;
  final bool quiet;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final fg = quiet ? c.ink : c.onMarigold;
    return Material(
      color: quiet ? c.surface : c.marigold,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: quiet ? BorderSide(color: c.line, width: 1.5) : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: Theme.of(context).textTheme.labelLarge!.copyWith(color: fg, height: 1.25)),
                if (sub != null)
                  Text(sub!, style: Theme.of(context).textTheme.bodySmall!.copyWith(color: fg.withValues(alpha: .8))),
              ]),
            ),
            const SizedBox(width: 12),
            Icon(Icons.arrow_forward, color: fg),
          ]),
        ),
      ),
    );
  }
}

class SourceBadge extends StatelessWidget {
  const SourceBadge({super.key, required this.live, required this.lang});
  final bool live;
  final AppLang lang;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final fg = live ? c.good : c.hold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: live ? c.goodBg : c.holdBg, borderRadius: BorderRadius.circular(99)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 7, height: 7, decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(tr(lang, live ? 'live' : 'off'),
            style: Theme.of(context).textTheme.bodySmall!.copyWith(color: fg, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status, required this.lang});
  final SchemeStatus status;
  final AppLang lang;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final (fg, bg, key) = switch (status) {
      SchemeStatus.eligible => (c.good, c.goodBg, 'eligible'),
      SchemeStatus.check => (c.hold, c.holdBg, 'check'),
      SchemeStatus.notEligible => (c.bad, c.badBg, 'notElig'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
      child: Text(tr(lang, key),
          style: Theme.of(context).textTheme.bodySmall!.copyWith(color: fg, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}

/// Shown while an AI call runs, including the retry count during backoff.
class Thinking extends StatelessWidget {
  const Thinking({super.key, required this.lang, required this.retryN, this.label});
  final AppLang lang;
  final int retryN;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(children: [
          SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5, color: c.marigold)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              retryN > 1 ? tr(lang, 'retry', {'n': retryN}) : (label ?? tr(lang, 'thinking')),
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: c.muted),
            ),
          ),
        ]),
      ),
    );
  }
}

class PlainBox extends StatelessWidget {
  const PlainBox(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: context.sc.sunken, borderRadius: BorderRadius.circular(14)),
        child: Text(text, style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 17)),
      );
}

/// Numbered steps. The numbers matter: these are done in order.
class StepList extends StatelessWidget {
  const StepList(this.steps, {super.key, required this.lang});
  final List<String> steps;
  final AppLang lang;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Column(children: [
      for (var i = 0; i < steps.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: c.marigold, shape: BoxShape.circle),
              child: Text('${i + 1}', style: AppFonts.display(lang, size: 17, weight: FontWeight.w800, color: c.onMarigold)),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(steps[i], style: Theme.of(context).textTheme.bodyLarge),
            )),
          ]),
        ),
    ]);
  }
}

/// Two-column list: term on the left, plain meaning on the right.
class TermList extends StatelessWidget {
  const TermList(this.rows, {super.key});
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Column(children: [
      for (final (a, b) in rows)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.line))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 2, child: Text(a, style: AppFonts.mono(size: 13, color: c.muted))),
            const SizedBox(width: 12),
            Expanded(flex: 3, child: Text(b, style: Theme.of(context).textTheme.bodyMedium)),
          ]),
        ),
    ]);
  }
}

/// A wrap of selectable chips used for recipients, hazards and quick labels.
class ChoiceChips<T> extends StatelessWidget {
  const ChoiceChips({super.key, required this.values, required this.selected, required this.label, required this.onSelect, this.danger = false});
  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onSelect;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    return Wrap(spacing: 8, runSpacing: 8, children: [
      for (final v in values)
        Builder(builder: (context) {
          final on = v == selected;
          final bg = on ? (danger ? c.badBg : c.ink) : c.surface;
          final fg = on ? (danger ? c.bad : c.paper) : c.ink;
          return Semantics(
            selected: on,
            button: true,
            child: Material(
              color: bg,
              shape: StadiumBorder(side: BorderSide(color: on ? (danger ? c.bad : c.ink) : c.line, width: 1.5)),
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: () => onSelect(v),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  child: Text(label(v),
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: fg, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          );
        }),
    ]);
  }
}

class Gap extends StatelessWidget {
  const Gap([this.size = 16, Key? key]) : super(key: key);
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(height: size, width: size);
}
