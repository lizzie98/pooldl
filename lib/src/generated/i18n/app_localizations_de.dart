// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get yes => 'Ja';

  @override
  String get appBarText => 'Pool Downloader';

  @override
  String get cancelDownloadButtonToolTip => 'Abbrechen';

  @override
  String get downloadButtonToolTip => 'Download starten';

  @override
  String skippedDeletedPostAmount(int amount) {
    return 'Übersprungen: $amount';
  }

  @override
  String get skippedDeletedPost => 'Ein gelöscher Post wurde übersprungen.';

  @override
  String get individualFileDownloadProgressBarLabel => 'Downloadfortschritt der aktuellen Datei.';

  @override
  String get totalDownloadProgressBarLabel => 'Insgesamter Fortschritt.';

  @override
  String get multiPoolDownload => 'Multi Pool Download';

  @override
  String get multiPoolDownloadDescription => 'Dieser Pool scheint Teil einer Serie zu sein. Möchtest Du die anderen Teile auch herunterladen?';

  @override
  String get noOnlyThisPool => 'Nein, nur diesen Pool';
}
