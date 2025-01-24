// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'routes.dart';
import 'map.dart';
import 'settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Make the status bar background transparent
      statusBarIconBrightness: Brightness.dark, // Dark icons for light mode
      statusBarBrightness: Brightness.light, // Required for iOS
    ),
  );
  runApp(const IliganonGo());
}

class IliganonGo extends StatelessWidget {
  const IliganonGo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IliganonGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF98D8D8), // Pastel Teal
        scaffoldBackgroundColor: const Color(0xFFF7F7F7), // Light neutral background
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF98D8D8),
          secondary: Color(0xFFD89898), // Pastel Pink
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF98D8D8),
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFFF7F7F7),
          selectedItemColor: Color(0xFF98D8D8),
          unselectedItemColor: Color(0xFFD89898),
          selectedIconTheme: IconThemeData(size: 28),
          unselectedIconTheme: IconThemeData(size: 24),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF4A4A4A), fontSize: 16), // Dark gray text
          bodyMedium: TextStyle(color: Color(0xFF4A4A4A), fontSize: 14),
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
      resizeToAvoidBottomInset: false,
      body: SafeArea(child: _pages[_currentIndex]),
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
