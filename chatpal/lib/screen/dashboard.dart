import "package:flutter/material.dart";
import "../theme/theme.dart";

class DashboardScreen extends StatelessWidget {
  final VoidCallback onAIChatTap;
  final VoidCallback onQuizTap;
  final VoidCallback onLogoutTap;
  final VoidCallback onPomodoroTap;
  final VoidCallback onFlashCardTap;

  const DashboardScreen({
    super.key,
    required this.onAIChatTap,
    required this.onQuizTap,
    required this.onLogoutTap,
    required this.onPomodoroTap,
    required this.onFlashCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.buildBoxDecoration,
      width: double.infinity,
      height: double.infinity,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "CramLand",
                      style: _buildTextStyleCram(context),
                    ),

                    IconButton(
                      onPressed: onLogoutTap,
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white70,
                        size: 28,
                      ),
                      tooltip: 'Logout',
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Text(
                  "Welcome Back \nSolder!",
                  style: _buildTextStyleWel(context),
                ),
                const SizedBox(height: 32),

                _DasBoardCard(
                  icon: Icons.smart_toy_outlined,
                  title: "AI Chat",
                  colorAccent: const Color(0xFF96A3F6),
                  onTap: onAIChatTap,
                ),
                const SizedBox(height: 20),
                _DasBoardCard(
                  icon: Icons.book_outlined,
                  title: "Quiz",
                  colorAccent: const Color(0xFFF6A396),
                  onTap: onQuizTap,
                ),
                const SizedBox(height: 20),
                _DasBoardCard(
                    icon: Icons.timer,
                    title: "Pomodoro Timer",
                    onTap: onPomodoroTap,
                ),
                const SizedBox(height: 20),
                _DasBoardCard(
                    icon: Icons.note,
                    title: "Flash Note",
                    colorAccent: const Color(0xFFF6A396),
                    onTap: onFlashCardTap
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
      width: double.infinity,
      height: 150,
      child: Card(
        elevation: 8,
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: const Color(0xFFE9EEFE),
        child: InkWell(
          onTap: onTap,
          splashColor: colorAccent.withOpacity(0.3),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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