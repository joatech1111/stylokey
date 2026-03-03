import 'package:flutter/material.dart';
import 'keyboard_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KeyboardApp());
}

class KeyboardApp extends StatelessWidget {
  const KeyboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const _ImeHost(),
    );
  }
}

class _ImeHost extends StatelessWidget {
  const _ImeHost();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.bottomCenter,
        child: KeyboardView(),
      ),
    );
  }
}
