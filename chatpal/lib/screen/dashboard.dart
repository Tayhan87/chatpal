import "package:flutter/material.dart";
import "../theme/theme.dart";

class DashboardScreen extends StatelessWidget {
  final VoidCallback onAIChatTap;
  final VoidCallback onQuizTap;
  final VoidCallback onTestTap;

  const DashboardScreen({
    super.key,
    required this.onAIChatTap,
    required this.onQuizTap,
    required this.onTestTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.buildBoxDecoration,
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        child: SingleChildScrollView( // 1. Added Scrolling to prevent overflow
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "CramLand",
                      style: _buildTextStyleCram(context),
                    ),
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.black26,
                      child: Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "Welcome Back \nTayhan!",
                  style: _buildTextStyleWel(context),
                ),
                const SizedBox(height: 32),

                // --- CARDS ---
                // 2. Removed 'width: 400'. The cards now fill the screen width.
                _DasBoardCard(
                  icon: Icons.smart_toy_outlined,
                  title: "AI Chat",
                  colorAccent: const Color(0xFF96A3F6), // Light Purple Icon
                  onTap: onAIChatTap,
                ),
                const SizedBox(height: 20),
                _DasBoardCard(
                  icon: Icons.book_outlined,
                  title: "Quiz",
                  colorAccent: const Color(0xFFF6A396), // Light Red Icon
                  onTap: onQuizTap,
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _buildTextStyleCram(BuildContext context) {
    return const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        fontFamily: "Inter",
        color: Colors.white54);
  }

  TextStyle _buildTextStyleWel(BuildContext context) {
    return const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: Color(0xFF3D4B6B),
      height: 1.3,
    );
  }
}

class _DasBoardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color colorAccent;

  const _DasBoardCard({
    required this.icon,
    required this.title,
    required this.onTap,
    this.colorAccent = const Color(0xFF96A3F6),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Fills the width of the parent (padding)
      height: 150,
      child: Card(
        elevation: 8,
        // Clip behavior ensures the InkWell ripple stays inside the rounded corners
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: const Color(0xFFE9EEFE),
        child: InkWell(
          onTap: onTap,
          splashColor: colorAccent.withOpacity(0.3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // 3. Centered content
            children: [
              Icon(icon, size: 60, color: colorAccent),
              const SizedBox(height: 10),
              Text(title, style: _buildTextStyleCard(context))
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _buildTextStyleCard(BuildContext context) {
    return const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      fontFamily: "Inter",
      color: Colors.black54,
    );
  }
}