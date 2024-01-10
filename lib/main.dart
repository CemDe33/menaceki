import 'menace1.dart';
import 'menace2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:developer' as developer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Menace KI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Menace(),
    );
  }
}

class Menace extends StatefulWidget {
  const Menace({super.key});

  @override
  State<Menace> createState() => _MenaceState();
}

class _MenaceState extends State<Menace> {
  final List <Color> _colors = [Colors.deepOrange, Colors.black, Colors.blue.shade900, Colors.purple.shade800, Colors.white, Colors.red.shade600, Colors.pink.shade300, Colors.green.shade700, Colors.yellow];
  late List<String> _board = List.filled(9, '');
  String _currentAi = 'menace1';
  List<List<String>> _currentAiList = menace1Moves;
  int _box = 0;
  String _currentPlayer = 'X';
  String _winner = '';

  _nestList(list) {
    List<List<String>> nested = [];
    int currentIndex = 0;

    while (currentIndex < list.length) {
      int endIndex = currentIndex + 3;
      if (endIndex > list.length) {
        endIndex = list.length;
      }

      List<String> sublist = list.sublist(currentIndex, endIndex);
      nested.add(sublist);

      currentIndex += 3;
    }

    return nested;
  }

  _flatList(List<List<String>> list) {
    return list.expand((sublist) => sublist).toList();
  }

  _rotate(List<List<String>> list) {
    int n = list.length;
    List<List<String>> rotatedField = List.generate(n, (_) => List.generate(n, (_) => ' '));

    for (var i = 0; i < n; i++) {
      for (var j = 0; j < n; j++) {
        rotatedField[j][n - 1 - i] = list[i][j];
      }
    }

    return rotatedField;
  }

  _switchAi(String ai) {
    List<List<String>> liste = [];

    if(ai == 'menace1') { liste = menace1Moves; }
    else { liste = menace2Moves; }

    setState(() {
      _currentAiList = liste;
      _currentAi = ai;
    });

    _reset();
    _checkWinner();
  }

  getColor() {
    var color;

    if(_winner != '') {
      color = Colors.grey;
    } else if((_currentAi == 'menace1' && _box == 1) || (_currentAi == 'menace2' && _box >= 1 && _box <= 3)) {
      color = Colors.greenAccent.shade400;
    } else if((_currentAi == 'menace1' && _box >= 2 && _box <= 13) || (_currentAi == 'menace2' && _box >= 4 && _box <= 41)) {
      color = Colors.pink;
    } else if((_currentAi == 'menace1' && _box >= 14 && _box <= 121) || (_currentAi == 'menace2' && _box >=42 && _box <= 194)) {
      color = Colors.yellow;
    } else if((_currentAi == 'menace1' && _box >= 122) || (_currentAi == 'menace2' && _box >= 195)) {
      color = Colors.lightBlue;
    } else {
      color = Colors.grey;
    }

    return color;
  }

  _play(int index) {
    if(_winner == '') {
      late String field = _currentPlayer;
      late String next = _currentPlayer == 'X' ? 'O' : 'X';

      if(_board[index] != '') {
        field = '';
      }

      setState(() {
        _board[index] = field;
        _currentPlayer = next;
      });

      _check();
      _checkWinner();
    }
  }

  _check() {
    int boxNum = 0;
    List<String> board = _board;

    for(var p = 0; p < 8; p++) {
      List<List<String>> nested = _nestList(board);
      if(p == 1) { nested = _rotate(nested); }
      else if(p == 2) { nested = _rotate(nested); }
      else if(p == 3) { nested = _rotate(nested); }
      else if(p == 4) { nested = nested.reversed.toList(); }
      else if(p == 5) { nested = _rotate(nested); }
      else if(p == 6) { nested = _rotate(nested); }
      else if(p == 7) { nested = _rotate(nested); }
      board = _flatList(nested);

      for (int i = 0; i < _currentAiList.length; i++) {
        if(listEquals(board, _currentAiList[i]) == true) {
          boxNum = i + 1;

          setState(() {
            _board = board;
            _box = boxNum;
          });
        }
      }


    }
  }

  _checkWinner() {
    String winner = '';

    for(int i = 0; i < 9; i += 3) {
      if(_board[i] != '' && _board[i] == _board[i + 1] && _board[i + 1] == _board[i + 2]) {
        winner = _board[i];
      }
    }

    for(int i = 0; i < 3; i++) {
      if(_board[i] != '' && _board[i] == _board[i + 3] && _board[i + 3] == _board[i + 6]) {
        winner = _board[i];
      }
    }

    if(_board[0] != '' && _board[0] == _board[4] && _board[4] == _board[8]) {
      winner = _board[0];
    }

    if(_board[2] != '' && _board[2] == _board[4] && _board[4] == _board[6]) {
      winner = _board[2];
    }

    if(winner == 'X') {
      _winner = 'KI gewinnt';
    } else if(winner == 'O') {
      _winner = 'Mensch gewinnt';
    } else if(
      !_board.contains('') ||
      (_checkRowIsDraw(_board[0], _board[1], _board[2]) &&
      _checkRowIsDraw(_board[3], _board[4], _board[5]) &&
      _checkRowIsDraw(_board[6], _board[7], _board[8]) &&
      _checkRowIsDraw(_board[0], _board[3], _board[6]) &&
      _checkRowIsDraw(_board[1], _board[4], _board[7]) &&
      _checkRowIsDraw(_board[2], _board[5], _board[8]) &&
      _checkRowIsDraw(_board[0], _board[4], _board[8]) &&
      _checkRowIsDraw(_board[2], _board[4], _board[6]))
    ) {
      _winner = 'Unentschieden';
    }
  }

  _checkRowIsDraw(fieldOne, fieldTwo, fieldThree) {
    if ((fieldOne != '' && fieldTwo != '' && fieldOne != fieldTwo) ||
        (fieldOne != '' && fieldThree != '' && fieldOne != fieldThree) ||
        (fieldTwo != '' && fieldThree != '' && fieldTwo != fieldThree)) {
      return true;
    } else {
      return false;
    }
  }

  _reset() {
    setState(() {
      _board = List.filled(9, '');
      _currentPlayer = _currentAi == 'menace1' ? 'X' : 'O';
      _winner = '';
      _box = 0;
    });

    _check();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    _check();

    return Scaffold(
      backgroundColor: const Color(0xff1C2733),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Row(
                    children: [
                      Expanded(
                          child: Container(
                              height: 40,
                              margin: const EdgeInsets.only(right: 5.0),
                              child: TextButton(
                                  onPressed: () { _switchAi('menace1'); },
                                  style: ButtonStyle(
                                    backgroundColor: _currentAi == 'menace1' ? MaterialStateProperty.all<Color>(Colors.red) : MaterialStateProperty.all<Color>(Colors.grey),
                                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                  ),
                                  child: const Text('Menace 1')
                              )
                          )
                      ),
                      Expanded(
                          child: Container(
                            height: 40,
                            margin: const EdgeInsets.only(left: 5.0),
                            child: TextButton(
                                onPressed: () { _switchAi('menace2'); },
                                style: ButtonStyle(
                                  backgroundColor: _currentAi == 'menace2' ? MaterialStateProperty.all<Color>(Colors.red) : MaterialStateProperty.all<Color>(Colors.grey),
                                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                ),
                                child: const Text('Menace 2')
                            ),
                          )
                      )
                    ]
                ),
                Container(
                    width: double.infinity,
                    height: 55,
                    margin: const EdgeInsets.only(top: 15.0),
                    decoration: BoxDecoration(
                        color: getColor(),
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Center(
                        child: Text(
                          _winner == '' ? 'Box $_box' : _winner,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 40
                          ),
                        )
                    )
                ),
                Container(
                    margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    padding: const EdgeInsets.only(top: 5.0, bottom: 10.0, left: 10.0, right: 10.0),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: const BorderRadius.all(Radius.circular(10))),
                    child: Column(
                      children: [
                        Text(
                            'KEY',
                            style: TextStyle(
                                color: Colors.grey.shade600,//Color(0xffa60505),
                                fontWeight: FontWeight.bold,
                                fontSize: 66
                            )
                        ),
                        Container(
                          decoration: const BoxDecoration(
                              color: Colors.greenAccent,
                              borderRadius: BorderRadius.all(Radius.circular(10))
                          ),
                          child: GridView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: 9,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 1,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10),
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    _play(index);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: _colors[index],
                                        borderRadius: BorderRadius.circular(10)),
                                    child: _board[index] == ""
                                        ? const SizedBox()
                                        : Center(
                                      child: Text(
                                        _board[index].toLowerCase(),
                                        style: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 80
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                        )
                      ],
                    )
                ),
                TextButton(
                  onPressed: () { _reset(); },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  child: const Text('Zurücksetzen'),
                )
              ],
            ),
          )
        )
      )
    );
  }
}
