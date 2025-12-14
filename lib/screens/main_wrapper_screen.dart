import 'package:flutter/material.dart';

import 'main_page_screen.dart';
import 'todo_list_screen.dart';
import 'calendar_screen.dart';

class MainWrapperScreen extends StatefulWidget {
  const MainWrapperScreen({super.key});

  @override
  State<MainWrapperScreen> createState() => _MainWrapperScreenState();
}

class _MainWrapperScreenState extends State<MainWrapperScreen> {
  int _selectedIndex = 0; 

  static const List<Widget> _widgetOptions = <Widget>[
    MainPageScreen(),    // Index 0: Main Page
    TodoListScreen(),    // Index 1: To-Do List
    CalendarScreen(),    // Index 2: Calendar
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex), 
      
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.yellow.shade100,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20), 
            topRight: Radius.circular(20),
          ),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), 
              label: 'Main',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt),
              label: 'To-Do',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'Calendar',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.green.shade700, 
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.transparent, 
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}

