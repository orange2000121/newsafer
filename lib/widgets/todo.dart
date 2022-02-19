import 'package:flutter/material.dart';
import 'package:newsafer/tool/people_service.dart';

class Todo {
  final int id;
  final int taskId;
  final String title;
  final int isDone;
  Todo({required this.id, required this.taskId, required this.title, required this.isDone});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'title': title,
      'isDone': isDone,
    };
  }
}

class TodoWidget extends StatelessWidget {
  final String text;
  final bool isDone;
  final int taskId;
  final int id;
  TodoWidget({required this.text, required this.taskId, required this.id, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 8.0,
      ),
      child: Row(
        children: [
          Container(
            width: 20.0,
            height: 20.0,
            margin: EdgeInsets.only(
              right: 12.0,
            ),
            decoration: BoxDecoration(
              color: isDone ? Color(0xFF7349FE) : Colors.transparent,
              borderRadius: BorderRadius.circular(6.0),
              border: isDone ? null : Border.all(color: Color(0xFF86829D), width: 1.5),
            ),
            child: Image(
              image: AssetImage('assets/images/check_icon.png'),
            ),
          ),
          Flexible(
            child: TextField(
              controller: TextEditingController.fromValue(TextEditingValue(
                text: text,
              )),
              onSubmitted: (value) async {
                // Check if the field is not empty
                if (value != "") {
                  if (taskId != 0) {
                    DatabaseHelper _dbHelper = DatabaseHelper();

                    // print(id);
                    await _dbHelper.updateTodotitle(id, value);
                  } else {
                    print("Task doesn't exist");
                  }
                }
              },
              style: TextStyle(
                color: isDone ? Color(0xFF211551) : Color(0xFF86829D),
                fontSize: 16.0,
                fontWeight: isDone ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
