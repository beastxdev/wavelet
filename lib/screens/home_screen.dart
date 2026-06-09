import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/audio_player_service.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/mini_player.dart';
import 'library_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  late final List<Widget> _pages = [
    _HomeTab(onNavigate: (index) => setState(() => _index = index)),
    const SearchScreen(),
    const LibraryScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        child: KeyedSubtree(key: ValueKey(_index), child: _pages[_index]),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          WaveletBottomNav(index: _index, onChanged: (value) => setState(() => _index = value)),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioPlayerService>();
    final track = audio.current;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text('Wavelet'),
          floating: true,
          actions: [
            IconButton.filledTonal(
              tooltip: 'Search',
              onPressed: () => onNavigate(1),
              icon: const Icon(Icons.search),
            ),
            const SizedBox(width: 12),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList.list(
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF152B25), Color(0xFF111A2B)]),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    _ListeningOrb(active: audio.isPlaying),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(track == null ? 'Ready to play' : 'Now playing', style: const TextStyle(color: Colors.white60)),
                          const SizedBox(height: 6),
                          Text(track?.title ?? 'Find your next track', maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                          if (track != null) ...[
                            const SizedBox(height: 4),
                            Text(track.author, maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text('Jump back in', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.6,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _Shortcut(icon: Icons.search, label: 'Search', onTap: () => onNavigate(1)),
                  _Shortcut(icon: Icons.favorite, label: 'Liked songs', onTap: () => onNavigate(2)),
                  _Shortcut(icon: Icons.playlist_play, label: 'Playlists', onTap: () => onNavigate(2)),
                  _Shortcut(icon: Icons.settings, label: 'Settings', onTap: () => onNavigate(3)),
                ],
              ),
              const SizedBox(height: 22),
              Text('Playback', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ActionChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shuffle, size: 18),
                        const SizedBox(width: 6),
                        Text(audio.mode == PlaybackMode.shuffle ? 'Shuffle on' : 'Shuffle'),
                      ],
                    ),
                    onPressed: audio.cycleMode,
                  ),
                  ActionChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.queue_music, size: 18),
                        const SizedBox(width: 6),
                        Text('${audio.queue.length} queued'),
                      ],
                    ),
                    onPressed: audio.current == null ? null : () => audio.playNext(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(color: const Color(0xFF111820), borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800))),
          ],
        ),
      ),
    );
  }
}

class _ListeningOrb extends StatefulWidget {
  const _ListeningOrb({required this.active});
  final bool active;

  @override
  State<_ListeningOrb> createState() => _ListeningOrbState();
}

class _ListeningOrbState extends State<_ListeningOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);

  @override
  void didUpdateWidget(covariant _ListeningOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.active ? _controller.repeat(reverse: true) : _controller.stop();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12 + (widget.active ? _controller.value * 0.12 : 0)),
            border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.36)),
          ),
          child: Icon(widget.active ? Icons.graphic_eq : Icons.play_arrow, size: 36, color: Theme.of(context).colorScheme.primary),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
