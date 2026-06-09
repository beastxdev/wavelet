import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/now_playing_screen.dart';
import '../services/audio_player_service.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioPlayerService>();
    final track = audio.current;
    if (track == null) return const SizedBox.shrink();

    return SafeArea(
      top: false,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 76,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF173A30), Color(0xFF152436)]),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: audio.isPlaying ? 0.24 : 0.08),
              blurRadius: audio.isPlaying ? 22 : 10,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NowPlayingScreen())),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: track.thumbnail.isEmpty
                          ? Container(width: 48, height: 48, color: const Color(0xFF101820), child: const Icon(Icons.music_note))
                          : CachedNetworkImage(imageUrl: track.thumbnail, width: 48, height: 48, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _TinyBars(active: audio.isPlaying),
                              const SizedBox(width: 8),
                              Expanded(child: Text(track.author, maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.skip_next), onPressed: audio.hasNext ? () => audio.playNext() : null),
                    IconButton(
                      icon: Icon(audio.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill),
                      iconSize: 38,
                      onPressed: audio.toggle,
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
              LinearProgressIndicator(
                value: audio.duration.inMilliseconds <= 0 ? 0 : audio.position.inMilliseconds.clamp(0, audio.duration.inMilliseconds) / audio.duration.inMilliseconds,
                minHeight: 3,
                backgroundColor: Colors.white10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TinyBars extends StatefulWidget {
  const _TinyBars({required this.active});
  final bool active;

  @override
  State<_TinyBars> createState() => _TinyBarsState();
}

class _TinyBarsState extends State<_TinyBars> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);

  @override
  void didUpdateWidget(covariant _TinyBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.active ? _controller.repeat(reverse: true) : _controller.stop();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          children: List.generate(3, (index) {
            final phase = ((_controller.value + index * 0.24) % 1);
            return Container(
              width: 3,
              height: widget.active ? 7 + phase * 9 : 6,
              margin: const EdgeInsets.only(right: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
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
