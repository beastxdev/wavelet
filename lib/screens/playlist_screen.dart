import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/track.dart';
import '../services/api_service.dart';
import '../services/audio_player_service.dart';
import '../widgets/track_tile.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<ApiService>().getPlaylists();
  }

  void _refresh() => setState(() => _future = context.read<ApiService>().getPlaylists());

  Future<void> _create() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New playlist'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: 'Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Create')),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    final api = context.read<ApiService>();
    await api.createPlaylist(name);
    if (!mounted) return;
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Playlists'), actions: [IconButton.filledTonal(onPressed: _create, icon: const Icon(Icons.add))]),
      body: FutureBuilder<List<dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text(snapshot.error.toString()));
          final playlists = snapshot.data ?? [];
          if (playlists.isEmpty) {
            return Center(
              child: FilledButton.icon(onPressed: _create, icon: const Icon(Icons.add), label: const Text('Create your first playlist')),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index] as Map<String, dynamic>;
              final tracks = (playlist['tracks'] as List? ?? []).map((item) => Track.fromJson(item)).toList();
              return _PlaylistCard(
                playlist: playlist,
                tracks: tracks,
                onChanged: _refresh,
              );
            },
          );
        },
      ),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({required this.playlist, required this.tracks, required this.onChanged});

  final Map<String, dynamic> playlist;
  final List<Track> tracks;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioPlayerService>();
    final name = playlist['name']?.toString() ?? 'Playlist';
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1ED760), Color(0xFF39A7FF)]),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.playlist_play, color: Colors.black),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text('${tracks.length} tracks'),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: tracks.isEmpty ? null : () => audio.playAll(tracks),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Play'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: tracks.isEmpty ? null : () => audio.playAll(tracks, shuffle: true),
                    icon: const Icon(Icons.shuffle),
                    label: const Text('Shuffle'),
                  ),
                ),
              ],
            ),
          ),
          if (tracks.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Text('Add songs from search to build this playlist.', style: TextStyle(color: Colors.white60)),
            )
          else
            ...tracks.asMap().entries.map((entry) {
              final track = entry.value;
              return TrackTile(
                index: entry.key,
                playing: audio.current?.id == track.id,
                track: track,
                onTap: () => audio.play(track, contextQueue: tracks),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () async {
                    final api = context.read<ApiService>();
                    await api.removeFromPlaylist(playlist['id'].toString(), track.id);
                    onChanged();
                  },
                ),
              );
            }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
