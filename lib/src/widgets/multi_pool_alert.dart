import 'package:flutter/material.dart';
import 'package:pooldl/src/generated/i18n/app_localizations.dart';

/// Alert dialog shown to the user: the pool belongs to a series, do you want to
/// download all belonging pools yes/no.
class MultiPoolAlert extends StatelessWidget {
  /// List of pool names that will be downloaded if accepted.
  const MultiPoolAlert(this._poolNames, {super.key});
  final Iterable<String> _poolNames;

  @override
  Widget build(BuildContext context) {
    const String bullet = '\u2022';
    final String pools = _poolNames
        .map((s) => '$bullet ${s.replaceAll('_', ' ')}')
        .join('\n');

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.multiPoolDownload),
      titleTextStyle: Theme.of(context).textTheme.titleLarge,
      contentTextStyle: Theme.of(context).textTheme.bodyMedium,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.multiPoolDownloadDescription),
          const SizedBox(height: 5),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                pools,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(height: 1.8),
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          style: Theme.of(context).textButtonTheme.style,
          child: Text(AppLocalizations.of(context)!.noOnlyThisPool),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: Theme.of(context).textButtonTheme.style,
          child: Text(AppLocalizations.of(context)!.yes),
        ),
      ],
    );
  }
}
