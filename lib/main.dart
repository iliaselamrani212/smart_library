import 'package:smart_library/auth/auth.dart';
import 'package:smart_library/pages/book_datails_screen.dart';
import 'package:smart_library/pages/books_screen.dart'; // Assurez-vous que le nom du fichier est bon
import 'package:smart_library/pages/home_screen.dart';
import 'package:smart_library/pages/layout.dart';
import 'package:smart_library/pages/setting.dart';
import 'package:smart_library/providers/favorites_provider.dart';
import 'package:smart_library/theme/theme.dart';
import 'package:smart_library/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // 1. Indispensable pour charger le thème avant le lancement


  // 2. On prépare le ThemeManager


  runApp(
    MultiProvider(
      providers: [

        ChangeNotifierProvider<FavoriteBooksProvider>(create: (_) => FavoriteBooksProvider()),
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

      home:  Layout(),
    );
  }
}