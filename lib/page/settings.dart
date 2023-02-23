import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rigassat/main.dart';
import 'package:rigassat/page/language.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../components/theme_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(lang.settingsTitle)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            _buildLanguageSelect(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                lang.themeModeTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            _buildThemeSelect(),
            _buildContactDev(),
            _buildRemoveAds(),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelect() {
    return Consumer(
      builder: (context, ref, child) {
        return Column(
          children: [
            GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.75 / 1,
                padding: EdgeInsets.zero,
                children: const <ThemeCard>[
                  ThemeCard(
                    mode: ThemeMode.system,
                    icon: Icons.contrast,
                  ),
                  ThemeCard(mode: ThemeMode.light, icon: Icons.sunny),
                  ThemeCard(mode: ThemeMode.dark, icon: Icons.nightlight_round),
                ]),
          ],
        );
      },
    );
  }

  Widget _buildLanguageSelect() {
    final lang = AppLocalizations.of(context);

    return Card(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _SettingsLine(
                lang.settingsLang,
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).push(
                        PageRouteBuilder(
                            transitionDuration: Duration.zero,
                            pageBuilder: (context, animation1, animation2) =>
                                const LanguagePicker()));
                  },
                ),
              ),
            ],
          ),
        ));
  }
}

String? encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map((MapEntry<String, String> e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}

void _composeMail() {
// #docregion encode-query-parameters
  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: 'martinssvdev@gmail.com',
    query: encodeQueryParameters(<String, String>{
      'subject': '[Rigify] Feedback',
    }),
  );

  launchUrl(emailLaunchUri);
// #enddocregion encode-query-parameters
}

Widget _buildContactDev() {
  return Consumer(builder: (context, ref, snapshot) {
    final lang = AppLocalizations.of(context);
    return Card(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _SettingsLine(
                lang.supportTitle,
                child: SizedBox(
                    height: 50,
                    width: 200,
                    child: Card(
                      elevation: 2,
                      child: Center(
                        child: TextButton(
                          child: const Text(
                            'martinssvdev@gmail.com',
                          ),
                          onPressed: () {
                            _composeMail();
                          },
                        ),
                      ),
                    )),
              ),
            ],
          ),
        ));
  });
}

Widget _buildRemoveAds() {
  return Consumer(builder: (context, ref, child) {
    final lang = AppLocalizations.of(context);
    if (inAppPurchaseControllerProvider == null) {
      return const SizedBox.shrink();
    }

    Widget icon;
    VoidCallback? callback;

    if (inAppPurchaseControllerProvider != null
        ? ref.watch(inAppPurchaseControllerProvider!).maybeMap(
              active: (value) => true,
              orElse: () => false,
            )
        : false) {
      icon = const Text('❤️');
    } else if (inAppPurchaseControllerProvider != null
        ? ref.watch(inAppPurchaseControllerProvider!).maybeMap(
              pending: (value) => true,
              orElse: () => false,
            )
        : false) {
      icon = const CircularProgressIndicator();
    } else {
      icon = const Text(
        '1.79€',
        style: TextStyle(fontWeight: FontWeight.bold),
      );
      callback = () {
        if (inAppPurchaseControllerProvider != null) {
          ref.read(inAppPurchaseControllerProvider!.notifier).buy();
        }
      };
    }
    return Card(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _SettingsLine(
                lang.removeAdsTitle,
                child: SizedBox(
                    height: 50,
                    width: 100,
                    child: Card(elevation: 2, child: Center(child: icon))),
                onSelected: callback,
              ),
            ],
          ),
        ));
  });
}

class _SettingsLine extends StatelessWidget {
  final String title;

  final Widget child;

  final VoidCallback? onSelected;

  const _SettingsLine(this.title, {this.onSelected, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: const TextStyle(
                fontFamily: 'Permanent Marker',
                fontSize: 14,
              )),
          const Spacer(),
          InkResponse(onTap: onSelected, child: child),
        ],
      ),
    );
  }
}
