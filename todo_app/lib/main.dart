import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/pages/login.dart';
import '/pages/home.dart';
import 'package:provider/provider.dart';
import '/providers/project_provider.dart';
import '/providers/task_provider.dart';
import '/providers/profile_provider.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://mndwmwmmikpfksmcxlwu.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1uZHdtd21taWtwZmtzbWN4bHd1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjkyNTgxOTEsImV4cCI6MjA0NDgzNDE5MX0.6I9ck7Wcg6XBLDgNKR7dy4ROVs2winVBYXNSao1GCYs',
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ProfileProvider(supabase)),
          ChangeNotifierProvider(create: (_) => ProjectProvider(supabase)),
          ChangeNotifierProvider(create: (_) => TaskProvider(supabase)),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Pro-Genius',
          theme: ThemeData.dark().copyWith(
            primaryColor: Colors.blueAccent,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          home: supabase.auth.currentSession == null
              ? const LoginPage()
              : const HomePage(),
        ));
  }
}

extension ContextExtension on BuildContext {
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(this).colorScheme.error
            : Theme.of(this).snackBarTheme.backgroundColor,
      ),
    );
  }
}
