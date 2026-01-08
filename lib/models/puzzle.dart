import 'package:json_annotation/json_annotation.dart';

part 'puzzle.g.dart';

/// Represents a single Nonogram puzzle with grid, clues, and metadata.
@JsonSerializable()
class Puzzle {
  /// Unique identifier for the puzzle
  final String id;

  /// Title of the puzzle
  final String title;

  /// Description of the puzzle
  final String? description;

  /// Width of the puzzle grid
  final int width;

  /// Height of the puzzle grid
  final int height;

  /// The solution grid represented as a flat list of booleans
  /// true = filled, false = empty
  /// Length should equal width * height
  final List<bool> solution;

  /// Row clues for the puzzle
  /// Each row contains a list of clue numbers
  late final List<List<int>> rowClues;

  /// Column clues for the puzzle
  /// Each column contains a list of clue numbers
  late final List<List<int>> columnClues;

  /// Difficulty level (1-5, where 5 is hardest)
  final int difficulty;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last modified timestamp
  final DateTime? modifiedAt;

  /// Author of the puzzle
  final String? author;

  /// Tags for categorization
  final List<String> tags;

  /// Whether this puzzle is a favorite
  @JsonKey(defaultValue: false)
  final bool isFavorite;

  /// Best completion time in seconds (null if not completed)
  final int? bestTime;

  /// Number of times this puzzle has been played
  @JsonKey(defaultValue: 0)
  final int playCount;

  Puzzle({
    required this.id,
    required this.title,
    this.description,
    required this.width,
    required this.height,
    required this.solution,
    required this.difficulty,
    required this.createdAt,
    this.modifiedAt,
    this.author,
    this.tags = const [],
    this.isFavorite = false,
    this.bestTime,
    this.playCount = 0,
  }) {
    _validateDimensions();
    rowClues = _calculateClues(true);
    columnClues = _calculateClues(false);
  }

  /// Validates that the solution grid dimensions match the specified width and height
  void _validateDimensions() {
    if (solution.length != width * height) {
      throw ArgumentError(
        'Solution length (${solution.length}) does not match width ($width) × height ($height)',
      );
    }
  }

  /// Calculates clues for rows or columns based on the [isRow] parameter
  ///
  /// Returns a list of clue lists, where each inner list represents the consecutive
  /// filled cells in that row or column.
  List<List<int>> _calculateClues(bool isRow) {
    final clues = <List<int>>[];

    if (isRow) {
      for (int row = 0; row < height; row++) {
        final rowData = <bool>[];
        for (int col = 0; col < width; col++) {
          rowData.add(solution[row * width + col]);
        }
        clues.add(_extractClues(rowData));
      }
    } else {
      for (int col = 0; col < width; col++) {
        final colData = <bool>[];
        for (int row = 0; row < height; row++) {
          colData.add(solution[row * width + col]);
        }
        clues.add(_extractClues(colData));
      }
    }

    return clues;
  }

  /// Extracts consecutive clues from a line of cells
  ///
  /// Returns a list of integers representing the sizes of consecutive filled groups.
  /// If the line is empty, returns an empty list.
  /// If all cells are filled, returns [length].
  List<int> _extractClues(List<bool> line) {
    final clues = <int>[];
    int consecutiveCount = 0;

    for (final cell in line) {
      if (cell) {
        consecutiveCount++;
      } else {
        if (consecutiveCount > 0) {
          clues.add(consecutiveCount);
          consecutiveCount = 0;
        }
      }
    }

    // Add the last group if it exists
    if (consecutiveCount > 0) {
      clues.add(consecutiveCount);
    }

    return clues;
  }

  /// Gets a cell value from the solution grid at the specified [row] and [col]
  ///
  /// Returns true if the cell is filled, false otherwise.
  /// Throws [RangeError] if coordinates are out of bounds.
  bool getCell(int row, int col) {
    if (row < 0 || row >= height || col < 0 || col >= width) {
      throw RangeError('Coordinates ($row, $col) are out of bounds for grid ${width}x$height');
    }
    return solution[row * width + col];
  }

  /// Gets the row clues for a specific row index
  ///
  /// Returns a list of integers representing the clues for that row.
  /// Throws [RangeError] if row index is out of bounds.
  List<int> getRowClues(int row) {
    if (row < 0 || row >= height) {
      throw RangeError('Row index $row is out of bounds for height $height');
    }
    return rowClues[row];
  }

  /// Gets the column clues for a specific column index
  ///
  /// Returns a list of integers representing the clues for that column.
  /// Throws [RangeError] if column index is out of bounds.
  List<int> getColumnClues(int col) {
    if (col < 0 || col >= width) {
      throw RangeError('Column index $col is out of bounds for width $width');
    }
    return columnClues[col];
  }

  /// Calculates the difficulty based on grid size and clue complexity
  ///
  /// Returns a difficulty score from 1 to 5.
  int calculateDifficultyScore() {
    // Base difficulty on grid size
    final gridSize = width * height;
    int difficulty = 1;

    if (gridSize > 100) difficulty = 2;
    if (gridSize > 225) difficulty = 3;
    if (gridSize > 400) difficulty = 4;
    if (gridSize > 625) difficulty = 5;

    // Adjust based on clue complexity
    final avgRowClues = rowClues.fold<int>(0, (sum, clues) => sum + clues.length) / height;
    final avgColClues = columnClues.fold<int>(0, (sum, clues) => sum + clues.length) / width;
    final avgClueCount = (avgRowClues + avgColClues) / 2;

    if (avgClueCount > 5) difficulty = (difficulty + 1).clamp(1, 5) as int;

    return difficulty;
  }

  /// Creates a copy of this Puzzle with optional field overrides
  Puzzle copyWith({
    String? id,
    String? title,
    String? description,
    int? width,
    int? height,
    List<bool>? solution,
    int? difficulty,
    DateTime? createdAt,
    DateTime? modifiedAt,
    String? author,
    List<String>? tags,
    bool? isFavorite,
    int? bestTime,
    int? playCount,
  }) {
    return Puzzle(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      width: width ?? this.width,
      height: height ?? this.height,
      solution: solution ?? this.solution,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      author: author ?? this.author,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      bestTime: bestTime ?? this.bestTime,
      playCount: playCount ?? this.playCount,
    );
  }

  /// Converts the Puzzle instance to JSON
  Map<String, dynamic> toJson() => _$PuzzleToJson(this);

  /// Creates a Puzzle instance from JSON
  factory Puzzle.fromJson(Map<String, dynamic> json) => _$PuzzleFromJson(json);

  @override
  String toString() {
    return 'Puzzle(id: $id, title: $title, ${width}x$height, difficulty: $difficulty)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Puzzle &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          width == other.width &&
          height == other.height &&
          solution == other.solution;

  @override
  int get hashCode => Object.hash(id, title, width, height, solution);
}
