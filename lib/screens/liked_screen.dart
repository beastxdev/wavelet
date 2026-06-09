import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/track.dart';
import '../services/api_service.dart';
import '../services/audio_player_service.dart';
import '../widgets/track_tile.dart';

class LikedScreen extends StatelessWidget {
  const LikedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Track>>(
        future: context.read<ApiService>().getLiked(),
        builder: (context, snapshot) {
          final tracks = snapshot.data ?? [];
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                title: const Text('Liked songs'),
                expandedHeight: 160,
                pinned: true,
                flexibleSpace: const FlexibleSpaceBar(
                  background: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1ED760), Color(0xFF106DB7), Color(0xFF080B10)]),
                    ),
                  ),
                ),
              ),
              if (snapshot.connectionState == ConnectionState.waiting)
                const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
              else if (snapshot.hasError)
                SliverFillRemaining(child: Center(child: Text(snapshot.error.toString())))
              else if (tracks.isEmpty)
                const SliverFillRemaining(child: Center(child: Text('No liked songs yet.')))
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => context.read<AudioPlayerService>().playAll(tracks),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Play liked'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => context.read<AudioPlayerService>().playAll(tracks, shuffle: true),
                            icon: const Icon(Icons.shuffle),
                            label: const Text('Shuffle'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList.builder(
                  itemCount: tracks.length,
                  itemBuilder: (context, index) {
                    final track = tracks[index];
                    final audio = context.watch<AudioPlayerService>();
                    return TrackTile(
                      index: index,
                      playing: audio.current?.id == track.id,
                      track: track,
                      onTap: () => context.read<AudioPlayerService>().play(track, contextQueue: tracks),
                      trailing: IconButton(
                        icon: const Icon(Icons.favorite),
                        onPressed: () => context.read<ApiService>().unlike(track.id),
                      ),
                    );
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
