import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: context.read<ApiConfig>().baseUrl);
  }

  @override
  Widget build(BuildContext context) {
    final config = context.watch<ApiConfig>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Backend', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.dns), labelText: 'Backend URL'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => config.updateBaseUrl(_controller.text),
            icon: const Icon(Icons.save),
            label: const Text('Save'),
          ),
          const SizedBox(height: 24),
          const ListTile(
            leading: Icon(Icons.offline_pin_outlined),
            title: Text('Offline mode'),
            subtitle: Text('Available later for permitted/local files.'),
          ),
        ],
      ),
    );
  }
}
