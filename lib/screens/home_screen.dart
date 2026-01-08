import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade900,
              Colors.deepPurple.shade600,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              const Padding(
                padding: EdgeInsets.only(bottom: 60.0),
                child: Column(
                  children: [
                    Text(
                      'NONOGRAM',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2.0,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Logic Puzzle Game',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              // Menu Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    _buildMenuButton(
                      context,
                      label: 'New Game',
                      icon: Icons.play_arrow,
                      onPressed: () {
                        // Navigate to game selection or new game
                        _handleNewGame(context);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildMenuButton(
                      context,
                      label: 'Continue',
                      icon: Icons.history,
                      onPressed: () {
                        // Continue last game
                        _handleContinueGame(context);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildMenuButton(
                      context,
                      label: 'Statistics',
                      icon: Icons.bar_chart,
                      onPressed: () {
                        // View statistics
                        _handleStatistics(context);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildMenuButton(
                      context,
                      label: 'Settings',
                      icon: Icons.settings,
                      onPressed: () {
                        // Open settings
                        _handleSettings(context);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildMenuButton(
                      context,
                      label: 'About',
                      icon: Icons.info,
                      onPressed: () {
                        // Show about dialog
                        _handleAbout(context);
                      },
                    ),
                  ],
                ),
              ),
              // Footer
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.lightBlue.shade400,
                  Colors.cyan.shade600,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleNewGame(BuildContext context) {
    // TODO: Navigate to game selection screen or difficulty selection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New Game - Coming Soon')),
    );
  }

  void _handleContinueGame(BuildContext context) {
    // TODO: Load and display last saved game
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Continue Game - Coming Soon')),
    );
  }

  void _handleStatistics(BuildContext context) {
    // TODO: Navigate to statistics screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Statistics - Coming Soon')),
    );
  }

  void _handleSettings(BuildContext context) {
    // TODO: Navigate to settings screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings - Coming Soon')),
    );
  }

  void _handleAbout(BuildContext context) {
    // TODO: Show about dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('About Nonogram'),
          content: const Text(
            'Nonogram Game\n\nVersion 1.0.0\n\nA logic puzzle game where you fill in cells to create a picture based on number clues.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
