import 'package:flutter/material.dart';

import 'liked_screen.dart';
import 'playlist_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _LibraryTile(
            icon: Icons.favorite,
            title: 'Liked songs',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LikedScreen())),
          ),
          _LibraryTile(
            icon: Icons.playlist_play,
            title: 'Playlists',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PlaylistScreen())),
          ),
          _LibraryTile(
            icon: Icons.offline_pin_outlined,
            title: 'Offline mode',
            subtitle: 'Available later for permitted/local files.',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _LibraryTile extends StatelessWidget {
  const _LibraryTile({required this.icon, required this.title, required this.onTap, this.subtitle});

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.secondary),
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle!),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
