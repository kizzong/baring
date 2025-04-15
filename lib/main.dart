import 'package:baring/list_page/list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest_10y.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// 알림 기능을 위한 패키지 선언
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  // 특정 기능 전에 flutter에게 준비 및 초기화 요청
  WidgetsFlutterBinding.ensureInitialized();

  // 전 세계 타임 존 불러오기
  tz.initializeTimeZones();
  // 그 중에 한국 시간 기준으로 설정
  tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

  // 각 플랫폼에 맞는 초기화 설정
  const initializationSettings = InitializationSettings(
    iOS: DarwinInitializationSettings(),
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  );

  // 알람 기능 패키지 안에  위 함수들을 적용해서  앱과 연결
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await Hive.initFlutter();
  await Hive.openBox('Goal'); // 목표
  await Hive.openBox('Date'); // 목표 D-day

  await Hive.openBox('Todo'); // Todo List

  await Hive.openBox('Tasks_Count'); // task 완료 갯수

  await Hive.openBox('Name'); // task List

  await Hive.openBox('Notification'); // 알림 설정

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
