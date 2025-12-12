import "package:flutter/material.dart";
import "screen/dashboard.dart";
import "screen/aichatscreen.dart";
import "screen/quizscreen.dart";
import 'screen/loginscreen.dart';
import 'screen/pomodoro.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'screen/flashcardscreen.dart';
import 'dart:convert';
void main() => runApp(CramLand());

class CramLand extends StatelessWidget {
  const CramLand({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "CramLand",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue,fontFamily: "Inter"),
     // home: const MainScreen(),
        home: Builder(
          builder: (context) => LoginScreen(
            onLoginSuccess: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            },
          ),
        ),
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
  bool _isLoading = false;

  Future<void> _handleLogout(BuildContext context) async {
    setState(() => _isLoading = true);

    try {

      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      if (token != null) {

        final url = Uri.parse('http://192.168.0.109:8000/api/logout/');

        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Token $token',
          },
        );

        if (response.statusCode == 200) {
          print("Server logout successful");
        } else {
          print("Server logout failed: ${response.body}");
        }
      }

      await prefs.clear();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => LoginScreen(
              onLoginSuccess: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                );
              },
            ),
          ),
              (route) => false,
        );
      }
    } catch (e) {
      print("Error during logout: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {

    final List<Widget> screens = [
      DashboardScreen(
        onAIChatTap: () {
          setState(() => _selectedIndex = 1);
        },
        onQuizTap: () {
          setState(() => _selectedIndex = 2);
        },
        onPomodoroTap:(){
          setState(() => _selectedIndex = 3);
        },
        onFlashCardTap:(){
          setState(() => _selectedIndex = 4);
        },
        onLogoutTap: () => _handleLogout(context),
      ),

      AIChatScreen(onBackTap: () {
        setState(() => _selectedIndex = 0);
      }),
      QuizScreen(onBackTap: () {
        setState(() => _selectedIndex = 0);
      }),
      PomodoroScreen(onBackTap: (){
        setState(()=>_selectedIndex = 0);
      }),
      FlashCardScreen(onBackTap: (){
        setState(() => _selectedIndex = 0);
      }),
    ];

    return Scaffold(

      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: screens,
          ),
          if (_isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}