import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

/// Model class for puzzle statistics
class PuzzleStats {
  final String puzzleId;
  final String title;
  final int width;
  final int height;
  final DateTime createdAt;
  final DateTime? lastPlayedAt;
  final DateTime? completedAt;
  final int timesPlayed;
  final int timesCompleted;
  final Duration totalTimeSpent;
  final Duration? bestTime;
  final bool isFavorite;

  PuzzleStats({
    required this.puzzleId,
    required this.title,
    required this.width,
    required this.height,
    required this.createdAt,
    this.lastPlayedAt,
    this.completedAt,
    this.timesPlayed = 0,
    this.timesCompleted = 0,
    this.totalTimeSpent = Duration.zero,
    this.bestTime,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() => {
    'puzzleId': puzzleId,
    'title': title,
    'width': width,
    'height': height,
    'createdAt': createdAt.toIso8601String(),
    'lastPlayedAt': lastPlayedAt?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'timesPlayed': timesPlayed,
    'timesCompleted': timesCompleted,
    'totalTimeSpent': totalTimeSpent.inSeconds,
    'bestTime': bestTime?.inSeconds,
    'isFavorite': isFavorite,
  };

  factory PuzzleStats.fromJson(Map<String, dynamic> json) => PuzzleStats(
    puzzleId: json['puzzleId'] as String,
    title: json['title'] as String,
    width: json['width'] as int,
    height: json['height'] as int,
    createdAt: DateTime.parse(json['createdAt'] as String),
    lastPlayedAt: json['lastPlayedAt'] != null
        ? DateTime.parse(json['lastPlayedAt'] as String)
        : null,
    completedAt: json['completedAt'] != null
        ? DateTime.parse(json['completedAt'] as String)
        : null,
    timesPlayed: json['timesPlayed'] as int? ?? 0,
    timesCompleted: json['timesCompleted'] as int? ?? 0,
    totalTimeSpent: Duration(seconds: json['totalTimeSpent'] as int? ?? 0),
    bestTime: json['bestTime'] != null
        ? Duration(seconds: json['bestTime'] as int)
        : null,
    isFavorite: json['isFavorite'] as bool? ?? false,
  );

  /// Create a copy of this stats object with some fields replaced
  PuzzleStats copyWith({
    String? puzzleId,
    String? title,
    int? width,
    int? height,
    DateTime? createdAt,
    DateTime? lastPlayedAt,
    DateTime? completedAt,
    int? timesPlayed,
    int? timesCompleted,
    Duration? totalTimeSpent,
    Duration? bestTime,
    bool? isFavorite,
  }) =>
      PuzzleStats(
        puzzleId: puzzleId ?? this.puzzleId,
        title: title ?? this.title,
        width: width ?? this.width,
        height: height ?? this.height,
        createdAt: createdAt ?? this.createdAt,
        lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
        completedAt: completedAt ?? this.completedAt,
        timesPlayed: timesPlayed ?? this.timesPlayed,
        timesCompleted: timesCompleted ?? this.timesCompleted,
        totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
        bestTime: bestTime ?? this.bestTime,
        isFavorite: isFavorite ?? this.isFavorite,
      );
}

/// Model class for puzzle progress/save state
class PuzzleProgress {
  final String puzzleId;
  final List<List<int>> gridState; // 0 = empty, 1 = filled, 2 = crossed
  final DateTime lastSavedAt;
  final Duration timeSinceStart;

  PuzzleProgress({
    required this.puzzleId,
    required this.gridState,
    required this.lastSavedAt,
    required this.timeSinceStart,
  });

  Map<String, dynamic> toJson() => {
    'puzzleId': puzzleId,
    'gridState': gridState,
    'lastSavedAt': lastSavedAt.toIso8601String(),
    'timeSinceStart': timeSinceStart.inSeconds,
  };

  factory PuzzleProgress.fromJson(Map<String, dynamic> json) => PuzzleProgress(
    puzzleId: json['puzzleId'] as String,
    gridState: List<List<int>>.from(
      (json['gridState'] as List).map(
        (row) => List<int>.from(row as List),
      ),
    ),
    lastSavedAt: DateTime.parse(json['lastSavedAt'] as String),
    timeSinceStart: Duration(seconds: json['timeSinceStart'] as int),
  );
}

/// Service for managing puzzle files, persistence, and statistics
class PuzzleService {
  static final PuzzleService _instance = PuzzleService._internal();

  late Directory _appDocDir;
  late Directory _puzzlesDir;
  late Directory _progressDir;
  late File _statsFile;

  final Map<String, PuzzleStats> _statsCache = {};
  final Map<String, PuzzleProgress> _progressCache = {};

  PuzzleService._internal();

  factory PuzzleService() => _instance;

  /// Initialize the puzzle service and create necessary directories
  Future<void> initialize() async {
    _appDocDir = await getApplicationDocumentsDirectory();
    _puzzlesDir = Directory('${_appDocDir.path}/puzzles');
    _progressDir = Directory('${_appDocDir.path}/progress');
    _statsFile = File('${_appDocDir.path}/puzzle_stats.json');

    // Create directories if they don't exist
    if (!await _puzzlesDir.exists()) {
      await _puzzlesDir.create(recursive: true);
    }
    if (!await _progressDir.exists()) {
      await _progressDir.create(recursive: true);
    }

    // Load existing statistics
    await _loadStatsFromDisk();
  }

  /// Save a puzzle file to local storage
  Future<void> savePuzzle(
    String puzzleId,
    String title,
    int width,
    int height,
    List<List<int>> solution,
  ) async {
    final puzzleFile = File('${_puzzlesDir.path}/$puzzleId.json');
    final puzzleData = {
      'id': puzzleId,
      'title': title,
      'width': width,
      'height': height,
      'solution': solution,
      'createdAt': DateTime.now().toIso8601String(),
    };

    await puzzleFile.writeAsString(jsonEncode(puzzleData));

    // Initialize stats if not already present
    if (!_statsCache.containsKey(puzzleId)) {
      _statsCache[puzzleId] = PuzzleStats(
        puzzleId: puzzleId,
        title: title,
        width: width,
        height: height,
        createdAt: DateTime.now(),
      );
      await _saveStatsToDisk();
    }
  }

  /// Load a puzzle by ID
  Future<Map<String, dynamic>?> loadPuzzle(String puzzleId) async {
    final puzzleFile = File('${_puzzlesDir.path}/$puzzleId.json');

    if (!await puzzleFile.exists()) {
      return null;
    }

    try {
      final contents = await puzzleFile.readAsString();
      return jsonDecode(contents) as Map<String, dynamic>;
    } catch (e) {
      print('Error loading puzzle: $e');
      return null;
    }
  }

  /// Get all available puzzles
  Future<List<Map<String, dynamic>>> getAllPuzzles() async {
    final puzzles = <Map<String, dynamic>>[];

    try {
      final files = _puzzlesDir.listSync();
      for (var file in files) {
        if (file is File && file.path.endsWith('.json')) {
          final contents = await file.readAsString();
          puzzles.add(jsonDecode(contents) as Map<String, dynamic>);
        }
      }
    } catch (e) {
      print('Error getting all puzzles: $e');
    }

    return puzzles;
  }

  /// Save puzzle progress/state
  Future<void> saveProgress(
    String puzzleId,
    List<List<int>> gridState,
    Duration timeSinceStart,
  ) async {
    final progress = PuzzleProgress(
      puzzleId: puzzleId,
      gridState: gridState,
      lastSavedAt: DateTime.now(),
      timeSinceStart: timeSinceStart,
    );

    _progressCache[puzzleId] = progress;

    final progressFile = File('${_progressDir.path}/$puzzleId.json');
    await progressFile.writeAsString(jsonEncode(progress.toJson()));
  }

  /// Load puzzle progress by ID
  Future<PuzzleProgress?> loadProgress(String puzzleId) async {
    // Check cache first
    if (_progressCache.containsKey(puzzleId)) {
      return _progressCache[puzzleId];
    }

    final progressFile = File('${_progressDir.path}/$puzzleId.json');

    if (!await progressFile.exists()) {
      return null;
    }

    try {
      final contents = await progressFile.readAsString();
      final progress = PuzzleProgress.fromJson(
        jsonDecode(contents) as Map<String, dynamic>,
      );
      _progressCache[puzzleId] = progress;
      return progress;
    } catch (e) {
      print('Error loading progress: $e');
      return null;
    }
  }

  /// Clear progress for a puzzle
  Future<void> clearProgress(String puzzleId) async {
    final progressFile = File('${_progressDir.path}/$puzzleId.json');
    if (await progressFile.exists()) {
      await progressFile.delete();
    }
    _progressCache.remove(puzzleId);
  }

  /// Update puzzle statistics when puzzle is played
  Future<void> recordPuzzlePlay(String puzzleId) async {
    if (_statsCache.containsKey(puzzleId)) {
      final stats = _statsCache[puzzleId]!;
      _statsCache[puzzleId] = stats.copyWith(
        timesPlayed: stats.timesPlayed + 1,
        lastPlayedAt: DateTime.now(),
      );
      await _saveStatsToDisk();
    }
  }

  /// Update puzzle statistics when puzzle is completed
  Future<void> recordPuzzleCompletion(
    String puzzleId,
    Duration timeSpent,
  ) async {
    if (_statsCache.containsKey(puzzleId)) {
      final stats = _statsCache[puzzleId]!;
      final newBestTime = stats.bestTime == null || timeSpent < stats.bestTime!
          ? timeSpent
          : stats.bestTime;

      _statsCache[puzzleId] = stats.copyWith(
        timesCompleted: stats.timesCompleted + 1,
        completedAt: DateTime.now(),
        totalTimeSpent: stats.totalTimeSpent + timeSpent,
        bestTime: newBestTime,
      );
      await _saveStatsToDisk();
    }
  }

  /// Toggle favorite status for a puzzle
  Future<void> toggleFavorite(String puzzleId) async {
    if (_statsCache.containsKey(puzzleId)) {
      final stats = _statsCache[puzzleId]!;
      _statsCache[puzzleId] = stats.copyWith(
        isFavorite: !stats.isFavorite,
      );
      await _saveStatsToDisk();
    }
  }

  /// Get statistics for a specific puzzle
  PuzzleStats? getPuzzleStats(String puzzleId) {
    return _statsCache[puzzleId];
  }

  /// Get all puzzle statistics
  List<PuzzleStats> getAllStats() {
    return _statsCache.values.toList();
  }

  /// Get favorite puzzles
  List<PuzzleStats> getFavoritePuzzles() {
    return _statsCache.values.where((stats) => stats.isFavorite).toList();
  }

  /// Get recently played puzzles
  List<PuzzleStats> getRecentlyPlayed({int limit = 10}) {
    final recent = _statsCache.values
        .where((stats) => stats.lastPlayedAt != null)
        .toList();
    recent.sort((a, b) => b.lastPlayedAt!.compareTo(a.lastPlayedAt!));
    return recent.take(limit).toList();
  }

  /// Get completed puzzles
  List<PuzzleStats> getCompletedPuzzles() {
    return _statsCache.values.where((stats) => stats.completedAt != null).toList();
  }

  /// Get statistics summary
  Map<String, dynamic> getStatisticsSummary() {
    final allStats = _statsCache.values.toList();
    final completedStats = allStats.where((s) => s.completedAt != null).toList();

    int totalPlayed = 0;
    int totalCompleted = 0;
    Duration totalTime = Duration.zero;
    Duration? bestTime;

    for (var stats in allStats) {
      totalPlayed += stats.timesPlayed;
      totalCompleted += stats.timesCompleted;
      totalTime += stats.totalTimeSpent;

      if (stats.bestTime != null) {
        bestTime = bestTime == null || stats.bestTime! < bestTime
            ? stats.bestTime
            : bestTime;
      }
    }

    final completionRate = totalPlayed > 0
        ? (totalCompleted / totalPlayed * 100).toStringAsFixed(1)
        : '0.0';

    return {
      'totalPuzzles': allStats.length,
      'completedPuzzles': completedStats.length,
      'totalPlayed': totalPlayed,
      'totalCompleted': totalCompleted,
      'completionRate': '$completionRate%',
      'totalTimeSpent': _formatDuration(totalTime),
      'bestTime': bestTime != null ? _formatDuration(bestTime) : 'N/A',
      'favoritePuzzles': allStats.where((s) => s.isFavorite).length,
    };
  }

  /// Export all data as JSON
  Future<String> exportAllData() async {
    final allStats = getAllStats();
    final data = {
      'exportedAt': DateTime.now().toIso8601String(),
      'statistics': allStats.map((s) => s.toJson()).toList(),
      'summary': getStatisticsSummary(),
    };
    return jsonEncode(data);
  }

  /// Delete a puzzle and all associated data
  Future<void> deletePuzzle(String puzzleId) async {
    // Delete puzzle file
    final puzzleFile = File('${_puzzlesDir.path}/$puzzleId.json');
    if (await puzzleFile.exists()) {
      await puzzleFile.delete();
    }

    // Delete progress file
    final progressFile = File('${_progressDir.path}/$puzzleId.json');
    if (await progressFile.exists()) {
      await progressFile.delete();
    }

    // Remove from caches
    _statsCache.remove(puzzleId);
    _progressCache.remove(puzzleId);

    // Save updated stats
    await _saveStatsToDisk();
  }

  /// Clear all data (use with caution)
  Future<void> clearAllData() async {
    try {
      if (await _puzzlesDir.exists()) {
        await _puzzlesDir.delete(recursive: true);
      }
      if (await _progressDir.exists()) {
        await _progressDir.delete(recursive: true);
      }
      if (await _statsFile.exists()) {
        await _statsFile.delete();
      }

      _statsCache.clear();
      _progressCache.clear();

      // Recreate directories
      await _puzzlesDir.create(recursive: true);
      await _progressDir.create(recursive: true);
    } catch (e) {
      print('Error clearing all data: $e');
    }
  }

  /// Load statistics from disk
  Future<void> _loadStatsFromDisk() async {
    try {
      if (await _statsFile.exists()) {
        final contents = await _statsFile.readAsString();
        final jsonData = jsonDecode(contents) as List;
        for (var statJson in jsonData) {
          final stats = PuzzleStats.fromJson(statJson as Map<String, dynamic>);
          _statsCache[stats.puzzleId] = stats;
        }
      }
    } catch (e) {
      print('Error loading stats from disk: $e');
    }
  }

  /// Save statistics to disk
  Future<void> _saveStatsToDisk() async {
    try {
      final jsonData = _statsCache.values.map((s) => s.toJson()).toList();
      await _statsFile.writeAsString(jsonEncode(jsonData));
    } catch (e) {
      print('Error saving stats to disk: $e');
    }
  }

  /// Format duration to human-readable string
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '$hours h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '$minutes m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
