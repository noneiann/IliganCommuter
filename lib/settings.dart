// settings.dart
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: Icon(Icons.language, color: Theme.of(context).colorScheme.primary),
            title: Text('Language', style: Theme.of(context).textTheme.bodyLarge),
            subtitle: Text('English', style: Theme.of(context).textTheme.bodyMedium),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: Icon(Icons.dark_mode, color: Theme.of(context).colorScheme.primary),
            title: Text('Theme', style: Theme.of(context).textTheme.bodyLarge),
            subtitle: Text('Light', style: Theme.of(context).textTheme.bodyMedium),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: Icon(Icons.info, color: Theme.of(context).colorScheme.primary),
            title: Text('About', style: Theme.of(context).textTheme.bodyLarge),
            subtitle: Text('Version 1.0.0', style: Theme.of(context).textTheme.bodyMedium),
          ),
        ),
      ],
    );
  }
}
