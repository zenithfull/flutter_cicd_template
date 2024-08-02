import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My First App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const StarPage(),
    );
  }
}

class StarPage extends StatelessWidget {
  const StarPage([Key? key]) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'スライドパズル',
            style: TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            key: Key('start'),
            onPressed: () => showPuzzlePage(context),
            child: const Text('スタート'),
          )
        ],
      ),
    ));
  }
}

void showPuzzlePage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => PuzzlePage()),
  );
}

class PuzzlePage extends StatefulWidget {
  const PuzzlePage({Key? key}) : super(key: key);

  @override
  _PuzzlePageState createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> {
  List<int> tileNumbers = [1, 2, 3, 4, 5, 6, 7, 8, 0];
  String debugString = '静的解析エラーになる？';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('スライドパズル'),
        actions: [
          IconButton(
            onPressed: () => loadTileNumbers(),
            icon: const Icon(Icons.play_arrow),
          ),
          IconButton(
            onPressed: () => saveTileNumbers(),
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: TilesView(
                  numbers: tileNumbers,
                  isCurrent: calcIsCurrent(tileNumbers),
                  onPressed: (number) => swapTile(number),
                ),
              ),
            ),
            SizedBox(
                width: double.infinity,
                // シャッフルボタン
                child: ElevatedButton.icon(
                  onPressed: () => shuffleTiles(),
                  icon: const Icon(Icons.shuffle),
                  label: const Text('シャッフル'),
                )),
          ],
        ),
      ),
    );
  }

  bool calcIsCurrent(List<int> numbers) {
    final currentNumbers = [1, 2, 3, 4, 5, 6, 7, 8, 0];

    for (int i = 0; i < currentNumbers.length; i++) {
      if (currentNumbers[i] != numbers[i]) {
        return false;
      }
    }

    return true;
  }

  void swapTile(int number) {
    if (canSwapTile(number)) {
      setState(() {
        final indexOfTile = tileNumbers.indexOf(number);
        final indexOfEmpty = tileNumbers.indexOf(0);
        tileNumbers[indexOfTile] = 0;
        tileNumbers[indexOfEmpty] = number;
      });
    }
  }

  bool canSwapTile(int number) {
    final indexOfTile = tileNumbers.indexOf(number);
    final indexOfEmpty = tileNumbers.indexOf(0);

    switch (indexOfEmpty) {
      case 0:
        return [1, 3].contains(indexOfTile);
      case 1:
        return [0, 2, 4].contains(indexOfTile);
      case 2:
        return [1, 3, 5].contains(indexOfTile);
      case 3:
        return [0, 4, 6].contains(indexOfTile);
      case 4:
        return [1, 3, 5, 7].contains(indexOfTile);
      case 5:
        return [2, 4, 8].contains(indexOfTile);
      case 6:
        return [3, 7].contains(indexOfTile);
      case 7:
        return [4, 6, 8].contains(indexOfTile);
      case 8:
        return [5, 7].contains(indexOfTile);
      default:
        return false;
    }
  }

  void shuffleTiles() {
    setState(() {
      tileNumbers.shuffle();
    });
  }

  void saveTileNumbers() async {
    final value = jsonEncode(tileNumbers);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('TILE_NUMBERS', value);
  }

  void loadTileNumbers() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString('TILE_NUMBERS');
    if (value != null) {
      final numbers =
          (jsonDecode(value) as List<dynamic>).map((v) => v as int).toList();
      setState(() {
        tileNumbers = numbers;
      });
    }
  }
}

class TilesView extends StatelessWidget {
  final List<int> numbers;
  final bool isCurrent;
  final void Function(int number) onPressed;

  const TilesView({
    Key? key,
    required this.numbers,
    required this.isCurrent,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      crossAxisSpacing: 24,
      mainAxisSpacing: 24,
      padding: const EdgeInsets.symmetric(vertical: 24),
      children: numbers.map((number) {
        if (number == 0) {
          return Container();
        }
        return TileView(
          number: number,
          color: isCurrent ? Colors.green : Colors.blue,
          onPressed: () => onPressed(number),
        );
      }).toList(),
    );
  }
}

class TileView extends StatelessWidget {
  final int number;
  final Color color;
  final void Function() onPressed;

  const TileView({
    Key? key,
    required this.number,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        textStyle: const TextStyle(fontSize: 32),
      ),
      child: Center(
        child: Text(number.toString()),
      ),
    );
  }
}
