import 'package:baring/main.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final nameBox = Hive.box('Name'); // box 이름과 변수 이름 변경
  final notificationBox = Hive.box('Notification');
  final TextEditingController _controller = TextEditingController();
  bool isNotificationOn = false;

  @override
  void initState() {
    super.initState();
    isNotificationOn = notificationBox.get(
      'isNotificationOn',
      defaultValue: true,
    );
  }

  void toggleNotification(bool value) async {
    setState(() {
      isNotificationOn = value;
      notificationBox.put('isNotificationOn', value);
    });

    if (value) {
      // 알림이 켜질 때 권한 요청
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    _controller.text = nameBox.get('userName', defaultValue: '');

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(), // 왼쪽 뒤로가기 버튼
        title: const Text('설정'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 30),
          Text(
            '${nameBox.get('userName', defaultValue: 'Baring')} 님',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          // 프로필 이름 수정
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: const Text('프로필 수정'),
                leading: const Icon(Icons.person, color: Colors.grey),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('이름'),
                        content: TextField(
                          decoration: const InputDecoration(
                            hintText: '수정할 이름을 입력하세요',
                          ),
                          controller: _controller,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              String newName = _controller.text.trim();
                              if (newName.isNotEmpty) {
                                nameBox.put('userName', newName); // 수정
                                Navigator.pop(context);
                              }
                            },
                            child: const Text('확인'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 15),
          // 알림 설정
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SwitchListTile(
                title: const Text('알림 설정 '),
                secondary: const Icon(Icons.notifications, color: Colors.grey),
                value: isNotificationOn,
                onChanged: toggleNotification,
              ),
            ),
          ),
          const SizedBox(height: 15),
          // 앱 설명 / 인사말
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: const Text('바링 App'),
                leading: const Icon(Icons.info, color: Colors.grey),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('App 소개'),
                        content: SizedBox(
                          height: 700,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '👋 안녕하세요! 바링입니다.',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        '해야 할 일을 잊지 않고, \n'
                                        '간단하게 정리하고 싶은 분들을 위해 바링을 만들었어요.\n',
                                        style: TextStyle(
                                          fontSize: 16,
                                          height: 1.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ExpansionTile(
                                  title: Text(
                                    '📝 왜 Task는 6개 제한인가요?',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: Text(
                                        '처음엔 할 일을 너무 많이 적기보단,\n'
                                        '딱 6개만 집중해서 해보는 게 좋겠다고 생각했어요.\n\n'
                                        '할 일이 많아지면 오히려 하나하나에 집중하기 어려워지고,\n'
                                        '결국 아무것도 제대로 못할 수 있잖아요?\n\n'
                                        '그래서 바링의 테스트 버전에서는\n'
                                        '하루에 6개의 할 일만 등록할 수 있도록 했어요!\n'
                                        '나중에 사용자 반응에 따라 줄이거나 늘려갈 수도 있어요. 😊\n\n',
                                        style: TextStyle(
                                          fontSize: 16,
                                          height: 1.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                ExpansionTile(
                                  title: Text(
                                    '🌟 누적 Task 등급이 뭐예요?',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: Text(
                                        '바링에서는 하루 할 일을 모두 완료하고,\n'
                                        '전체 삭제 버튼을 누르면 누적 task 수가 올라가요! 📈\n\n'
                                        '이 숫자에 따라 작은 리워드나 랭킹 시스템도 준비 중이에요.\n'
                                        '단순히 할 일을 지우는 게 아니라,\n내가 해낸 것들이 하나씩 쌓이는 느낌!\n'
                                        '작지만 성취감을 느껴보세요. 🎉\n\n',
                                        style: TextStyle(
                                          fontSize: 16,
                                          height: 1.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                ExpansionTile(
                                  title: Text(
                                    '🤔 왜 바링을 만들었나요?',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: Text(
                                        '집에 있을 때는 할 일이 떠오르면\n'
                                        '포스트잇에 적고, 하나씩 지우면서 정리하곤 했어요.\n\n'
                                        '그런데 밖에서는 메모장이나 카톡에 적게 되는데,\n'
                                        '이런 앱들은 한 번 적고 나면 잘 안 보게 되더라고요. 😅\n\n'
                                        // '그래서\n'
                                        '“밖에서도 포스트잇처럼 편하게 기록하고,\n'
                                        '눈에 잘 띄게 해주는 앱이 있었으면 좋겠다!\n'
                                        '라고 생각했어요 😁\n\n'
                                        '그렇게 해서 만든 게 바로 할 일 관리 앱, "바링이에요.\n\n'
                                        '할 일이 떠오를 때 바로 기록하고,\n'
                                        '하루에 두 번 알림으로 까먹지 않게 도와주고,\n'
                                        '모두 완료하면 깔끔하게 정리할 수 있도록 만들었어요. 🥳\n\n',
                                        // '어느 날 문득, 밖에 있다가 "아! 이거 해야 하는데…" 싶은 생각이 들었는데\n'
                                        // '카톡에 적자니 어색하고,\n메모장은 찾기 귀찮더라고요. 😅\n\n'
                                        // '그래서, 그냥 할 일을 편하게 적고 체크할 수 있는\n'
                                        // '심플한 앱을 만들자! 해서 탄생한 게 바로 "바링"이에요.\n'
                                        // '생각났을 때 바로 기록하고,\n끝내면 깔끔하게 지울 수 있게 만들었어요. 😁\n\n',
                                        style: TextStyle(
                                          fontSize: 16,
                                          height: 1.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                ExpansionTile(
                                  title: Text(
                                    '🚀 앞으로 바링은...?',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      child: Text(
                                        '테스트 버전 반응이 좋으면,\n이런 기능들도 준비하고 있어요!\n\n'
                                        '1️⃣ 카테고리별 Task 관리 🗂️ \n(학교 일정, 개인 일정, 취미 일정 등)\n\n'
                                        '2️⃣ 성과 캘린더 📅\n(어떤 일을 언제 했는지 한눈에 보기)\n\n'
                                        '3️⃣ 커뮤니티 기능 🧑‍🧑‍🧒‍🧒\n(비슷한 목표를 가진 사람들과 소통)\n\n'
                                        '4️⃣ AI 맞춤 Task 추천 🤖✨\n(목표와 기간에 맞는 할 일 자동 추천)\n\n',
                                        style: TextStyle(
                                          fontSize: 16,
                                          height: 1.8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('확인'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
