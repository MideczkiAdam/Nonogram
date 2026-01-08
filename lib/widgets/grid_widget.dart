import 'package:flutter/material.dart';

/// Represents the state of a single cell in the grid
enum CellState {
  empty,    // Empty/unresolved cell
  filled,   // Filled cell (black)
  crossed,  // Crossed out cell (marked as empty)
}

/// Grid widget for displaying and editing nonogram puzzles
class GridWidget extends StatefulWidget {
  /// Number of columns in the grid
  final int columns;

  /// Number of rows in the grid
  final int rows;

  /// Initial grid state (optional)
  /// If not provided, all cells start as empty
  final List<List<CellState>>? initialGrid;

  /// Callback when grid state changes
  final void Function(List<List<CellState>> grid)? onGridChanged;

  /// Size of each cell in pixels
  final double cellSize;

  /// Whether the grid is in edit mode
  final bool editMode;

  /// Color for filled cells
  final Color filledColor;

  /// Color for crossed cells
  final Color crossedColor;

  /// Color for empty cells
  final Color emptyColor;

  /// Border color for cells
  final Color borderColor;

  const GridWidget({
    Key? key,
    required this.columns,
    required this.rows,
    this.initialGrid,
    this.onGridChanged,
    this.cellSize = 30.0,
    this.editMode = true,
    this.filledColor = Colors.black87,
    this.crossedColor = const Color(0xFFE0E0E0),
    this.emptyColor = Colors.white,
    this.borderColor = const Color(0xFFBDBDBD),
  }) : super(key: key);

  @override
  State<GridWidget> createState() => _GridWidgetState();
}

class _GridWidgetState extends State<GridWidget> {
  late List<List<CellState>> grid;

  @override
  void initState() {
    super.initState();
    _initializeGrid();
  }

  /// Initialize the grid with provided initial state or empty state
  void _initializeGrid() {
    if (widget.initialGrid != null) {
      grid = List<List<CellState>>.from(
        widget.initialGrid!.map(
          (row) => List<CellState>.from(row),
        ),
      );
    } else {
      grid = List.generate(
        widget.rows,
        (row) => List.generate(
          widget.columns,
          (col) => CellState.empty,
        ),
      );
    }
  }

  /// Toggle cell state on tap
  void _toggleCell(int row, int col) {
    if (!widget.editMode) return;

    setState(() {
      final currentState = grid[row][col];
      grid[row][col] = _getNextCellState(currentState);
    });

    widget.onGridChanged?.call(grid);
  }

  /// Get the next state for a cell in cycle: empty -> filled -> crossed -> empty
  CellState _getNextCellState(CellState current) {
    switch (current) {
      case CellState.empty:
        return CellState.filled;
      case CellState.filled:
        return CellState.crossed;
      case CellState.crossed:
        return CellState.empty;
    }
  }

  /// Get the color for a cell based on its state
  Color _getCellColor(CellState state) {
    switch (state) {
      case CellState.empty:
        return widget.emptyColor;
      case CellState.filled:
        return widget.filledColor;
      case CellState.crossed:
        return widget.crossedColor;
    }
  }

  /// Build a single cell widget
  Widget _buildCell(int row, int col) {
    final state = grid[row][col];
    final color = _getCellColor(state);

    return GestureDetector(
      onTap: () => _toggleCell(row, col),
      child: Container(
        width: widget.cellSize,
        height: widget.cellSize,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: widget.borderColor,
            width: 0.5,
          ),
        ),
        child: state == CellState.crossed
            ? _buildCrossMark()
            : null,
      ),
    );
  }

  /// Build the X mark for crossed cells
  Widget _buildCrossMark() {
    return Center(
      child: CustomPaint(
        size: Size(widget.cellSize * 0.6, widget.cellSize * 0.6),
        painter: _CrossPainter(
          color: Colors.grey[600]!,
        ),
      ),
    );
  }

  /// Clear all cells in the grid
  void _clearGrid() {
    setState(() {
      for (var row = 0; row < widget.rows; row++) {
        for (var col = 0; col < widget.columns; col++) {
          grid[row][col] = CellState.empty;
        }
      }
    });
    widget.onGridChanged?.call(grid);
  }

  /// Fill all cells in the grid
  void _fillGrid() {
    setState(() {
      for (var row = 0; row < widget.rows; row++) {
        for (var col = 0; col < widget.columns; col++) {
          grid[row][col] = CellState.filled;
        }
      }
    });
    widget.onGridChanged?.call(grid);
  }

  /// Get the current grid state
  List<List<CellState>> getGridState() => grid;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Grid display
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.borderColor,
              width: 1.5,
            ),
          ),
          child: Column(
            children: List.generate(
              widget.rows,
              (row) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  widget.columns,
                  (col) => _buildCell(row, col),
                ),
              ),
            ),
          ),
        ),
        // Control buttons (only in edit mode)
        if (widget.editMode)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8.0,
              children: [
                ElevatedButton.icon(
                  onPressed: _fillGrid,
                  icon: const Icon(Icons.format_color_fill),
                  label: const Text('Fill All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _clearGrid,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Custom painter for drawing the X mark on crossed cells
class _CrossPainter extends CustomPainter {
  final Color color;

  _CrossPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Draw diagonal lines to form an X
    canvas.drawLine(
      Offset.zero,
      Offset(size.width, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, 0),
      Offset(0, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CrossPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
