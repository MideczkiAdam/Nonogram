import 'package:flutter/material.dart';

class PuzzleSelectionScreen extends StatelessWidget {
  const PuzzleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Puzzle Size'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Choose a puzzle difficulty',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildSizeButton(
                    context,
                    size: '5x5',
                    difficulty: 'Easy',
                    color: Colors.green,
                  ),
                  _buildSizeButton(
                    context,
                    size: '10x10',
                    difficulty: 'Medium',
                    color: Colors.blue,
                  ),
                  _buildSizeButton(
                    context,
                    size: '15x15',
                    difficulty: 'Hard',
                    color: Colors.orange,
                  ),
                  _buildSizeButton(
                    context,
                    size: '20x20',
                    difficulty: 'Expert',
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSizeButton(
    BuildContext context, {
    required String size,
    required String difficulty,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        _onPuzzleSizeSelected(context, size);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.8),
              color,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                size,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                difficulty,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onPuzzleSizeSelected(BuildContext context, String size) {
    // Handle puzzle size selection
    // TODO: Navigate to puzzle game screen or fetch puzzle based on size
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting $size puzzle...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
