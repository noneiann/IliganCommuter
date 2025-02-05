// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:iliganon_go/api.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'routes.dart';
import 'map.dart';
import 'settings.dart';

// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(const IliganonGo());
}

class IliganonGo extends StatefulWidget {
  const IliganonGo({super.key});

  @override
  State<IliganonGo> createState() => _IliganonGoState();
}

class _IliganonGoState extends State<IliganonGo> {
  ThemeMode _themeMode = ThemeMode.light;

  void _changeThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
    // Update status bar icons based on theme
    final brightness = mode == ThemeMode.dark ? Brightness.light : Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: brightness,
        statusBarBrightness: brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IliganonGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF98D8D8),
        scaffoldBackgroundColor: const Color(0xFFF7F7F7),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF98D8D8),
          secondary: Color(0xFFD89898),
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
          bodyLarge: TextStyle(color: Color(0xFF4A4A4A), fontSize: 16),
          bodyMedium: TextStyle(color: Color(0xFF4A4A4A), fontSize: 14),
        ),
      ),
      darkTheme: ThemeData(
        primaryColor: const Color(0xFF4A4A4A),
        scaffoldBackgroundColor: const Color(0xFF303030),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4A4A4A),
          secondary: Color(0xFF7A7A7A),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4A4A4A),
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF303030),
          selectedItemColor: Color(0xFF7A7A7A),
          unselectedItemColor: Color(0xFF5A5A5A),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      themeMode: _themeMode,
      home: HomePage(
        changeThemeMode: _changeThemeMode,
        currentThemeMode: _themeMode,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final Function(ThemeMode) changeThemeMode;
  final ThemeMode currentThemeMode;

  const HomePage({
    super.key,
    required this.changeThemeMode,
    required this.currentThemeMode,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      const RoutesPage(),
      const MapPage(),
      SettingsPage(
        changeThemeMode: widget.changeThemeMode,
        currentThemeMode: widget.currentThemeMode,
      ),
    ];

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