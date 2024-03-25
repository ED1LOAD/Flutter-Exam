import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((r - ds.abs() * r) - r).round(),
      g + ((g - ds.abs() * g) - g).round(),
      b + ((b - ds.abs() * b) - b).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  ThemeData _themeData = ThemeData(
    primarySwatch: Colors.blue,
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.grey),
  );

  void _updateTheme(Color color) {
    setState(() {
      _themeData = ThemeData(
        primarySwatch: createMaterialColor(color),
        colorScheme:
            ColorScheme.fromSwatch(primarySwatch: createMaterialColor(color))
                .copyWith(secondary: color),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _themeData,
      home: MainScreen(updateTheme: _updateTheme),
    );
  }
}

class MainScreen extends StatefulWidget {
  final Function(Color) updateTheme;

  const MainScreen({super.key, required this.updateTheme});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int selectedColor = 0;
  int selectedResult = 0;
  int selectedTransition = 0;
  final random = math.Random();

  Color getColor(int index) {
    switch (index) {
      case 1:
        return Colors.pink;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  void selectRandomOptions() {
    setState(() {
      selectedColor = random.nextInt(3) + 1;
      selectedResult = random.nextInt(2) + 1;
      selectedTransition = random.nextInt(3) + 1;
    });
    widget.updateTheme(getColor(selectedColor));
  }

  void showResult(BuildContext context) {
    final resultText =
        'Цвет: ${['Розовый', 'Желтый', 'Зеленый'][selectedColor - 1]}, '
        'Результат: ${['Dialog', 'SnackBar'][selectedResult - 1]}, '
        'Переход: ${[
      'Снизу Вверх',
      'Сверху Вниз',
      'Справо Налево'
    ][selectedTransition - 1]}';
    if (selectedResult == 1) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Результат'),
            content: Text(resultText),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    } else if (selectedResult == 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultText),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void navigateToCriteria() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => CriteriaScreen(
          color: ['Розовый', 'Желтый', 'Зеленый'][selectedColor - 1],
          result: ['Dialog', 'SnackBar'][selectedResult - 1],
          transition: [
            'Снизу Вверх',
            'Сверху Вниз',
            'Справо Налево'
          ][selectedTransition - 1],
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return slideTransition(animation, child, selectedTransition);
        },
      ),
    );
  }

  Widget slideTransition(
      Animation<double> animation, Widget child, int transition) {
    Offset begin;
    switch (transition) {
      case 1:
        begin = const Offset(0.0, 1.0);
        break;
      case 2:
        begin = const Offset(0.0, -1.0);
        break;
      case 3:
        begin = const Offset(1.0, 0.0);
        break;
      default:
        begin = Offset.zero;
    }
    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: Offset.zero,
      ).animate(animation),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Экзамен Flutter'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ChoiceSection(
              title: 'Основной цвет',
              choices: const ['Розовый', 'Желтый', 'Зеленый'],
              selected: selectedColor,
              onSelectionChanged: (int index) {
                setState(() {
                  selectedColor = index;
                });
                widget.updateTheme(getColor(selectedColor));
              },
            ),
            ChoiceSection(
              title: 'Показ результата',
              choices: const ['Dialog', 'SnackBar'],
              selected: selectedResult,
              onSelectionChanged: (int index) {
                setState(() {
                  selectedResult = index;
                });
              },
            ),
            ChoiceSection(
              title: 'Переход между экранами',
              choices: const ['Снизу Вверх', 'Сверху Вниз', 'Справо Налево'],
              selected: selectedTransition,
              onSelectionChanged: (int index) {
                setState(() {
                  selectedTransition = index;
                });
              },
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: selectRandomOptions,
              child: const Text('Подобрать вариант'),
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: navigateToCriteria,
              child: const Text('Открыть критерии'),
            ),
            const SizedBox(
              height: 10,
            ),
            if (selectedColor != 0 &&
                selectedResult != 0 &&
                selectedTransition != 0)
              ElevatedButton(
                onPressed: () => showResult(context),
                child: const Text('Открыть Dialog/SnackBar'),
              ),
          ],
        ),
      ),
    );
  }
}

class ChoiceSection extends StatelessWidget {
  final String title;
  final List<String> choices;
  final int selected;
  final Function(int) onSelectionChanged;

  const ChoiceSection({
    super.key,
    required this.title,
    required this.choices,
    required this.selected,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: List<Widget>.generate(
              choices.length,
              (int index) {
                return ChoiceChip(
                  label: Text(choices[index]),
                  selected: selected == index + 1,
                  onSelected: (bool selected) {
                    onSelectionChanged(index + 1);
                  },
                  backgroundColor: Colors.grey.shade200,
                  selectedColor: Theme.of(context).colorScheme.secondary,
                );
              },
            ).toList(),
          ),
        ],
      ),
    );
  }
}

class CriteriaScreen extends StatelessWidget {
  final String color;
  final String result;
  final String transition;

  const CriteriaScreen({
    super.key,
    required this.color,
    required this.result,
    required this.transition,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Критерии'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Выбранный цвет: $color",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text("Результат: $result", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text("Анимация перехода: $transition",
                style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
