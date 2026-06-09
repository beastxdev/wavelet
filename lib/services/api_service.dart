import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/track.dart';

class ApiConfig extends ChangeNotifier {
  static const _defaultBaseUrl = String.fromEnvironment(
    'WAVELET_API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  String _baseUrl = _toServerRoot(_defaultBaseUrl);

  String get baseUrl => _baseUrl;
  String get normalizedBaseUrl => '${_toServerRoot(_baseUrl)}/api';

  void updateBaseUrl(String value) {
    final normalized = _toServerRoot(value);
    if (normalized.isEmpty || normalized == _baseUrl) return;
    _baseUrl = normalized;
    notifyListeners();
  }

  static String _toServerRoot(String value) {
    final normalized = value.trim().replaceAll(RegExp(r'/+$'), '');
    if (normalized.isEmpty) return '';
    final apiIndex = normalized.indexOf('/api');
    return apiIndex == -1 ? normalized : normalized.substring(0, apiIndex);
  }
}

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ApiService {
  ApiService(this.config);

  final ApiConfig config;

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse('${config.normalizedBaseUrl}$path').replace(queryParameters: query);
  }

  Future<dynamic> _send(Future<http.Response> request) async {
    final response = await request.timeout(const Duration(seconds: 20));
    final contentType = response.headers['content-type'] ?? '';
    final looksLikeJson = contentType.contains('application/json') || response.body.trimLeft().startsWith('{') || response.body.trimLeft().startsWith('[');
    final body = response.body.isEmpty || !looksLikeJson ? null : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(body is Map ? body['error']?.toString() ?? 'Request failed' : _unexpectedResponseMessage(response));
    }
    if (!looksLikeJson) {
      throw ApiException(_unexpectedResponseMessage(response));
    }
    return body;
  }

  String _unexpectedResponseMessage(http.Response response) {
    final preview = response.body.trim().replaceAll(RegExp(r'\s+'), ' ');
    final shortPreview = preview.length > 100 ? '${preview.substring(0, 100)}...' : preview;
    return 'Expected JSON from ${response.request?.url}, got HTTP ${response.statusCode}: $shortPreview';
  }

  Future<List<Track>> search(String query) async {
    if (query.trim().isEmpty) return [];
    final body = await _send(http.get(_uri('/search', {'q': query.trim()})));
    return (body as List).map((item) => _trackFromJson(item)).toList();
  }

  Future<List<Track>> getLiked() => _getTracks('/liked');
  Future<List<Track>> getRecent() => _getTracks('/recent');
  Future<List<Track>> getQueue() => _getTracks('/queue');

  Future<List<Track>> _getTracks(String path) async {
    final body = await _send(http.get(_uri(path)));
    return (body as List).map((item) => _trackFromJson(item)).toList();
  }

  Track _trackFromJson(dynamic item) {
    final track = Track.fromJson(item as Map<String, dynamic>);
    final streamUrl = track.streamUrl;
    if (streamUrl == null || streamUrl.isEmpty || streamUrl.startsWith('http')) {
      return track;
    }

    final apiBase = Uri.parse(config.normalizedBaseUrl);
    final origin = '${apiBase.scheme}://${apiBase.authority}';
    return track.copyWith(streamUrl: '$origin$streamUrl');
  }

  Future<void> like(Track track) => _send(http.post(_uri('/liked'), headers: _jsonHeaders, body: jsonEncode(track.toJson())));
  Future<void> unlike(String id) => _send(http.delete(_uri('/liked/$id')));
  Future<void> addRecent(Track track) => _send(http.post(_uri('/recent'), headers: _jsonHeaders, body: jsonEncode(track.toJson())));
  Future<void> addQueue(Track track) => _send(http.post(_uri('/queue'), headers: _jsonHeaders, body: jsonEncode(track.toJson())));
  Future<void> removeQueue(String id) => _send(http.delete(_uri('/queue/$id')));
  Future<void> clearQueue() => _send(http.delete(_uri('/queue')));

  Future<List<dynamic>> getPlaylists() async => await _send(http.get(_uri('/playlists'))) as List<dynamic>;
  Future<void> createPlaylist(String name) => _send(http.post(_uri('/playlists'), headers: _jsonHeaders, body: jsonEncode({'name': name})));
  Future<void> addToPlaylist(String playlistId, Track track) => _send(http.post(_uri('/playlists/$playlistId/tracks'), headers: _jsonHeaders, body: jsonEncode(track.toJson())));
  Future<void> removeFromPlaylist(String playlistId, String trackId) => _send(http.delete(_uri('/playlists/$playlistId/tracks/$trackId')));

  Map<String, String> get _jsonHeaders => {'Content-Type': 'application/json'};
}
