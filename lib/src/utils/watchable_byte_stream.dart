import 'dart:async';

/// Streams how many bytes of this stream were processed as `processedAmount`,
/// `totalAmount`, and `bytes/second`.
typedef ProgressStream = Stream<(int, int, double)>;

/// Returns a [ProgressStream] for a given byte stream.
class WatchableByteStream {
  /// The expected number of bytes for this stream as well as the source stream.
  WatchableByteStream(this._totalByteCount, this._source);
  final int _totalByteCount;
  final Stream<List<int>> _source;
  final StreamController<(int, int, double)> _progressCtrl =
      StreamController<(int, int, double)>();
  int _currentByteCount = 0;

  int? _firstBytesArrived;

  /// Gets the progress stream for this stream.
  ProgressStream get progressStream => _progressCtrl.stream;

  /// Passes the source stream to the callback. The callback should return a
  /// [Future] that completes once the stream is fully consumed. Exceptions in
  /// the [Future] are caught and passed to the progress stream.
  void consume(Future Function(Stream<List<int>>) consumer) {
    unawaited(
      consumer(_consumeSourceStream()).catchError(_progressCtrl.addError),
    );
  }

  Stream<List<int>> _consumeSourceStream() async* {
    await for (final List<int> bytes in _source) {
      _currentByteCount += bytes.length;
      double speed = 0;
      if (_firstBytesArrived == null) {
        _firstBytesArrived = DateTime.now().millisecondsSinceEpoch;
      } else {
        final int passed =
            DateTime.now().millisecondsSinceEpoch - _firstBytesArrived!;
        speed = _currentByteCount / (passed / 1000);
      }
      yield bytes;
      _progressCtrl.add((_currentByteCount, _totalByteCount, speed));
    }
    await _progressCtrl.close();
  }
}
