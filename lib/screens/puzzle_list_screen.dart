import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/puzzle_model.dart';
import '../providers/puzzle_provider.dart';
import '../widgets/puzzle_card.dart';

class PuzzleListScreen extends StatefulWidget {
  const PuzzleListScreen({Key? key}) : super(key: key);

  @override
  State<PuzzleListScreen> createState() => _PuzzleListScreenState();
}

class _PuzzleListScreenState extends State<PuzzleListScreen> {
  bool _isSelectionMode = false;
  final Set<String> _selectedPuzzles = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text('${_selectedPuzzles.length} selected')
            : const Text('Saved Puzzles'),
        elevation: 0,
        actions: [
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _clearSelection,
              tooltip: 'Cancel selection',
            ),
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleteSelected,
              tooltip: 'Delete selected',
            ),
        ],
      ),
      body: Consumer<PuzzleProvider>(
        builder: (context, puzzleProvider, child) {
          if (puzzleProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (puzzleProvider.puzzles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.puzzle_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No puzzles saved yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create or download a puzzle to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.add),
                    label: const Text('Create New Puzzle'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => puzzleProvider.loadPuzzles(),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: puzzleProvider.puzzles.length,
              itemBuilder: (context, index) {
                final puzzle = puzzleProvider.puzzles[index];
                final isSelected = _selectedPuzzles.contains(puzzle.id);

                return PuzzleCard(
                  puzzle: puzzle,
                  isSelected: isSelected && _isSelectionMode,
                  onTap: () => _handlePuzzleTap(puzzle),
                  onLongPress: () => _handlePuzzleLongPress(puzzle),
                  onDelete: () => _deletePuzzle(context, puzzle),
                  onEdit: () => _editPuzzle(context, puzzle),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton(
              onPressed: () => _createNewPuzzle(context),
              tooltip: 'Create new puzzle',
              child: const Icon(Icons.add),
            ),
    );
  }

  void _handlePuzzleTap(PuzzleModel puzzle) {
    if (_isSelectionMode) {
      setState(() {
        if (_selectedPuzzles.contains(puzzle.id)) {
          _selectedPuzzles.remove(puzzle.id);
        } else {
          _selectedPuzzles.add(puzzle.id);
        }

        if (_selectedPuzzles.isEmpty) {
          _isSelectionMode = false;
        }
      });
    } else {
      // Navigate to puzzle game/details screen
      Navigator.of(context).pushNamed(
        '/puzzle-game',
        arguments: puzzle,
      );
    }
  }

  void _handlePuzzleLongPress(PuzzleModel puzzle) {
    setState(() {
      _isSelectionMode = true;
      _selectedPuzzles.add(puzzle.id);
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedPuzzles.clear();
      _isSelectionMode = false;
    });
  }

  Future<void> _deletePuzzle(BuildContext context, PuzzleModel puzzle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Puzzle'),
        content: Text(
          'Are you sure you want to delete "${puzzle.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (mounted) {
        final puzzleProvider =
            Provider.of<PuzzleProvider>(context, listen: false);
        try {
          await puzzleProvider.deletePuzzle(puzzle.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Puzzle "${puzzle.name}" deleted'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to delete puzzle: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  Future<void> _deleteSelected() async {
    if (_selectedPuzzles.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Puzzles'),
        content: Text(
          'Are you sure you want to delete ${_selectedPuzzles.length} puzzle(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (mounted) {
        final puzzleProvider =
            Provider.of<PuzzleProvider>(context, listen: false);
        try {
          for (final puzzleId in _selectedPuzzles) {
            await puzzleProvider.deletePuzzle(puzzleId);
          }
          if (mounted) {
            setState(() {
              _selectedPuzzles.clear();
              _isSelectionMode = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${_selectedPuzzles.length} puzzle(s) deleted'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to delete puzzles: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  void _editPuzzle(BuildContext context, PuzzleModel puzzle) {
    // Navigate to puzzle editor screen
    Navigator.of(context).pushNamed(
      '/puzzle-editor',
      arguments: puzzle,
    );
  }

  void _createNewPuzzle(BuildContext context) {
    // Navigate to puzzle creation screen
    Navigator.of(context).pushNamed('/puzzle-create');
  }
}
