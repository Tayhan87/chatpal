import 'package:flutter/material.dart';

void main() => runApp(const CramLandApp());


class CramLandApp extends StatelessWidget {
  const CramLandApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CramLand',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // This list will hold our screens
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Initialize the screens list here, passing the callbacks
    _screens = [
      DashboardScreen(
        onAIChatTap: () {
          setState(() {
            _selectedIndex = 1; // Switch to AIChatScreen
          });
        },
      ),
      AIChatScreen(
        onBackTap: () {
          setState(() {
            _selectedIndex = 0; // Switch back to DashboardScreen
          });
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use IndexedStack to switch between widgets in the list
      // based on _selectedIndex
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  final VoidCallback onAIChatTap;

  const DashboardScreen({Key? key, required this.onAIChatTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFA4A4F5),
            Color(0xFFD4DDFA),
          ],
        ),

      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Main Dashboard',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 32),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFDAE3F8).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'CramLand',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          CircleAvatar(
                            backgroundColor: Color(0xFF7B8FCC),
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Welcome back,\nTayhan!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3D4B6B),
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 32),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              FeatureCard(
                                icon: Icons.smart_toy_outlined,
                                label: 'AI Chat',
                                color: Color(0xFF8FA7E8),
                                onTap: onAIChatTap, // This now works
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: FeatureCard(
                                      icon: Icons.menu_book,
                                      label: 'Study Buddy',
                                      color: Color(0xFF8FA7E8),
                                      isSmall: true,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: FeatureCard(
                                      icon: Icons.lightbulb_outline,
                                      label: 'Quizzes',
                                      color: Color(0xFF8FA7E8),
                                      isSmall: true,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: FeatureCard(
                                      icon: Icons.favorite_border,
                                      label: 'Wellness',
                                      color: Color(0xFF8FA7E8),
                                      isSmall: true,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: FeatureCard(
                                      icon: Icons.spa_outlined,
                                      label: 'Wellness',
                                      color: Color(0xFF8FA7E8),
                                      isSmall: true,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            NavItem(icon: Icons.home, label: 'Home'),
                            NavItem(icon: Icons.history, label: 'History'),
                            NavItem(icon: Icons.settings, label: 'Settings'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isSmall;
  final VoidCallback? onTap;

  const FeatureCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    this.isSmall = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.all(isSmall ? 16 : 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(isSmall ? 12 : 16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: isSmall ? 32 : 40,
                color: color,
              ),
            ),
            SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: isSmall ? 14 : 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3D4B6B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const NavItem({Key? key, required this.icon, required this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Color(0xFF8FA7E8), size: 28),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF8FA7E8),
          ),
        ),
      ],
    );
  }
}

class AIChatScreen extends StatefulWidget {
  // Add a callback to navigate back
  final VoidCallback onBackTap;

  const AIChatScreen({Key? key, required this.onBackTap}) : super(key: key);

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFB8C5E8),
            Color(0xFFD4DDFA),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add a Row to hold the back button and title
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
                    onPressed: widget.onBackTap, // Use the callback
                  ),
                  SizedBox(width: 8),
                  Text(
                    'AI Chat Interface',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24), // Adjusted spacing
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFDAE3F8).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  padding: EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'AI Tutor',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3D4B6B),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.access_time,
                                  color: Color(0xFF8FA7E8)),
                              SizedBox(width: 8),
                              Text(
                                'Summarize',
                                style: TextStyle(
                                  color: Color(0xFF8FA7E8),
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.more_vert, color: Color(0xFF8FA7E8)),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.psychology, color: Color(0xFF8FA7E8)),
                            SizedBox(width: 12),
                            Text(
                              'Personality: Supportive Tutor',
                              style: TextStyle(
                                color: Color(0xFF3D4B6B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Spacer(),
                            Icon(Icons.refresh, color: Color(0xFF8FA7E8)),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Summarize',
                            style: TextStyle(color: Color(0xFF8FA7E8)),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'New Chat',
                          style: TextStyle(color: Color(0xFF8FA7E8)),
                        ),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      // ** SYNTAX ERROR FIXED HERE **
                                      // The string is now closed, and the
                                      // widget has its closing parenthesis.
                                      MessageBubble(
                                        message:
                                        'Explain the main principles of quantum AI.',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // (Your chat input field would go here)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ** MISSING WIDGET ADDED HERE **
// A simple MessageBubble widget to display the chat message.
class MessageBubble extends StatelessWidget {
  final String message;

  const MessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Color(0xFF8FA7E8).withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: Text(
        message,
        style: TextStyle(
          color: Color(0xFF3D4B6B),
          fontSize: 16,
        ),
      ),
    );
  }
}