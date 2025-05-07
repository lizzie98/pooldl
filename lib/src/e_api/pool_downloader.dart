import 'dart:async';
import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:pooldl/src/e_api/e_api.dart';
import 'package:pooldl/src/e_api/json_classes.dart';
import 'package:pooldl/src/utils/string_operations.dart';
import 'package:pooldl/src/utils/watchable_byte_stream.dart';

/// Represents stream of downloading images. If an image is skipped due to the
/// post being deleted, a [DeletedPostException] is streamed. If the image is
/// being downloaded, a [ProgressStream] as well as the target `filePath` is
/// returned.
typedef FileStream =
    Stream<Either<(ProgressStream, String), DeletedPostException>>;

/// Siginifies that a post was deleted and will not be downloaded. This won't be
/// thrown however, but `yielded` via the [FileStream].
class DeletedPostException {
  /// Default file constructor.
  DeletedPostException(this.post, this.fileName, this.parentPool);

  /// The post that was skipped.
  final Post post;

  /// The filename this post would be downloaded to if it wasn't skipped.
  final String fileName;

  /// The pool that contains this post.
  final Pool parentPool;
}

/// Thrown if the download is manually canceled.
class CanceledException {}

/// Downloads all posts of a pool.
class PoolDownloader {
  /// Default constructor.
  PoolDownloader(this._api, this._poolId);

  /// Trys to parse the pool's id from [s] using [tryGetPoolId]. Throws an
  /// exception if that fails.
  factory PoolDownloader.fromString(EApi api, String s) {
    final int? id = tryGetPoolId(s);
    if (id == null) {
      throw Exception('not a valid pool ID: $s');
    }

    return PoolDownloader(api, id);
  }

  final EApi _api;
  final int _poolId;

  Pool? _pool;
  List<Pool>? _poolCandidates;
  bool _canceled = false;

  /// If [s] is just a number, return that number. If [s] appears to be a pool's
  /// URL, return its ID.
  static int? tryGetPoolId(String s) {
    final RegExp pattern = RegExp(r'^(\d+)$|\/pools\/(\d+)');
    final RegExpMatch? match = pattern.firstMatch(s);
    if (match == null) {
      return null;
    }
    return int.parse(match[1] ?? match[2]!);
  }

  /// Download an image to a `filePath`. The file's extension will be taken from
  /// the returned HTTP header `content-type`.
  Future<(ProgressStream, String)> downloadImageToFile(
    Uri url,
    String pathWithoutExt,
  ) async {
    final (String ext, WatchableByteStream stream) = await _api.getImageStream(
      url,
    );
    final file = File('$pathWithoutExt.$ext');
    final IOSink sink = file.openWrite();
    stream.consume((s) => s.pipe(sink));
    return (stream.progressStream, file.path);
  }

  /// If the pool belongs to a series, download all pools of that series.
  FileStream downloadAllCandidates(String path) async* {
    yield* _downloadPools(await getPoolCandidates(), path);
  }

  /// Only download the original pool.
  FileStream downloadSinglePool(String path) async* {
    yield* _downloadPools([await getPool()], path);
  }

  /// Get the pool's metadata from the API. The result is cached, so this
  /// function can safely be called many times.
  Future<Pool> getPool() async {
    _pool ??= await _api.getPool(_poolId);
    return _pool!;
  }

  /// Search the pool's description for links to other pools. Returns a list of
  /// these pools as well as the original pool. The result is cached.
  Future<List<Pool>> getPoolCandidates() async {
    if (_poolCandidates == null) {
      final Pool pool = await getPool();
      final List<int> poolIds = _searchForPools(pool.description);

      if (!poolIds.contains(_poolId)) {
        poolIds.insert(0, _poolId);
      }

      final List<Pool> pools = [];
      for (final poolId in poolIds) {
        if (_canceled) throw CanceledException();
        pools.add(await _api.getPool(poolId));
      }

      for (int i = pools.length - 1; i >= 0; i--) {
        final Pool pool = pools[i];
        for (int j = 0; j < pools.length; j++) {
          if (j == i) {
            continue;
          }
          final Pool otherPool = pools[j];
          // this pool contains every single post of some other pool
          if (otherPool.postIds.every(pool.postIds.contains)) {
            pools.removeAt(i);
            break;
          }
        }
      }

      _poolCandidates = pools;
    }

    return _poolCandidates!;
  }

  /// Cancel the download. Raises an exception in the download stream.
  void cancel() {
    _canceled = true;
  }

  FileStream _downloadPools(List<Pool> pools, String path) async* {
    final List<String> filePrefixes = _getFilePrefixes(pools);

    for (var i = 0; i < pools.length; i++) {
      yield* _downloadPoolToPrefixedPath(pools[i], '$path/${filePrefixes[i]}');
    }
  }

  List<String> _getFilePrefixes(List<Pool> pools) {
    assert(pools.isNotEmpty, "can't download an empty pool");
    final String firstPoolName = ReduceCharacters.truncateAndClean(
      pools.first.name,
    );
    if (pools.length == 1) {
      return ['${firstPoolName}_p'];
    }
    final String secondPoolName = ReduceCharacters.truncateAndClean(
      pools[1].name,
    );
    String prefix = longestCommonPrefix(firstPoolName, secondPoolName);
    prefix = trim(prefix, '_');

    if (prefix.length < 3) {
      prefix = firstPoolName;
    }

    final List<String> prefixes = [];
    final int maxDigits = _decimalDigits(_pool!.postIds.length);
    for (int i = 0; i < pools.length; i++) {
      final String volume = (i + 1).toString().padLeft(maxDigits, '0');
      prefixes.add('${prefix}_v${volume}p');
    }
    return prefixes;
  }

  FileStream _downloadPoolToPrefixedPath(Pool pool, String pathPrefix) async* {
    final int maxDigits = _decimalDigits(pool.postIds.length);
    for (var i = 0; i < pool.postIds.length; i++) {
      if (_canceled) throw CanceledException();
      final String pathSuffix = (i + 1).toString().padLeft(maxDigits, '0');
      final String pathWithoutExt = pathPrefix + pathSuffix;
      final int postId = pool.postIds[i];
      final Post post = await _api.getPost(postId);
      if (post.flags.deleted) {
        final fileName = '$pathWithoutExt.${post.file.ext}';
        yield Right(DeletedPostException(post, fileName, pool));
      } else {
        final Uri imageUrl = post.file.url!;
        yield Left(await downloadImageToFile(imageUrl, pathWithoutExt));
      }
    }
  }

  static List<int> _searchForPools(String description) {
    final poolLink = RegExp(r'\/pools\/(\d+)');
    return poolLink
        .allMatches(description)
        .map((m) => int.parse(m[1]!))
        .toList();
  }

  static int _decimalDigits(int n) {
    var digits = 1;
    int remaining = n;
    while (remaining >= 10) {
      digits++;
      remaining = remaining ~/ 10;
    }
    return digits;
  }
}
