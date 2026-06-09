import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/audio_player_service.dart';
import '../widgets/track_tile.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioPlayerService>();
    final track = audio.current;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Now playing'),
        actions: [
          if (track != null)
            IconButton.filledTonal(
              tooltip: 'Add to playlist',
              onPressed: () => _addCurrentToPlaylist(context),
              icon: const Icon(Icons.playlist_add),
            ),
          const SizedBox(width: 12),
        ],
      ),
      body: track == null
          ? const Center(child: Text('Nothing is playing.'))
          : Stack(
              children: [
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, _) {
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment(math.sin(_pulse.value * math.pi * 2) * 0.35, -0.55),
                            radius: 1.1,
                            colors: const [Color(0x5522D36F), Color(0x22106DB7), Color(0xFF080B10)],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ListView(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 360),
                        scale: audio.isPlaying ? 1 : 0.96,
                        child: AnimatedRotation(
                          turns: audio.isPlaying ? 0.005 : 0,
                          duration: const Duration(milliseconds: 800),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: track.thumbnail.isEmpty
                                ? Container(width: 290, height: 290, color: const Color(0xFF16212B), child: const Icon(Icons.music_note, size: 86))
                                : CachedNetworkImage(imageUrl: track.thumbnail, width: 290, height: 290, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(track.title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Text(track.author, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70)),
                    const SizedBox(height: 22),
                    Slider(
                      value: audio.position.inMilliseconds.clamp(0, audio.duration.inMilliseconds).toDouble(),
                      max: audio.duration.inMilliseconds <= 0 ? 1 : audio.duration.inMilliseconds.toDouble(),
                      onChanged: (_) {},
                      onChangeEnd: (value) => audio.seek(Duration(milliseconds: value.toInt())),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_time(audio.position)),
                        Text(_time(audio.duration)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton.filledTonal(
                          tooltip: _modeLabel(audio.mode),
                          onPressed: audio.cycleMode,
                          icon: Icon(_modeIcon(audio.mode)),
                        ),
                        const SizedBox(width: 14),
                        IconButton(iconSize: 42, onPressed: audio.hasNext ? () => audio.playNext() : null, icon: const Icon(Icons.skip_next)),
                        const SizedBox(width: 14),
                        IconButton.filled(
                          iconSize: 72,
                          onPressed: audio.toggle,
                          icon: Icon(audio.isPlaying ? Icons.pause : Icons.play_arrow),
                        ),
                        const SizedBox(width: 14),
                        IconButton.filledTonal(
                          tooltip: 'Download',
                          onPressed: audio.isDownloading ? null : audio.downloadCurrent,
                          icon: audio.isDownloading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.download),
                        ),
                      ],
                    ),
                    if (audio.downloadMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(audio.downloadMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
                    ],
                    const SizedBox(height: 26),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Up next', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                        Text('${audio.queue.length} queued', style: const TextStyle(color: Colors.white60)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (audio.queue.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Text('Add tracks or play a playlist to keep the music moving.', style: TextStyle(color: Colors.white60)),
                      )
                    else
                      ...audio.queue.take(5).map((item) => TrackTile(track: item, onTap: () => audio.play(item), trailing: const Icon(Icons.drag_handle))),
                  ],
                ),
              ],
            ),
    );
  }

  String _time(Duration value) {
    final minutes = value.inMinutes;
    final seconds = value.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _addCurrentToPlaylist(BuildContext context) async {
    final track = context.read<AudioPlayerService>().current;
    if (track == null) return;
    final api = context.read<ApiService>();
    final playlists = await api.getPlaylists();
    if (!context.mounted) return;

    final selected = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      showDragHandle: true,
      builder: (context) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        children: [
          Text('Add to playlist', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          if (playlists.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 18), child: Text('Create a playlist from Library first.')),
          ...playlists.map((item) {
            final playlist = item as Map<String, dynamic>;
            return ListTile(
              leading: const Icon(Icons.playlist_add),
              title: Text(playlist['name']?.toString() ?? 'Playlist'),
              subtitle: Text('${(playlist['tracks'] as List? ?? []).length} tracks'),
              onTap: () => Navigator.pop(context, playlist),
            );
          }),
        ],
      ),
    );

    if (selected == null) return;
    await api.addToPlaylist(selected['id'].toString(), track);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added to ${selected['name']}')));
  }

  IconData _modeIcon(PlaybackMode mode) {
    return switch (mode) {
      PlaybackMode.normal => Icons.repeat,
      PlaybackMode.shuffle => Icons.shuffle,
      PlaybackMode.repeatOne => Icons.repeat_one,
    };
  }

  String _modeLabel(PlaybackMode mode) {
    return switch (mode) {
      PlaybackMode.normal => 'Normal play',
      PlaybackMode.shuffle => 'Shuffle',
      PlaybackMode.repeatOne => 'Repeat one',
    };
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }
}
