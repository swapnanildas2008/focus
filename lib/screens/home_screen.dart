import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'pomodoro_screen.dart';
import 'focus_mode_screen.dart';  // NEW
import 'island_screen.dart';
import 'todo_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const PomodoroScreen(),
    const FocusModeScreen(),  // NEW
    const IslandScreen(),
    const TodoScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.forestGreen.shade400,
              AppColors.forestGreen.shade600,
            ],
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.timer_outlined),
              activeIcon: Icon(Icons.timer),
              label: 'Pomodoro',
            ),
            BottomNavigationBarItem(  // NEW
              icon: Icon(Icons.psychology_outlined),
              activeIcon: Icon(Icons.psychology),
              label: 'Focus',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.landscape_outlined),
              activeIcon: Icon(Icons.landscape),
              label: 'Island',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.checklist_outlined),
              activeIcon: Icon(Icons.checklist),
              label: 'Tasks',
            ),
          ],
        ),
      ),
    );
  }
}
