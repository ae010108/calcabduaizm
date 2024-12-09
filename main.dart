import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '';
  String _result = '0';

  void _buttonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _expression = '';
        _result = '0';
      } else if (value == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (value == '=') {
        try {
          _result = _evaluateExpression(_expression).toString();
        } catch (e) {
          _result = 'Error';
        }
      } else if (value == '.') {
        // Bir nechta nuqta qo'shishni cheklash
        if (_expression.isNotEmpty) {
          String lastToken = _getLastToken(_expression);
          if (!lastToken.contains('.')) {
            _expression += value;
          }
        } else {
          _expression = '0.';
        }
      } else {
        _expression += value;
      }
    });
  }

  // Oxirgi tokenni olish (so'nggi raqam yoki operator)
  String _getLastToken(String expression) {
    final parser = RegExp(r'(\d+\.?\d*|[\+\-\*/%])');
    final matches = parser.allMatches(expression);
    return matches.isNotEmpty ? matches.last.group(0)! : '';
  }

  double _evaluateExpression(String expression) {
    final parser = RegExp(r'(\d+\.?\d*|[\+\-\*/%])');
    final matches = parser.allMatches(expression);
    List<String> tokens = matches.map((m) => m.group(0)!).toList();

    // Process percentage (%)
    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i] == '%') {
        if (i > 0 && i < tokens.length - 1) {
          double left = double.parse(tokens[i - 1]);
          double right = double.parse(tokens[i + 1]);
          double result = (left / 100) * right;
          tokens.replaceRange(i - 1, i + 2, [result.toString()]);
          i--;
        } else if (i > 0) {
          double left = double.parse(tokens[i - 1]);
          double result = left / 100.0;
          tokens.replaceRange(i - 1, i + 1, [result.toString()]);
          i--;
        }
      }
    }

    // Perform multiplication and division
    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i] == '*' || tokens[i] == '/') {
        double left = double.parse(tokens[i - 1]);
        double right = double.parse(tokens[i + 1]);
        double result = tokens[i] == '*' ? left * right : left / right;
        tokens.replaceRange(i - 1, i + 2, [result.toString()]);
        i--;
      }
    }

    // Perform addition and subtraction
    double total = double.parse(tokens[0]);
    for (int i = 1; i < tokens.length; i += 2) {
      String operator = tokens[i];
      double operand = double.parse(tokens[i + 1]);
      total = operator == '+' ? total + operand : total - operand;
    }

    return total;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _expression,
                    style: TextStyle(fontSize: 28, color: Colors.grey[400]),
                  ),
                  Text(
                    _result,
                    style: const TextStyle(fontSize: 56, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: GridView.builder(
              itemCount: _buttons.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
              ),
              itemBuilder: (context, index) {
                String value = _buttons[index];
                return GestureDetector(
                  onTap: () => _buttonPressed(value),
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Center(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 36,
                          color: _isOperator(value)
                              ? Colors.lightBlueAccent
                              : Colors.pinkAccent,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  final List<String> _buttons = [
    'C', '⌫', '()', '%',
    '7', '8', '9', '/',
    '4', '5', '6', '*',
    '1', '2', '3', '-',
    '0', '.', '=', '+',
  ];

  bool _isOperator(String value) {
    return ['+', '-', '*', '/', '=', '%'].contains(value);
  }
}
