import 'package:flutter/material.dart';

// ignore: must_be_immutable
class TodoTitle extends StatelessWidget {
  String taskName;
  final bool taskCompleted;
  Function(bool?)? onChanged;
  Function(BuildContext)? deleteFunction;

  TodoTitle({
    super.key,
    required this.taskName,
    required this.taskCompleted,
    required this.onChanged,
    required this.deleteFunction,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 길게 누르면 삭제 창 띄우기
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("❌  Task 삭제"),
              content: const Text(
                "\n삭제하시겠습니까? 🤔",
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("취소"),
                ),
                TextButton(
                  onPressed: () {
                    if (deleteFunction != null) {
                      deleteFunction!(context); // context를 전달
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text("삭제"),
                ),
              ],
            );
          },
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            taskName,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              decoration: taskCompleted ? TextDecoration.lineThrough : null,
              decorationThickness: taskCompleted ? 2.3 : null,
            ),
          ),
          Checkbox(
            value: taskCompleted,
            onChanged: onChanged,
            checkColor: Colors.black,
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              }
              return Colors.grey[200];
            }),
            side: const BorderSide(width: 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ],
      ),
    );
  }
}
