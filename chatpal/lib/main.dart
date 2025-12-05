import "package:flutter/material.dart";
import "screen/dashboard.dart";
import "screen/aichatscreen.dart";
import "screen/quizscreen.dart";

void main() => runApp(CramLand());

class CramLand extends StatelessWidget {
  const CramLand({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "CramLand",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue,fontFamily: "Inter"),
      home: const MainScreen(),
    );
  }
}

class Style {
  static ThemeData get style {
    return ThemeData(
      primarySwatch: Colors.blue,
      fontFamily: "Inter",
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();


    _screens = [

      DashboardScreen(
        onAIChatTap: () {
          setState(() => _selectedIndex = 1);
        },
        onQuizTap: () {
          setState(() => _selectedIndex = 2);
        },
        onTestTap: () {
          setState(() => _selectedIndex = 2);
        },
      ),


      AIChatScreen(onBackTap: () {
        setState(() => _selectedIndex = 0);
      }),


      QuizScreen(onBackTap: () {
        setState(() => _selectedIndex = 0);
      }),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
    );
  }
}