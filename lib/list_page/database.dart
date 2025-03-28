import 'package:hive_flutter/hive_flutter.dart';

class ToDoDataBase {
  List todoList = [];

  Box todoBox = Hive.box('Todo'); // [Hive(Todo) 데이터] 변수 todoBox로 설정

  void createInitialData() {
    todoList = [
      ["할 일 적기", true],
      ["꾹 눌러 삭제하기", false],
      ["다시 할일 적기", false],
    ];
  }

  void loadData() {
    todoList = todoBox.get("todo_list");
  }

  void updateDataBase() {
    todoBox.put("todo_list", todoList);
  }
}
