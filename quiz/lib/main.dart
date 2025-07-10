import 'package:flutter/material.dart';
import 'package:quiz/config/supabase_config.dart';
import 'package:quiz/src/login/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      home: LoginScreen(),
    );
  }
}
