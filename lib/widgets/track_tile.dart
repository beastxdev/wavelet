import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/track.dart';

class TrackTile extends StatelessWidget {
  const TrackTile({
    super.key,
    required this.track,
    required this.onTap,
    this.trailing,
    this.index,
    this.playing = false,
  });

  final Track track;
  final VoidCallback onTap;
  final Widget? trailing;
  final int? index;
  final bool playing;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: playing ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (index != null)
              SizedBox(
                width: 28,
                child: Text('${index! + 1}', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withValues(alpha: 0.56))),
              ),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: track.thumbnail.isEmpty
                  ? Container(
                      width: 54,
                      height: 54,
                      color: const Color(0xFF1A2430),
                      child: const Icon(Icons.music_note),
                    )
                  : CachedNetworkImage(
                      imageUrl: track.thumbnail,
                      width: 54,
                      height: 54,
                      fit: BoxFit.cover,
                    ),
            ),
          ],
        ),
        title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: playing ? FontWeight.w800 : FontWeight.w600)),
        subtitle: Text('${track.author} • ${track.durationLabel}', maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: trailing,
      ),
    );
  }
}
