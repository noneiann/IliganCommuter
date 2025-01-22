// main.dart
import 'package:flutter/material.dart';
import 'routes.dart';
import 'map.dart';
import 'settings.dart';

void main() {
  runApp(const IliganonGo());
}

class IliganonGo extends StatelessWidget {
  const IliganonGo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IliganonGo',
      theme: ThemeData(
        primaryColor: const Color(0xFF98D8D8), // Pastel Blue
        scaffoldBackgroundColor: const Color(0xFFF0F8F8),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF98D8D8),
          secondary: Color(0xFF98D8AA), // Pastel Green
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const RoutesPage(),
    const MapPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IliganonGo'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.route), label: 'Routes'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}