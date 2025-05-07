import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pooldl/src/e_api/json_classes.dart';
import 'package:pooldl/src/utils/watchable_byte_stream.dart';

/// HTTP response did not return 200.
class HttpException implements Exception {
  /// Default constructor.
  HttpException(this.statusCode, this.reason);

  /// The returned status code.
  int statusCode;

  /// The given reason.
  String? reason;

  @override
  String toString() => 'HttpException: $statusCode $reason';
}

/// API wrapper. Requests to the API are supplied with a user-agent header,
/// which includes the appname, version, and author.
class EApi {
  EApi._(http.BaseClient client) : _client = client;
  static EApi? _instance;

  final http.BaseClient _client;

  /// Get an instance of this API wrapper.
  static Future<EApi> getInstance() async {
    if (_instance == null) {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();

      final String appName = packageInfo.appName;
      final String version = packageInfo.version;

      final String userAgent = '$appName/$version (by lizzie98)';

      final client = _UserAgentClient(userAgent, http.Client());

      _instance = EApi._(client);
    }

    return _instance!;
  }

  /// Get pool metadata, without any error handling.
  Future<Pool> getPool(int id) async {
    final Uri url = _pool(id);
    final http.Response response = await _client.get(url);
    _throwIfUnsuccessful(response);
    final pool = json.decode(response.body) as Map<String, dynamic>;
    return Pool.fromJson(pool);
  }

  /// Get post metadata without any error handling.
  Future<Post> getPost(int id) async {
    final Uri url = _post(id);
    final http.Response response = await _client.get(url);
    _throwIfUnsuccessful(response);
    final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
    final postJson = jsonResponse['post'] as Map<String, dynamic>;
    return Post.fromJson(postJson);
  }

  /// Get an image/video as a byte stream. Also returns the file's extension,
  /// taken from the 'content-type' header.
  Future<(String, WatchableByteStream)> getMediaStream(Uri url) async {
    final request = http.Request('GET', url);
    final http.StreamedResponse response = await _client.send(request);
    _throwIfUnsuccessful(response);
    final String? contentType = response.headers['content-type'];
    final String? contentLength = response.headers['content-length'];

    int byteCount = 0x7FFFFFFFFFFFFFFF;
    if (contentLength != null) {
      final int? length = int.tryParse(contentLength);
      if (length != null) {
        byteCount = length;
      }
    }

    if (contentType == null) {
      throw Exception('unrecognized file type');
    }
    final String? ext = _tryGetMediaFileType(contentType);
    if (ext == null) {
      throw Exception('invalid content-type');
    }

    final stream = WatchableByteStream(byteCount, response.stream);
    return (ext, stream);
  }

  static void _throwIfUnsuccessful(http.BaseResponse response) {
    if (response.statusCode != 200) {
      throw HttpException(response.statusCode, response.reasonPhrase);
    }
  }

  static String? _tryGetMediaFileType(String contentType) {
    if (contentType.startsWith('image/')) {
      return contentType.substring('image/'.length);
    }
    if (contentType.startsWith('video/')) {
      return contentType.substring('video/'.length);
    }
    return null;
  }
}

class _UserAgentClient extends http.BaseClient {
  _UserAgentClient(this.userAgent, this._inner);
  final String userAgent;
  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['user-agent'] = userAgent;
    return _inner.send(request);
  }
}

final Uri _baseUrl = Uri.https('e621.net');

Uri _pool(int id) => _baseUrl.resolve('/pools/$id.json');

Uri _post(int id) => _baseUrl.resolve('/posts/$id.json');
