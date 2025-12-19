import 'package:flutter/material.dart';
import 'package:smart_library/pages/setting.dart';

import 'books_screen.dart';
import 'home_screen.dart';
class Layout extends StatefulWidget{
  State<Layout> createState() => _Layout();
}
class _Layout extends State<Layout> {
List<Widget> pages = [HomeScreen()  ,MyBooksScreen(),SettingsScreen() ];
int index = 0 ;
  @override
  Widget build(BuildContext context) {
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
      body: pages[index] ,

      // ---------- BOTTOM NAV ----------
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap:(value)=>{
          setState(() {
            index = value;
          }),
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'My Books',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}