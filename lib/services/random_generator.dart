import 'dart:math';

/// Service for generating random nonogram puzzles
class RandomGenerator {
  static final Random _random = Random();

  /// Generates a random nonogram puzzle with specified dimensions
  /// 
  /// [width] - Width of the puzzle grid
  /// [height] - Height of the puzzle grid
  /// [difficulty] - Difficulty level (0.0 to 1.0, where 1.0 is maximum fill)
  /// 
  /// Returns a 2D boolean list where true represents a filled cell
  static List<List<bool>> generatePuzzle({
    required int width,
    required int height,
    double difficulty = 0.5,
  }) {
    assert(width > 0 && width <= 50, 'Width must be between 1 and 50');
    assert(height > 0 && height <= 50, 'Height must be between 1 and 50');
    assert(difficulty >= 0.0 && difficulty <= 1.0, 'Difficulty must be between 0.0 and 1.0');

    final puzzle = List<List<bool>>.generate(
      height,
      (_) => List<bool>.generate(
        width,
        (_) => _random.nextDouble() < difficulty,
      ),
    );

    return puzzle;
  }

  /// Generates a random puzzle with a symmetric pattern (point symmetry)
  /// 
  /// [width] - Width of the puzzle grid
  /// [height] - Height of the puzzle grid
  /// [difficulty] - Difficulty level (0.0 to 1.0)
  /// 
  /// Returns a symmetrically filled 2D boolean list
  static List<List<bool>> generateSymmetricPuzzle({
    required int width,
    required int height,
    double difficulty = 0.5,
  }) {
    assert(width > 0 && width <= 50, 'Width must be between 1 and 50');
    assert(height > 0 && height <= 50, 'Height must be between 1 and 50');
    assert(difficulty >= 0.0 && difficulty <= 1.0, 'Difficulty must be between 0.0 and 1.0');

    final puzzle = List<List<bool>>.generate(height, (_) => List<bool>.filled(width, false));

    // Generate only half of the puzzle and mirror it
    final midHeight = (height / 2).ceil();
    final midWidth = (width / 2).ceil();

    for (int y = 0; y < midHeight; y++) {
      for (int x = 0; x < midWidth; x++) {
        final filled = _random.nextDouble() < difficulty;
        puzzle[y][x] = filled;
        
        // Mirror horizontally
        if (x < width - 1 - x) {
          puzzle[y][width - 1 - x] = filled;
        }
        
        // Mirror vertically
        if (y < height - 1 - y) {
          puzzle[height - 1 - y][x] = filled;
        }
        
        // Mirror both ways (point symmetry)
        if (x < width - 1 - x && y < height - 1 - y) {
          puzzle[height - 1 - y][width - 1 - x] = filled;
        }
      }
    }

    return puzzle;
  }

  /// Generates a puzzle with random horizontal stripes
  /// 
  /// [width] - Width of the puzzle grid
  /// [height] - Height of the puzzle grid
  /// 
  /// Returns a 2D boolean list with stripe pattern
  static List<List<bool>> generateStripedPuzzle({
    required int width,
    required int height,
  }) {
    assert(width > 0 && width <= 50, 'Width must be between 1 and 50');
    assert(height > 0 && height <= 50, 'Height must be between 1 and 50');

    final puzzle = List<List<bool>>.generate(height, (_) => List<bool>.filled(width, false));

    // Create random stripe pattern
    int stripeHeight = max(1, _random.nextInt(height ~/ 2) + 1);
    bool filled = _random.nextBool();

    for (int y = 0; y < height; y++) {
      if (y % stripeHeight == 0 && y > 0) {
        filled = !filled;
        stripeHeight = max(1, _random.nextInt(height ~/ 2) + 1);
      }

      for (int x = 0; x < width; x++) {
        puzzle[y][x] = filled;
      }
    }

    return puzzle;
  }

  /// Generates a puzzle with clusters of filled cells
  /// 
  /// [width] - Width of the puzzle grid
  /// [height] - Height of the puzzle grid
  /// [clusterCount] - Number of clusters to create
  /// [clusterSize] - Average size of each cluster
  /// 
  /// Returns a 2D boolean list with clustered pattern
  static List<List<bool>> generateClusteredPuzzle({
    required int width,
    required int height,
    int clusterCount = 5,
    int clusterSize = 3,
  }) {
    assert(width > 0 && width <= 50, 'Width must be between 1 and 50');
    assert(height > 0 && height <= 50, 'Height must be between 1 and 50');
    assert(clusterCount > 0, 'Cluster count must be positive');
    assert(clusterSize > 0, 'Cluster size must be positive');

    final puzzle = List<List<bool>>.generate(height, (_) => List<bool>.filled(width, false));

    for (int c = 0; c < clusterCount; c++) {
      int centerY = _random.nextInt(height);
      int centerX = _random.nextInt(width);
      int size = max(1, _random.nextInt(clusterSize) + 1);

      for (int dy = -size; dy <= size; dy++) {
        for (int dx = -size; dx <= size; dx++) {
          int y = centerY + dy;
          int x = centerX + dx;

          if (y >= 0 && y < height && x >= 0 && x < width) {
            if ((dx * dx + dy * dy) <= size * size) {
              puzzle[y][x] = true;
            }
          }
        }
      }
    }

    return puzzle;
  }

  /// Converts a puzzle to clue numbers (row and column hints)
  /// 
  /// [puzzle] - 2D boolean list representing the puzzle
  /// 
  /// Returns a map with 'rows' and 'cols' containing clue lists
  static Map<String, List<List<int>>> generateClues(List<List<bool>> puzzle) {
    final rows = <List<int>>[];
    final cols = <List<int>>[];

    // Generate row clues
    for (final row in puzzle) {
      rows.add(_generateLineClues(row));
    }

    // Generate column clues
    final width = puzzle[0].length;
    for (int x = 0; x < width; x++) {
      final column = puzzle.map((row) => row[x]).toList();
      cols.add(_generateLineClues(column));
    }

    return {'rows': rows, 'cols': cols};
  }

  /// Helper method to generate clues for a single line
  static List<int> _generateLineClues(List<bool> line) {
    final clues = <int>[];
    int consecutiveFilled = 0;

    for (final cell in line) {
      if (cell) {
        consecutiveFilled++;
      } else {
        if (consecutiveFilled > 0) {
          clues.add(consecutiveFilled);
          consecutiveFilled = 0;
        }
      }
    }

    if (consecutiveFilled > 0) {
      clues.add(consecutiveFilled);
    }

    return clues.isEmpty ? [0] : clues;
  }

  /// Shuffles a puzzle while maintaining its clues
  /// 
  /// [puzzle] - Original puzzle to shuffle
  /// [preserveClues] - Whether to maintain the same clues (careful shuffling)
  /// 
  /// Returns a new shuffled puzzle
  static List<List<bool>> shufflePuzzle(
    List<List<bool>> puzzle, {
    bool preserveClues = false,
  }) {
    final shuffled = puzzle.map((row) => [...row]).toList();

    if (!preserveClues) {
      // Simple shuffle - randomize all cells
      for (int y = 0; y < shuffled.length; y++) {
        for (int x = 0; x < shuffled[y].length; x++) {
          shuffled[y][x] = _random.nextBool();
        }
      }
    } else {
      // Fisher-Yates shuffle while trying to maintain clue structure
      for (int y = 0; y < shuffled.length; y++) {
        for (int x = shuffled[y].length - 1; x > 0; x--) {
          int randomIndex = _random.nextInt(x + 1);
          final temp = shuffled[y][x];
          shuffled[y][x] = shuffled[y][randomIndex];
          shuffled[y][randomIndex] = temp;
        }
      }
    }

    return shuffled;
  }

  /// Validates if a puzzle is solvable and reasonable
  /// 
  /// [puzzle] - Puzzle to validate
  /// 
  /// Returns true if puzzle appears to be valid
  static bool isValidPuzzle(List<List<bool>> puzzle) {
    if (puzzle.isEmpty || puzzle[0].isEmpty) {
      return false;
    }

    // Check all rows have same length
    final width = puzzle[0].length;
    for (final row in puzzle) {
      if (row.length != width) {
        return false;
      }
    }

    // Check puzzle is not empty or completely filled
    int filledCells = 0;
    for (final row in puzzle) {
      filledCells += row.where((cell) => cell).length;
    }

    final totalCells = puzzle.length * width;
    return filledCells > 0 && filledCells < totalCells;
  }
}
