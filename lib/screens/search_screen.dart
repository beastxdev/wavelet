import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/track.dart';
import '../services/api_service.dart';
import '../services/audio_player_service.dart';
import '../widgets/track_tile.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<Track> _results = [];
  bool _loading = false;
  String? _error;

  Future<void> _search() async {
    final api = context.read<ApiService>();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _results = await api.search(_controller.text);
    } catch (error) {
      _error = error.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _play(Track track) async {
    final api = context.read<ApiService>();
    final audio = context.read<AudioPlayerService>();
    try {
      await audio.play(track, contextQueue: _results);
      await api.addRecent(track);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _addToPlaylist(Track track) async {
    final api = context.read<ApiService>();
    final playlists = await api.getPlaylists();
    if (!mounted) return;

    final selected = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      showDragHandle: true,
      builder: (context) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        children: [
          Text('Add to playlist', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          if (playlists.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Text('Create a playlist from Library first.'),
            ),
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
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added to ${selected['name']}')));
  }

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioPlayerService>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Search'),
            floating: true,
            actions: [
              if (_results.isNotEmpty)
                IconButton.filledTonal(
                  tooltip: 'Play all',
                  onPressed: () => audio.playAll(_results),
                  icon: const Icon(Icons.play_arrow),
                ),
              const SizedBox(width: 12),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    if (_loading)
                      BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.24), blurRadius: 24),
                  ],
                ),
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(),
                  decoration: InputDecoration(
                    hintText: 'Songs, artists, videos',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(icon: const Icon(Icons.arrow_forward), onPressed: _search),
                  ),
                ),
              ),
            ),
          ),
          if (_loading) const SliverToBoxAdapter(child: LinearProgressIndicator()),
          if (_error != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              ),
            ),
          if (!_loading && _results.isEmpty && _error == null)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('Search for something you want to hear.')),
            )
          else
            SliverList.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final track = _results[index];
                return TrackTile(
                  index: index,
                  playing: audio.current?.id == track.id,
                  track: track,
                  onTap: () => _play(track),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      final api = context.read<ApiService>();
                      if (value == 'like') await api.like(track);
                      if (value == 'queue') {
                        final audio = context.read<AudioPlayerService>();
                        await api.addQueue(track);
                        if (!mounted) return;
                        audio.enqueue(track);
                      }
                      if (value == 'playlist') await _addToPlaylist(track);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'like', child: Text('Like')),
                      PopupMenuItem(value: 'queue', child: Text('Add to queue')),
                      PopupMenuItem(value: 'playlist', child: Text('Add to playlist')),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
