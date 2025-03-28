import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DialogBox extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const DialogBox({
    super.key,
    required this.controller,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<DialogBox> createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox> {
  String? errorText;
  bool isSaveEnabled = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      content: SizedBox(
        height: 250,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(height: 20),
            const Text("Don't forget this"),
            const SizedBox(height: 30),
            TextField(
              controller: widget.controller,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: "2글자 이상 10글자 이하",
                errorText: errorText,
              ),
              inputFormatters: [LengthLimitingTextInputFormatter(10)],
              onChanged: (value) {
                if (value.length < 2) {
                  setState(() {
                    errorText = '최소 2자 이상 입력하세요.';
                    isSaveEnabled = false;
                  });
                } else {
                  setState(() {
                    errorText = null;
                    isSaveEnabled = true; // 에러 메시지 제거
                  });
                }
              },
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                MaterialButton(
                  color: const Color.fromARGB(255, 153, 209, 255),
                  onPressed: widget.onCancel,
                  child: const Text("취소"),
                ),
                MaterialButton(
                  color: isSaveEnabled
                      ? const Color.fromARGB(255, 153, 209, 255)
                      : Colors.grey,
                  onPressed: isSaveEnabled ? widget.onSave : null,
                  child: const Text("저장"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
