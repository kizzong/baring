import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:subme2/list_page/list_page.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('Goal'); // 목표
  await Hive.openBox('Date'); // 목표 D-day

  runApp(SubMe());
}

class SubMe extends StatefulWidget {
  const SubMe({super.key});

  @override
  State<SubMe> createState() => _SubMeState();
}

class _SubMeState extends State<SubMe> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ListPage(),
    );
  }
}
