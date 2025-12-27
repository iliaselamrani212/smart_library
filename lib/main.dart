import 'package:smart_library/auth/auth.dart';
import 'package:smart_library/providers/favorites_provider.dart';
import 'package:smart_library/providers/my_books_provider.dart';
import 'package:smart_library/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 1. Indispensable pour charger le thème avant le lancement


  // 2. On prépare le ThemeManager


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
        ChangeNotifierProvider<FavoriteBooksProvider>(create: (_) => FavoriteBooksProvider()),
        ChangeNotifierProvider<MyBooksProvider>(create: (_) => MyBooksProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:  RegisterScreen(),
    );
  }
}
