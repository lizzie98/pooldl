// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get yes => 'Yes';

  @override
  String get appBarText => 'Pool Downloader';

  @override
  String get cancelDownloadButtonToolTip => 'Cancel download';

  @override
  String get downloadButtonToolTip => 'Download';

  @override
  String skippedDeletedPostAmount(int amount) {
    return 'Skipped: $amount';
  }

  @override
  String get skippedDeletedPost => 'A deleted post was skipped.';

  @override
  String get individualFileDownloadProgressBarLabel => 'Progress of the current file.';

  @override
  String get totalDownloadProgressBarLabel => 'Total download progress.';

  @override
  String get multiPoolDownload => 'Multi Pool Download';

  @override
  String get multiPoolDownloadDescription => 'This pool seems to be part of a series. Do you want to download the other parts as well?';

  @override
  String get noOnlyThisPool => 'No, only this pool';
}
