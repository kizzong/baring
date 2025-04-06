import 'package:baring/list_page/list_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('Goal'); // 목표
  await Hive.openBox('Date'); // 목표 D-day

  await Hive.openBox('Todo'); // Todo List

  runApp(Baring());
}

class Baring extends StatefulWidget {
  const Baring({super.key});

  @override
  State<Baring> createState() => _BaringState();
}

class _BaringState extends State<Baring> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: ListPage());
  }
}
