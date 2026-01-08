import 'package:flutter/material.dart';

void main() {
  runApp(const NonogramApp());
}

class NonogramApp extends StatelessWidget {
  const NonogramApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nonogram',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ).primary,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ).primary,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const NonogramHomePage(title: 'Nonogram'),
    );
  }
}

class NonogramHomePage extends StatefulWidget {
  const NonogramHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<NonogramHomePage> createState() => _NonogramHomePageState();
}

class _NonogramHomePageState extends State<NonogramHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const Center(
        child: Text(
          'Welcome to Nonogram!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
