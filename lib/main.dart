import 'package:flutter/material.dart';
import 'package:pooldl/src/generated/i18n/app_localizations.dart';
import 'package:pooldl/src/widgets/home_page_widget.dart';

void main() {
  runApp(const App());
}

/// The app.
class App extends StatelessWidget {
  /// Default constructor.
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'PoolDL',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
    ),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const HomePageWidget(),
  );
}
