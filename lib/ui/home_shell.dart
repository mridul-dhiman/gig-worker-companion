import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import 'onboarding_screen.dart';
import 'tabs/documents_tab.dart';
import 'tabs/earnings_tab.dart';
import 'tabs/grievance_tab.dart';
import 'tabs/safety_tab.dart';
import 'tabs/welfare_tab.dart';
import 'theme.dart';
import 'widgets.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.state});
  final AppState state;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  AppState get s => widget.state;

  @override
  void initState() {
    super.initState();
    s.addListener(_showToast);
  }

  @override
  void dispose() {
    s.removeListener(_showToast);
    super.dispose();
  }

  void _showToast() {
    final msg = s.takeToast();
    if (msg == null || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  static const _icons = [
    Icons.account_balance_wallet_outlined,
    Icons.campaign_outlined,
    Icons.favorite_border,
    Icons.description_outlined,
    Icons.health_and_safety_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final l = s.lang;
    return Scaffold(
      body: Column(children: [
        _TopBar(state: s),
        Expanded(
          child: IndexedStack(index: s.tab, children: [
            EarningsTab(state: s),
            GrievanceTab(state: s),
            WelfareTab(state: s),
            DocumentsTab(state: s),
            SafetyTab(state: s),
          ]),
        ),
      ]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: s.tab,
        onDestinationSelected: s.goTab,
        height: 68,
        destinations: [
          for (var i = 0; i < 5; i++)
            NavigationDestination(icon: Icon(_icons[i]), label: tabNames(l)[i]),
        ],
        surfaceTintColor: c.surface,
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final c = context.sc;
    final p = state.profile!;
    return Container(
      color: c.bar,
      padding: EdgeInsets.fromLTRB(16, 12 + MediaQuery.paddingOf(context).top, 12, 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Row(children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Wordmark(color: c.onBar),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<AppLang>(
              tooltip: 'Language',
              initialValue: state.lang,
              onSelected: state.setLang,
              itemBuilder: (_) => [
                for (final lang in AppLang.values)
                  PopupMenuItem(value: lang, child: Text(lang.native, style: AppFonts.body(lang, color: c.ink))),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: c.onBar.withValues(alpha: .1), borderRadius: BorderRadius.circular(99)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.language, size: 18, color: c.onBar),
                  const SizedBox(width: 6),
                  Text(state.lang.native, style: AppFonts.body(state.lang, size: 14, weight: FontWeight.w600, color: c.onBar)),
                ]),
              ),
            ),
            const SizedBox(width: 8),
            Semantics(
              button: true,
              label: tr(state.lang, 'profile'),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _openProfile(context),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: c.marigold,
                  child: Text(p.initials,
                      style: AppFonts.body(state.lang, size: 14, weight: FontWeight.w800, color: c.onMarigold)),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _openProfile(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: context.sc.surface,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (_) => ProfileSheet(state: state),
    );
  }
}

class ProfileSheet extends StatefulWidget {
  const ProfileSheet({super.key, required this.state});
  final AppState state;

  @override
  State<ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<ProfileSheet> {
  late final keyCtrl = TextEditingController(text: widget.state.ai.gemini.apiKey);

  @override
  void dispose() {
    keyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final l = s.lang;
    final p = s.profile!;
    final c = context.sc;
    final t = Theme.of(context).textTheme;
    Widget fact(String k, String v) => Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.line))),
          child: Row(children: [
            Text(k, style: t.bodyMedium!.copyWith(color: c.muted)),
            const Spacer(),
            Text(v, style: t.bodyMedium!.copyWith(fontWeight: FontWeight.w600)),
          ]),
        );
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: c.marigold,
            child: Text(p.initials, style: AppFonts.display(l, size: 20, weight: FontWeight.w800, color: c.onMarigold)),
          ),
          const Gap(14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.name, style: t.titleLarge),
              Text(s.prof.title(l), style: t.bodySmall!.copyWith(fontSize: 14)),
            ]),
          ),
        ]),
        const Gap(12),
        fact(tr(l, 'obPhone'), '+91 ${p.maskedPhone}'),
        fact(tr(l, 'obAge'), '${p.age}'),
        fact(tr(l, 'obState'), p.state),
        const Gap(16),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (ctx) => OnboardingScreen(state: s, editing: true, onCancel: () => Navigator.of(ctx).pop()),
            ));
          },
          icon: Icon(professionIcon(p.professionId)),
          label: Text(tr(l, 'changeWork')),
        ),
        const Gap(20),
        FieldLabel(tr(l, 'apiKey')),
        Row(children: [
          Expanded(
            child: TextField(
              controller: keyCtrl,
              obscureText: true,
              autocorrect: false,
              decoration: const InputDecoration(hintText: 'AIza…'),
            ),
          ),
          const Gap(8),
          OutlinedButton(
            onPressed: () {
              s.setApiKey(keyCtrl.text);
              setState(() {});
            },
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 50)),
            child: Text(tr(l, 'save')),
          ),
        ]),
        const Gap(6),
        Text(tr(l, 'apiKeySub'), style: t.bodySmall),
        const Gap(8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: s.ai.gemini.simulateOffline,
          activeThumbColor: c.marigold,
          onChanged: (v) {
            s.setSimulateOffline(v);
            setState(() {});
          },
          title: Text(tr(l, 'simulate'), style: t.bodyLarge),
          subtitle: SourceBadge(live: s.aiLive, lang: l),
        ),
        const Gap(8),
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pop();
            s.logout();
          },
          style: OutlinedButton.styleFrom(foregroundColor: c.bad, minimumSize: const Size.fromHeight(50)),
          child: Text(tr(l, 'logout')),
        ),
      ]),
    );
  }
}

/// Scrollable tab body with the greeting row and a width cap for desktop.
class TabBody extends StatelessWidget {
  const TabBody({super.key, required this.state, required this.sourceKey, required this.children});
  final AppState state;
  final String? sourceKey;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final s = state;
    final p = s.profile!;
    final t = Theme.of(context).textTheme;
    final src = sourceKey == null ? null : s.sources[sourceKey];
    final live = src == null ? s.aiLive : src == Source.gemini;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${tr(s.lang, 'hi')}, ${p.firstName}', style: t.titleLarge!.copyWith(fontSize: 22)),
                    Text('${s.prof.title(s.lang)} · ${p.state}', style: t.bodySmall!.copyWith(fontSize: 14)),
                  ]),
                ),
                if (sourceKey != null) SourceBadge(live: live, lang: s.lang),
              ]),
              const Gap(18),
              for (final (i, w) in children.indexed) ...[if (i > 0) const Gap(18), w],
            ]),
          ),
        ),
      ],
    );
  }
}
