import 'dart:io';
import 'dart:math';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../models/track.dart';

enum PlaybackMode { normal, shuffle, repeatOne }

class AudioPlayerService extends ChangeNotifier {
  AudioPlayerService() {
    _bindPlayer();
  }

  AudioPlayer _player = AudioPlayer();
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  void _bindPlayer() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions
      ..clear()
      ..add(_player.playerStateStream.listen((state) {
      if (!_changingSource && state.processingState == ProcessingState.completed && _isAtTrackEnd) {
        playNext(auto: true);
      } else {
        notifyListeners();
      }
    }))
      ..add(_player.positionStream.listen((_) => notifyListeners()))
      ..add(_player.durationStream.listen((_) => notifyListeners()));
  }

  final Random _random = Random();
  final List<Track> _queue = [];
  final Set<String> _downloadedIds = {};

  Track? _current;
  PlaybackMode _mode = PlaybackMode.normal;
  String? _downloadMessage;
  bool _isDownloading = false;
  bool _changingSource = false;

  Track? get current => _current;
  List<Track> get queue => List.unmodifiable(_queue);
  PlaybackMode get mode => _mode;
  bool get isPlaying => _player.playing;
  bool get isDownloading => _isDownloading;
  String? get downloadMessage => _downloadMessage;
  Duration get position => _player.position;
  Duration get duration => _player.duration ?? Duration(milliseconds: _current?.duration ?? 0);
  bool get hasNext => _queue.isNotEmpty || _mode == PlaybackMode.repeatOne;
  bool get _isAtTrackEnd {
    final total = duration.inMilliseconds;
    if (total <= 0) return false;
    return position.inMilliseconds >= total - 1200;
  }

  Future<void> play(Track track, {List<Track>? contextQueue}) async {
    if (contextQueue != null) {
      _queue
        ..clear()
        ..addAll(contextQueue.where((item) => item.id != track.id));
    }

    final url = track.streamUrl?.isNotEmpty == true ? track.streamUrl! : '';
    if (url.isEmpty) {
      throw Exception('This track does not have a playable stream URL.');
    }

    final uri = Uri.parse(url);
    final playableUri = uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        'trackId': track.id,
        't': DateTime.now().millisecondsSinceEpoch.toString(),
      },
    );

    _changingSource = true;
    try {
      await _player.dispose();
      _player = AudioPlayer();
      _bindPlayer();

      _current = track;
      notifyListeners();
      await _player.setAudioSource(AudioSource.uri(playableUri), preload: true);
      await _player.play();
    } finally {
      _changingSource = false;
      notifyListeners();
    }
  }

  Future<void> playAll(List<Track> tracks, {bool shuffle = false}) async {
    if (tracks.isEmpty) return;
    final playable = List<Track>.from(tracks);
    if (shuffle) playable.shuffle(_random);
    _queue
      ..clear()
      ..addAll(playable.skip(1));
    _mode = shuffle ? PlaybackMode.shuffle : PlaybackMode.normal;
    notifyListeners();
    await play(playable.first);
  }

  Future<void> toggle() async {
    if (isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    final wasPlaying = isPlaying;
    await _player.seek(position);
    if (wasPlaying && !_player.playing) {
      await _player.play();
    }
    notifyListeners();
  }

  void enqueue(Track track) {
    _queue.add(track);
    notifyListeners();
  }

  void enqueueAll(List<Track> tracks) {
    _queue.addAll(tracks);
    notifyListeners();
  }

  void cycleMode() {
    _mode = switch (_mode) {
      PlaybackMode.normal => PlaybackMode.shuffle,
      PlaybackMode.shuffle => PlaybackMode.repeatOne,
      PlaybackMode.repeatOne => PlaybackMode.normal,
    };
    notifyListeners();
  }

  Future<void> playNext({bool auto = false}) async {
    if (_mode == PlaybackMode.repeatOne && _current != null) {
      await play(_current!);
      return;
    }

    if (_queue.isEmpty) {
      if (auto) {
        await _player.pause();
        await _player.seek(Duration.zero);
        notifyListeners();
      }
      return;
    }

    final nextIndex = _mode == PlaybackMode.shuffle && _queue.length > 1 ? _random.nextInt(_queue.length) : 0;
    final next = _queue.removeAt(nextIndex);
    notifyListeners();
    await play(next);
  }

  Future<void> downloadCurrent() async {
    final track = _current;
    final url = track?.streamUrl ?? '';
    if (track == null || url.isEmpty) return;

    if (url.contains('/api/stream/youtube/')) {
      _downloadMessage = 'Downloads are available only for direct permitted audio files.';
      notifyListeners();
      return;
    }

    _isDownloading = true;
    _downloadMessage = 'Downloading ${track.title}...';
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Download failed with HTTP ${response.statusCode}');
      }

      final dir = await getApplicationDocumentsDirectory();
      final fileName = '${_safeFileName(track.title)}-${track.id}.audio';
      final file = File('${dir.path}${Platform.pathSeparator}$fileName');
      await file.writeAsBytes(response.bodyBytes);
      _downloadedIds.add(track.id);
      _downloadMessage = 'Saved for permitted local playback: $fileName';
    } catch (error) {
      _downloadMessage = error.toString();
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  bool isDownloaded(Track track) => _downloadedIds.contains(track.id);

  String _safeFileName(String value) {
    return value.replaceAll(RegExp(r'[^\w\s.-]+'), '').replaceAll(RegExp(r'\s+'), '_').take(48);
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _player.dispose();
    super.dispose();
  }
}

extension on String {
  String take(int max) => length <= max ? this : substring(0, max);
}
