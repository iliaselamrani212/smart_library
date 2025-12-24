import 'package:flutter/material.dart';
import 'package:smart_library/pages/add_book_screen.dart';
import 'package:smart_library/pages/books_screen.dart';
import 'package:smart_library/pages/home_screen.dart';
import 'package:smart_library/pages/setting.dart';

import 'MyQuotesScreen.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  int _currentIndex = 0;

  // Fonction pour gérer la navigation
  void _onItemTapped(int index) {
    // Si l'utilisateur clique sur le bouton "+" (index 2)
    // On ouvre la page d'ajout par-dessus le Layout
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddBookScreen()),
      );
      return; // On arrête ici pour ne pas changer l'onglet actif en dessous
    }

    // Sinon, on change l'onglet normalement
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Nous définissons la liste des pages ICI (dans le build)
    // C'est nécessaire pour pouvoir passer la fonction '_onItemTapped' au HomeScreen
    final List<Widget> pages = [
      // Index 0 : Home (On lui donne la capacité de changer d'onglet)
      HomeScreen(onTabChange: _onItemTapped),


      const MyBooksScreen(),

      const SizedBox(),




      const MyQuotesScreen(),


      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,

      // ---------- APP BAR ----------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Flutter Ebook App',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ---------- BODY ----------
      // Affiche la page correspondant à l'index sélectionné
      body: pages[_currentIndex],

      // ---------- BOTTOM NAV ----------
      bottomNavigationBar: Container(
        // Petite ombre pour détacher la barre du contenu blanc
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed, // Important car vous avez 5 items
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black, // Noir quand sélectionné
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 0,

          items: [
            // 0. Home
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),

            // 1. My Books
            const BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'My Books',
            ),

            // 2. LE BOUTON SPÉCIAL (ADD)
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black, // Le fond NOIR
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              label: '',
            ),

            // 3. Settings
            const BottomNavigationBarItem(
              icon: Icon(Icons.format_quote_outlined),
              activeIcon: Icon(Icons.format_quote_sharp),
              label: 'Quotes',

            ),

            // 4. Profile
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',

            ),
          ],
        ),
      ),
    );
  }
}