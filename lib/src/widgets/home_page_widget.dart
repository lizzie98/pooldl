import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pooldl/src/e_api/e_api.dart';
import 'package:pooldl/src/e_api/json_classes.dart';
import 'package:pooldl/src/e_api/pool_downloader.dart';
import 'package:pooldl/src/generated/i18n/app_localizations.dart';
import 'package:pooldl/src/utils/string_operations.dart';
import 'package:pooldl/src/utils/watchable_byte_stream.dart';
import 'package:pooldl/src/widgets/multi_pool_alert.dart';

const String _bullet = '\u2022';

/// The first screen shown when opening the app.
class HomePageWidget extends StatefulWidget {
  /// Default constructor.
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  PoolDownloader? _downloader;

  int? _poolId;
  String _poolName = '';
  String _downloadSpeed = '-- KB/s';
  String _imagesDownloaded = '-- / --';
  String _downloadingImage = '';
  String _errorMessage = '';
  double _perFileProgress = 0;
  double _totalProgress = 0;
  int _deletedPostAmount = 0;

  static String _downloadSpeedAndFileText(double speed, String fileName) {
    final String kbps = (speed / 1_000).toStringAsFixed(2);
    return '$kbps KB/s $_bullet $fileName';
  }

  static String _imagesDownloadedAndSkippedText(
    BuildContext context,
    int downloaded,
    int total,
    int skipped,
  ) {
    var s = '$downloaded / $total';
    if (skipped > 0) {
      s += ' $_bullet ';
      s += AppLocalizations.of(context)!.skippedDeletedPostAmount(skipped);
    }
    return s;
  }

  static Future<bool> _requestStoragePermissions() async {
    try {
      final PermissionStatus storagePerm = await Permission.storage.request();
      if (storagePerm == PermissionStatus.granted) {
        return true;
      }

      final PermissionStatus externalStoragePerm =
          await Permission.manageExternalStorage.request();
      return externalStoragePerm == PermissionStatus.granted;
    } on Exception {
      return true;
    }
  }

  void _onPoolIdTextChanged(String text) {
    setState(() {
      _poolId = PoolDownloader.tryGetPoolId(text);
    });
  }

  Future<void> _startDownload() async {
    _reset();

    try {
      if (!await _requestStoragePermissions()) {
        _showError('App needs storage permissions for saving the images.');
        return;
      }

      final downloader = PoolDownloader(await EApi.getInstance(), _poolId!);
      setState(() {
        _downloader = downloader;
      });
      final Pool pool = await downloader.getPool();
      setState(() => _poolName = pool.name.replaceAll('_', ' '));
      final Future<String?> pathTask = FilePicker.platform.getDirectoryPath();
      final List<Pool> poolCandidates = await downloader.getPoolCandidates();
      final Iterable<String> poolNames = poolCandidates.map((p) => p.name);
      final String? path = await pathTask;

      if (path == null) {
        _reset();
        return;
      }

      if (!mounted) {
        return;
      }

      bool downloadAll = false;
      if (poolCandidates.length > 1) {
        downloadAll =
            (await showDialog<bool>(
              context: context,
              builder: MultiPoolAlert(poolNames).build,
            ))!;
      }

      int postCount;
      FileStream fileStream;

      if (downloadAll) {
        postCount = poolCandidates
            .map((p) => p.postIds.length)
            .reduce((a, b) => a + b);
        fileStream = downloader.downloadAllCandidates(path);
      } else {
        postCount = (await downloader.getPool()).postIds.length;
        fileStream = downloader.downloadSinglePool(path);
      }

      int i = 0;
      await for (final fileStatus in fileStream) {
        String fileName = fileStatus.fold((a) => a.$2, (b) => b.fileName);
        fileName = splitRight(fileName, '/').$2;
        setState(() {
          _imagesDownloaded = _imagesDownloadedAndSkippedText(
            context,
            i,
            postCount,
            _deletedPostAmount,
          );
          _downloadingImage = fileName;
        });
        if (fileStatus.isLeft) {
          final ProgressStream progressStream = fileStatus.left.$1;
          await for (final (downloaded, total, speed) in progressStream) {
            setState(() {
              _perFileProgress = downloaded / total;
              _totalProgress = (i + _perFileProgress) / postCount;
              _downloadSpeed = _downloadSpeedAndFileText(speed, fileName);
            });
          }
        } else {
          _alertSkippedDeletedPost();
        }
        i++;
      }
      setState(() {
        _downloader = null;
        _imagesDownloaded = _imagesDownloadedAndSkippedText(
          context,
          i,
          postCount,
          _deletedPostAmount,
        );
        _downloadSpeed = '-- KB/s';
        _downloadingImage = '';
      });
    } on CanceledException {
      _reset();
    } on Exception catch (e) {
      _showError(e.toString());
    }
  }

  void _cancelDownload() {
    _downloader?.cancel();
    setState(() {
      _downloader = null;
    });
  }

  void _alertSkippedDeletedPost() {
    setState(() {
      _deletedPostAmount++;
    });
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        content: Text(
          AppLocalizations.of(context)!.skippedDeletedPost,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Theme.of(context).colorScheme.onInverseSurface,
          ),
        ),
      ),
    );
  }

  void _showError(String message) {
    setState(() {
      _downloader = null;
      _downloadSpeed =
          _downloadingImage == ''
              ? '-- KB/s'
              : '-- KB/s $_bullet $_downloadingImage';
      _errorMessage = message;
    });
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.error,
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Theme.of(context).colorScheme.onError,
          ),
        ),
      ),
    );
  }

  void _reset() {
    setState(() {
      _downloader = null;
      _poolName = '';
      _downloadSpeed = '-- KB/s';
      _imagesDownloaded = '-- / --';
      _downloadingImage = '';
      _errorMessage = '';
      _perFileProgress = 0;
      _totalProgress = 0;
      _deletedPostAmount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    const double iconSize = 25;
    const double iconMargin = 4;

    final enableDownload = _poolId != null;

    final Color primary = Theme.of(context).colorScheme.primary;
    final Color onPrimary = Theme.of(context).colorScheme.onPrimary;

    final int disabled = (255 * .6).toInt();
    final Color primaryDisabled = primary.withAlpha(disabled);
    final Color onPrimaryDisabled = onPrimary.withAlpha(disabled);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        title: Text(
          AppLocalizations.of(context)!.appBarText,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pool ID TextField
            const SizedBox(height: 30),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: primary),
                ),
                labelText: 'Pool ID',
                labelStyle: Theme.of(
                  context,
                ).textTheme.labelMedium!.copyWith(color: primary),
              ),
              style: Theme.of(context).textTheme.bodyMedium,
              onChanged: _onPoolIdTextChanged,
            ),
            const SizedBox(height: 25),

            // Current pool name
            Text(
              _poolName,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
            const SizedBox(height: 25),

            // Download speed/progress of the current file
            Row(
              children: [
                const SizedBox(width: iconSize + iconMargin),
                Flexible(
                  child: Text(
                    _downloadSpeed,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge!.copyWith(fontFamily: 'mono'),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.arrow_downward, color: primary, size: iconSize),
                const SizedBox(width: iconMargin),
                Expanded(
                  child: LinearProgressIndicator(
                    value: _perFileProgress,
                    color: primary,
                    semanticsLabel:
                        AppLocalizations.of(
                          context,
                        )!.individualFileDownloadProgressBarLabel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Total downlad progress
            Row(
              children: [
                const SizedBox(width: iconSize + iconMargin),
                Flexible(
                  child: Text(
                    _imagesDownloaded,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge!.copyWith(fontFamily: 'mono'),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Icon(Icons.image_outlined, color: primary, size: iconSize),
                const SizedBox(width: iconMargin),
                Expanded(
                  child: LinearProgressIndicator(
                    value: _totalProgress,
                    color: primary,
                    semanticsLabel:
                        AppLocalizations.of(
                          context,
                        )!.totalDownloadProgressBarLabel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // error message
            if (_errorMessage != '')
              Text(
                _errorMessage,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            bottom: 10,
            right: 10,
            child: Column(
              children: [
                if (_downloader != null)
                  FloatingActionButton(
                    onPressed: _cancelDownload,
                    tooltip:
                        AppLocalizations.of(
                          context,
                        )!.cancelDownloadButtonToolTip,
                    backgroundColor: Theme.of(context).colorScheme.error,
                    child: Icon(
                      Icons.cancel_outlined,
                      color: Theme.of(context).colorScheme.onError,
                    ),
                  ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  // disable this button if poolId was not yet set
                  onPressed: enableDownload ? _startDownload : null,
                  backgroundColor: enableDownload ? primary : primaryDisabled,
                  disabledElevation: 0,
                  tooltip: AppLocalizations.of(context)!.downloadButtonToolTip,
                  child: Icon(
                    Icons.download,
                    color: enableDownload ? onPrimary : onPrimaryDisabled,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
