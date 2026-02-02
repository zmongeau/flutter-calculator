import 'package:flutter/material.dart';
import 'package:expressions/expressions.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _expression = '';
  String _result = '0';
  bool _hasError = false;

  void _onButtonPressed(String value) {
    setState(() {
      _hasError = false;

      if (value == 'C') {
        _clear();
      } else if (value == '=') {
        _calculateResult();
      } else if (value == '←') {
        _backspace();
      } else {
        _addToExpression(value);
      }
    });
  }

  void _clear() {
    _expression = '';
    _result = '0';
    _hasError = false;
  }

  void _backspace() {
    if (_expression.isNotEmpty) {
      _expression = _expression.substring(0, _expression.length - 1);
      _updateResult();
    }
  }

  void _addToExpression(String value) {
    // Prevent leading zeros
    if (_expression.isEmpty && value == '0') {
      return;
    }

    // Prevent multiple operators in a row
    if (_isOperator(value) &&
        _expression.isNotEmpty &&
        _isOperator(_expression[_expression.length - 1])) {
      _expression = _expression.substring(0, _expression.length - 1) + value;
      return;
    }

    _expression += value;
    _updateResult();
  }

  bool _isOperator(String char) {
    return char == '+' ||
        char == '-' ||
        char == '*' ||
        char == '/' ||
        char == '%';
  }

  void _updateResult() {
    if (_expression.isEmpty) {
      _result = '0';
      return;
    }

    try {
      // Only evaluate if the expression looks complete enough
      final trimmedExpression = _expression.trim();
      if (trimmedExpression.isEmpty ||
          _isOperator(trimmedExpression[trimmedExpression.length - 1])) {
        _result = '0';
        return;
      }

      final expression = Expression.parse(trimmedExpression);
      final evaluator = const ExpressionEvaluator();
      final value = evaluator.eval(expression, {});

      if (value is num) {
        // Format the result to remove unnecessary decimal places
        if (value is double && value == value.toInt()) {
          _result = value.toInt().toString();
        } else if (value is double) {
          _result = value
              .toStringAsFixed(10)
              .replaceAll(RegExp(r'0+$'), '')
              .replaceAll(RegExp(r'\.$'), '');
        } else {
          _result = value.toString();
        }
      }
    } catch (e) {
      _result = '0';
    }
  }

  void _calculateResult() {
    try {
      final expression = Expression.parse(_expression);
      final evaluator = const ExpressionEvaluator();
      var evalResult = evaluator.eval(expression, {});
      _result = evalResult.toString();
    } catch (e) {
      _hasError = true;
      _result = 'Error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zack Mongeau'), elevation: 0),
      body: Column(
        children: [
          // Display
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Colors.grey[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Expression Display
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: Text(
                      _expression.isEmpty ? '0' : _expression,
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  // Result Display
                  Text(
                    _result,
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: _hasError ? Colors.red : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Buttons
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: GridView.count(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 5,
                children: [
                  _buildButton('C', Colors.red, Colors.white),
                  _buildButton('←', Colors.orange, Colors.white),
                  _buildButton('/', Colors.blue, Colors.white),
                  _buildButton('*', Colors.blue, Colors.white),
                  _buildButton('7', Colors.grey[300]!, Colors.black),
                  _buildButton('8', Colors.grey[300]!, Colors.black),
                  _buildButton('9', Colors.grey[300]!, Colors.black),
                  _buildButton('-', Colors.blue, Colors.white),
                  _buildButton('4', Colors.grey[300]!, Colors.black),
                  _buildButton('5', Colors.grey[300]!, Colors.black),
                  _buildButton('6', Colors.grey[300]!, Colors.black),
                  _buildButton('+', Colors.blue, Colors.white),
                  _buildButton('1', Colors.grey[300]!, Colors.black),
                  _buildButton('2', Colors.grey[300]!, Colors.black),
                  _buildButton('3', Colors.grey[300]!, Colors.black),
                  _buildButton('=', Colors.green, Colors.white),
                  _buildWideButton('0', Colors.grey[300]!, Colors.black),
                  _buildButton('.', Colors.grey[300]!, Colors.black),
                  _buildButton('%', Colors.blue, Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label, Color bgColor, Color textColor) {
    return ElevatedButton(
      onPressed: () => _onButtonPressed(label),
      style: ElevatedButton.styleFrom(backgroundColor: bgColor),
      child: Text(label, style: TextStyle(color: textColor)),
    );
  }

  Widget _buildWideButton(String label, Color bgColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => _onButtonPressed(label),
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
