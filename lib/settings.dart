// settings.dart
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        ListTile(
          leading: Icon(Icons.language),
          title: Text('Language'),
          subtitle: Text('English'),
        ),
        ListTile(
          leading: Icon(Icons.dark_mode),
          title: Text('Theme'),
          subtitle: Text('Light'),
        ),
        ListTile(
          leading: Icon(Icons.info),
          title: Text('About'),
          subtitle: Text('Version 1.0.0'),
        ),
      ],
    );
  }
}