import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rigassat/models/locale/locale_translate_name.dart';
import '../models/locale/locale_providers.dart';
import '../models/locale/locale_state.dart';
import '../theme/theme_mode_state.dart';

class LanguagePicker extends ConsumerWidget {
  const LanguagePicker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Locale> _supportedLocales = ref.read(supportedLocalesProvider);

    return Material(
      child: Scaffold(
        appBar: AppBar(),
        body: ListView.builder(
            itemCount: _supportedLocales.length,
            itemBuilder: (context, i) {
              return _SwitchListTileMenuItem(
                title: translateLocaleName(locale: _supportedLocales[i]),
                subtitle: translateLocaleName(locale: _supportedLocales[i]),
                locale: _supportedLocales[i],
                onTap: () {
                  ref
                      .read(localeStateProvider.notifier)
                      .setLocale(_supportedLocales[i]);
                },
              );
            }),
      ),
    );
  }
}

class _SwitchListTileMenuItem extends ConsumerWidget {
  const _SwitchListTileMenuItem({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.locale,
    required this.onTap,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final Locale locale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Locale _currentLocale = ref.watch(localeProvider);
    bool isSelected(BuildContext context) => locale == _currentLocale;
    final ThemeModeState currentTheme = ref.watch(themeProvider);

    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, top: 5),
      decoration: BoxDecoration(
        border: isSelected(context)
            ? Border.all(
                color: currentTheme.themeMode == "dark"
                    ? Colors.white
                    : Colors.black)
            : null,
      ),
      child: ListTile(
        dense: true,
        title: Text(
          title,
        ),
        subtitle: Text(
          subtitle,
        ),
        onTap: onTap,
      ),
    );
  }
}
