import 'package:flutter/material.dart';
import '../models/puzzle.dart';
import '../widgets/grid_editor.dart';
import '../widgets/clue_visualizer.dart';
import '../services/puzzle_service.dart';

class EditorScreen extends StatefulWidget {
  final Puzzle? initialPuzzle;

  const EditorScreen({
    Key? key,
    this.initialPuzzle,
  }) : super(key: key);

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late PuzzleService _puzzleService;
  
  // Puzzle state
  late List<List<bool>> _grid;
  late String _puzzleTitle;
  late String _puzzleDescription;
  late int _gridWidth;
  late int _gridHeight;
  
  // UI state
  bool _isDirty = false;
  bool _isSaving = false;
  int _selectedCellSize = 30;
  
  // Clues cache
  late List<List<int>> _horizontalClues;
  late List<List<int>> _verticalClues;

  @override
  void initState() {
    super.initState();
    _puzzleService = PuzzleService();
    _tabController = TabController(length: 3, vsync: this);
    _initializePuzzle();
  }

  void _initializePuzzle() {
    if (widget.initialPuzzle != null) {
      final puzzle = widget.initialPuzzle!;
      _puzzleTitle = puzzle.title;
      _puzzleDescription = puzzle.description;
      _grid = List.from(puzzle.grid.map((row) => List.from(row)));
      _gridWidth = puzzle.width;
      _gridHeight = puzzle.height;
    } else {
      _puzzleTitle = 'New Puzzle';
      _puzzleDescription = '';
      _gridWidth = 10;
      _gridHeight = 10;
      _grid = List.generate(_gridHeight, (_) => List.generate(_gridWidth, (_) => false));
    }
    _recalculateClues();
  }

  void _recalculateClues() {
    _horizontalClues = _calculateClues(_grid, isHorizontal: true);
    _verticalClues = _calculateClues(_grid, isHorizontal: false);
  }

  List<List<int>> _calculateClues(List<List<bool>> grid, {required bool isHorizontal}) {
    List<List<int>> clues = [];
    
    if (isHorizontal) {
      for (var row in grid) {
        clues.add(_getLineClues(row));
      }
    } else {
      for (int col = 0; col < grid[0].length; col++) {
        List<bool> column = [for (int row = 0; row < grid.length; row++) grid[row][col]];
        clues.add(_getLineClues(column));
      }
    }
    
    return clues;
  }

  List<int> _getLineClues(List<bool> line) {
    List<int> clues = [];
    int count = 0;
    
    for (bool cell in line) {
      if (cell) {
        count++;
      } else if (count > 0) {
        clues.add(count);
        count = 0;
      }
    }
    
    if (count > 0) {
      clues.add(count);
    }
    
    return clues.isEmpty ? [0] : clues;
  }

  void _toggleCell(int row, int col) {
    setState(() {
      _grid[row][col] = !_grid[row][col];
      _isDirty = true;
      _recalculateClues();
    });
  }

  void _fillRectangle(int startRow, int startCol, int endRow, int endCol, bool value) {
    setState(() {
      final minRow = startRow < endRow ? startRow : endRow;
      final maxRow = startRow > endRow ? startRow : endRow;
      final minCol = startCol < endCol ? startCol : endCol;
      final maxCol = startCol > endCol ? startCol : endCol;
      
      for (int i = minRow; i <= maxRow; i++) {
        for (int j = minCol; j <= maxCol; j++) {
          _grid[i][j] = value;
        }
      }
      _isDirty = true;
      _recalculateClues();
    });
  }

  void _clearGrid() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Grid'),
        content: const Text('Are you sure you want to clear the entire grid?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _grid = List.generate(_gridHeight, (_) => List.generate(_gridWidth, (_) => false));
                _isDirty = true;
                _recalculateClues();
              });
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _invertGrid() {
    setState(() {
      for (int i = 0; i < _grid.length; i++) {
        for (int j = 0; j < _grid[i].length; j++) {
          _grid[i][j] = !_grid[i][j];
        }
      }
      _isDirty = true;
      _recalculateClues();
    });
  }

  void _resizeGrid() {
    showDialog(
      context: context,
      builder: (context) {
        int width = _gridWidth;
        int height = _gridHeight;
        
        return AlertDialog(
          title: const Text('Resize Grid'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Width'),
                keyboardType: TextInputType.number,
                onChanged: (value) => width = int.tryParse(value) ?? _gridWidth,
                controller: TextEditingController(text: _gridWidth.toString()),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Height'),
                keyboardType: TextInputType.number,
                onChanged: (value) => height = int.tryParse(value) ?? _gridHeight,
                controller: TextEditingController(text: _gridHeight.toString()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (width > 0 && height > 0 && width <= 50 && height <= 50) {
                  setState(() {
                    _gridWidth = width;
                    _gridHeight = height;
                    _grid = List.generate(
                      height,
                      (i) => List.generate(
                        width,
                        (j) => i < _grid.length && j < _grid[i].length ? _grid[i][j] : false,
                      ),
                    );
                    _isDirty = true;
                    _recalculateClues();
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Grid size must be between 1 and 50')),
                  );
                }
              },
              child: const Text('Resize'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _savePuzzle() async {
    if (_puzzleTitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a puzzle title')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final puzzle = Puzzle(
        id: widget.initialPuzzle?.id,
        title: _puzzleTitle,
        description: _puzzleDescription,
        grid: _grid,
        width: _gridWidth,
        height: _gridHeight,
        difficulty: _calculateDifficulty(),
        createdAt: widget.initialPuzzle?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _puzzleService.savePuzzle(puzzle);
      
      if (mounted) {
        setState(() => _isDirty = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Puzzle saved successfully')),
        );
        Navigator.pop(context, puzzle);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving puzzle: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _calculateDifficulty() {
    final filledCells = _grid.fold<int>(
      0,
      (sum, row) => sum + row.where((cell) => cell).length,
    );
    final totalCells = _gridWidth * _gridHeight;
    final fillPercentage = (filledCells / totalCells) * 100;

    if (fillPercentage < 20) return 'Easy';
    if (fillPercentage < 50) return 'Medium';
    if (fillPercentage < 80) return 'Hard';
    return 'Expert';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isDirty) {
          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Unsaved Changes'),
              content: const Text('You have unsaved changes. Do you want to leave?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Keep Editing'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Discard', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
          return shouldExit ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Puzzle Editor'),
          elevation: 0,
          actions: [
            if (_isDirty)
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Chip(
                    label: const Text('Unsaved'),
                    backgroundColor: Colors.orange.withOpacity(0.2),
                    labelStyle: const TextStyle(color: Colors.orange),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'clear':
                      _clearGrid();
                      break;
                    case 'invert':
                      _invertGrid();
                      break;
                    case 'resize':
                      _resizeGrid();
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(
                    value: 'clear',
                    child: Text('Clear Grid'),
                  ),
                  const PopupMenuItem(
                    value: 'invert',
                    child: Text('Invert Grid'),
                  ),
                  const PopupMenuItem(
                    value: 'resize',
                    child: Text('Resize Grid'),
                  ),
                ],
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Edit'),
              Tab(text: 'Clues'),
              Tab(text: 'Details'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Edit Tab
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Grid Size Info
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      const Text('Width', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                      Text('$_gridWidth', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Text('Height', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                      Text('$_gridHeight', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Text('Filled', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                      Text(
                                        '${_grid.fold<int>(0, (sum, row) => sum + row.where((cell) => cell).length)}',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Cell Size Slider
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.zoom_out, size: 20),
                                Expanded(
                                  child: Slider(
                                    value: _selectedCellSize.toDouble(),
                                    min: 15,
                                    max: 50,
                                    onChanged: (value) {
                                      setState(() => _selectedCellSize = value.toInt());
                                    },
                                  ),
                                ),
                                const Icon(Icons.zoom_in, size: 20),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text('${_selectedCellSize}px'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Grid Editor
                          GridEditor(
                            grid: _grid,
                            cellSize: _selectedCellSize.toDouble(),
                            onCellToggled: _toggleCell,
                            onRectangleFilled: _fillRectangle,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Clues Tab
            ClueVisualizer(
              horizontalClues: _horizontalClues,
              verticalClues: _verticalClues,
              gridWidth: _gridWidth,
              gridHeight: _gridHeight,
            ),
            // Details Tab
            _buildDetailsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _isSaving ? null : _savePuzzle,
          icon: _isSaving ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ) : const Icon(Icons.save),
          label: Text(_isSaving ? 'Saving...' : 'Save'),
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Puzzle Title',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter puzzle title',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            onChanged: (value) => setState(() => _puzzleTitle = value),
            controller: TextEditingController(text: _puzzleTitle),
          ),
          const SizedBox(height: 24),
          const Text(
            'Description',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter puzzle description (optional)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            maxLines: 4,
            onChanged: (value) => setState(() => _puzzleDescription = value),
            controller: TextEditingController(text: _puzzleDescription),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Puzzle Statistics',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    'Grid Size',
                    '$_gridWidth × $_gridHeight (${_gridWidth * _gridHeight} cells)',
                  ),
                  _buildStatRow(
                    'Filled Cells',
                    '${_grid.fold<int>(0, (sum, row) => sum + row.where((cell) => cell).length)}/${_gridWidth * _gridHeight}',
                  ),
                  _buildStatRow(
                    'Fill Percentage',
                    '${(((_grid.fold<int>(0, (sum, row) => sum + row.where((cell) => cell).length)) / (_gridWidth * _gridHeight)) * 100).toStringAsFixed(1)}%',
                  ),
                  _buildStatRow(
                    'Difficulty',
                    _calculateDifficulty(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (widget.initialPuzzle != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Puzzle Info',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      'ID',
                      widget.initialPuzzle!.id ?? 'N/A',
                    ),
                    _buildStatRow(
                      'Created',
                      _formatDateTime(widget.initialPuzzle!.createdAt),
                    ),
                    _buildStatRow(
                      'Updated',
                      _formatDateTime(widget.initialPuzzle!.updatedAt),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
