# Nonogram

A Java-based Nonogram (also known as Picross) puzzle solver and game implementation.

## Overview

Nonogram is a logic puzzle game where you need to fill in cells in a grid based on number clues to reveal a hidden picture. This project provides both a puzzle solver and an interactive game implementation.

## Features

- **Puzzle Solver**: Automatically solves nonogram puzzles using constraint satisfaction algorithms
- **Interactive Game**: Play nonogram puzzles with a user-friendly interface
- **Multiple Difficulty Levels**: Support for various puzzle sizes and complexities
- **Input/Output**: Load puzzles from files and export solutions

## Getting Started

### Prerequisites

- Java JDK 11 or higher
- Maven (for building the project)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/MideczkiAdam/Nonogram.git
cd Nonogram
```

2. Build the project:
```bash
mvn clean build
```

3. Run the application:
```bash
mvn exec:java
```

## Project Structure

```
Nonogram/
├── src/
│   ├── main/
│   │   └── java/
│   │       └── [main source files]
│   └── test/
│       └── java/
│           └── [test files]
├── pom.xml
└── README.md
```

## How to Play

1. Start the game and select a puzzle
2. Use the number clues on the top and left side of the grid
3. Click cells to mark them as filled or empty
4. Complete the puzzle by following the clues
5. The hidden picture will be revealed when the puzzle is solved correctly

## Puzzle Format

Nonogram puzzles consist of:
- A grid of cells (typically 5x5 to 20x20)
- Row clues on the left indicating groups of consecutive filled cells
- Column clues on the top with the same information for columns

## Algorithm

The solver uses constraint propagation and backtracking to solve puzzles efficiently:
1. Analyzes clues to determine cell states
2. Propagates constraints across the grid
3. Uses backtracking when necessary to explore possibilities

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

- **Adam Midzecki** - [GitHub Profile](https://github.com/MideczkiAdam)

## Acknowledgments

- Inspired by classic nonogram puzzle games
- Thanks to the open-source community for various libraries and tools

## Changelog

### Version 1.0.0 (Current)
- Initial project setup
- Basic puzzle solver implementation
- Interactive game interface

## Support

For issues, questions, or suggestions, please open an issue on the GitHub repository.

---

Last updated: 2026-01-08
