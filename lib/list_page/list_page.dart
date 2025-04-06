import 'package:baring/list_page/database.dart';
import 'package:baring/list_page/dialog_box.dart';
import 'package:baring/list_page/todo_title.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  String myGoal = "목표 설정하기"; // 기본 목표 셋팅값
  DateTime? selectedDate;

  final _controller = TextEditingController();

  ToDoDataBase db = ToDoDataBase(); // [Hive(Todo) 데이터] db로 설정

  Box goalBox = Hive.box('Goal'); // [Hive(Goal) 데이터] 변수 goalBox로 설정
  Box dateBox = Hive.box('Date'); // [Hive(Date) 데이터] 변수 dateBox로 설정
  Box todoBox = Hive.box('Todo'); // [Hive(Todo) 데이터] 변수 todoBox로 설정

  @override
  void initState() {
    super.initState();

    if (todoBox.get("todo_list") == null) {
      db.createInitialData(); // 초기 데이터 생성
    } else {
      db.loadData(); // 데이터 불러오기
    }

    loadSavedGoal(); // 앱 실행시 [저장한 목표] 불러오기
    loadSavedDate(); // 앱 실행시 [저장한 날짜] 불러오기
  }

  // D-day 계산
  String calculateDday() {
    if (selectedDate == null) return "D-Day";
    final today = DateTime.now();

    // 당일 (연+월+일)
    final onlyDateToday = DateTime(today.year, today.month, today.day);
    // 선택한 날짜 (연+월+일)
    final onlyDateSelected = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
    );

    // 선택한 날짜 - 당일 = 남은 일수
    int daysRemaining = onlyDateSelected.difference(onlyDateToday).inDays;

    // 남은 일수가 0보다 작으면 "D-0"으로 표시
    if (daysRemaining <= 0) return "D-0";

    // 남은 일수  == 0 이면 "D-Day" 아니면 "D-남은일수"
    return daysRemaining == 0 ? "D-Day !!" : "D-$daysRemaining";
  }

  // 목표 입력
  void inputGoal() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('목표'),
          content: TextField(
            controller: controller,
            maxLength: 10,
            decoration: InputDecoration(hintText: '10글자 이하 입력'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                String inputGoal = controller.text.trim(); // 새로운 목표 입력
                if (inputGoal.isNotEmpty && inputGoal.length <= 10) {
                  setState(() {
                    myGoal = inputGoal;
                    goalBox.put('Goal', inputGoal);
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('저장'),
            ),
          ],
        );
      },
    );
  }

  // D-day 설정
  void pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateBox.put('Date', picked.toIso8601String()); // 설정한 날짜 [Date]에 저장
      });
    }
  }

  // 입력한 목표로 저장
  void loadSavedGoal() {
    String? storedGoal = goalBox.get('Goal');
    if (storedGoal != null) {
      setState(() {
        myGoal = storedGoal;
      });
    }
  }

  // 입력한 날짜로 저장
  void loadSavedDate() {
    String? savedDate = dateBox.get('Date');
    if (savedDate != null) {
      setState(() {
        selectedDate = DateTime.parse(savedDate);
      });
    }
  }

  //
  // 체크 박스 변경
  void checkboxChanged(bool? value, int index) {
    setState(() {
      db.todoList[index][1] = !db.todoList[index][1];
    });
    db.updateDataBase();

    // 모든 task 완료 시 축하메시지
    checkAllTasksCompleted();
  }

  // 모든 task 완료 시 축하메시지
  void checkAllTasksCompleted() {
    bool allCompleted = db.todoList.every((task) => task[1] == true);

    if (allCompleted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("축하합니다!"),
            content: SizedBox(
              height: 200, // 높이 조정
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 100, // Lottie 애니메이션 크기 조정
                    child: Row(
                      children: [
                        Lottie.asset("assets/logo/congratulation.json"),
                        Lottie.asset("assets/logo/badge.json"),
                        Lottie.asset("assets/logo/congratulation.json"),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "🥳 모든 할 일을 완료했습니다!",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("확인"),
              ),
            ],
          );
        },
      );
    }
  }

  // 새로운 task 생성
  void createNewTask() {
    if (db.todoList.length >= 3) {
      // 최대 항목 수 제한
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "할 일은 최대 3개까지만 추가할 수 있습니다.",
            style: TextStyle(color: Colors.black),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Color.fromARGB(255, 153, 209, 255),
        ),
      );
      return; // 더 이상 진행하지 않음
    }
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: _controller,
          onSave: saveNewTask,
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  // 새로운 task 를 [db.todoList]에 추가
  void saveNewTask() {
    setState(() {
      db.todoList.add([_controller.text, false]);
      _controller.clear();
    });
    Navigator.of(context).pop();
    db.updateDataBase();
  }

  // task 삭제
  void deleteTask(int index) {
    setState(() {
      db.todoList.removeAt(index);
    });
    db.updateDataBase();
  }

  // 할일 전체 삭제
  void allRemove() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("전체 삭제"),
          content: Text("정말 모든 항목을 삭제하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 취소 버튼
              },
              child: Text("취소"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  db.todoList.clear(); // 리스트 전체 삭제
                });
                db.updateDataBase();
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text("삭제", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/logo/baring_bgremove.png",
              height: 95,
              width: 95,
            ),
            Text(
              'Baring',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              // 설정 버튼 클릭 시 동작
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("설정 기능은 아직 구현되지 않았습니다.")));
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 30),
              Container(
                height: 230,
                width: 230,
                decoration: BoxDecoration(
                  color: Colors.blue[300],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha((0.7 * 255).toInt()),
                      blurRadius: 5,
                      offset: Offset(3, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 30),
                    Text(
                      myGoal,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      selectedDate == null ? "D-Day !!" : calculateDday(),
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(onPressed: inputGoal, child: Text('목표 설정')),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      pickDate();
                    },
                    child: Text('D-day 설정'),
                  ),
                ],
              ),
              SizedBox(height: 70),
              // ElevatedButton(
              //   onPressed: () {
              //     print(goalBox.get('Goal'));
              //     print(dateBox.get('Date'));
              //     print(todoBox.get('todo_list'));
              //   },
              //   child: Text('value'),
              // ),
              Row(
                children: [
                  SizedBox(width: 270),

                  IconButton(onPressed: allRemove, icon: Icon(Icons.delete)),
                  IconButton(onPressed: createNewTask, icon: Icon(Icons.add)),
                ],
              ),
              Container(
                width: 290,
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 153, 209, 255),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha((0.7 * 255).toInt()),
                      blurRadius: 5,
                      offset: Offset(3, 5),
                    ),
                  ],
                ),
                child:
                    db.todoList.isEmpty
                        ? Center(
                          child: Text(
                            "🔥 task 추가하기",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                        : ListView.builder(
                          shrinkWrap: true, // 크기 계산을 허용
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: db.todoList.length,
                          itemBuilder: (context, index) {
                            return TodoTitle(
                              taskName: db.todoList[index][0],
                              taskCompleted: db.todoList[index][1],
                              onChanged: (value) {
                                checkboxChanged(value, index);
                              },
                              deleteFunction: (context) => deleteTask(index),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
