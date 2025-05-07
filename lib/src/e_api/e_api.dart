import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pooldl/src/e_api/json_classes.dart';
import 'package:pooldl/src/utils/watchable_byte_stream.dart';

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
    final pool = json.decode(response.body) as Map<String, dynamic>;
    return Pool.fromJson(pool);
  }

  /// Get post metadata without any error handling.
  Future<Post> getPost(int id) async {
    final Uri url = _post(id);
    final http.Response response = await _client.get(url);
    final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
    final postJson = jsonResponse['post'] as Map<String, dynamic>;
    return Post.fromJson(postJson);
  }

  /// Get an image as a byte stream. Also returns the file's extension, taken
  /// from the 'content-type' header.
  Future<(String, WatchableByteStream)> getImageStream(Uri url) async {
    final request = http.Request('GET', url);
    final http.StreamedResponse response = await _client.send(request);
    final String? contentType = response.headers['content-type'];
    final String? contentLength = response.headers['content-length'];

    int byteCount = 0x7FFFFFFFFFFFFFFF;
    if (contentLength != null) {
      final int? length = int.tryParse(contentLength);
      if (length != null) {
        byteCount = length;
      }
    }

    if (contentType == null || !contentType.startsWith('image/')) {
      throw Exception("didn't return an image");
    }

    final String ext = contentType.substring('image/'.length);
    final stream = WatchableByteStream(byteCount, response.stream);
    return (ext, stream);
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
