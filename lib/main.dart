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

  static const Color _color = Colors.green;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'PoolDL',
    theme: ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: _color),
    ),
    darkTheme: ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _color,
        brightness: Brightness.dark,
      ),
    ),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const HomePageWidget(),
  );
}
