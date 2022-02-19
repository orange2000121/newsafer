import 'dart:convert';
import 'package:newsafer/tool/debug.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../services/marker_map.dart';
import 'package:newsafer/widgets/todo.dart';

class FriendData {
  final sqlFileName = 'people.db';
  final table = 'frienddata';
  open() async {
    String path = "${await getDatabasesPath()}/$sqlFileName";
    return await openDatabase(path, version: 1, onCreate: (db, ver) async {
      //需要值唯一加 primary key
      await db.execute('''
        Create Table frienddata(
          id INTEGER PRIMARY KEY ,
          name TEXT,
          user_id TEXT,
          email TEXT,
          email_verified_at TEXT,
          sex TEXT,
          city TEXT,
          photo BLOB,
          id_can_search INTEGER,
          google_login INTEGER,
          facebook_login INTEGER,
          already_set_password INTEGER,
          created_at TEXT,
          updated_at TEXT
        )
        ''');
    });
  }

  insert(Map<String, dynamic> m) async {
    Database db = await open();
    //插入資料
    return await db.insert(
      table,
      m,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  queryAll() async {
    Database db = await open();
    //取得資料
    return await db.query(table, columns: null);
  }

  Future queryonepeople(int id) async {
    Database db = await open();
    return db.query(table, where: 'id=$id');
  }

  Future<List> querymarker() async {
    Database db = await open();
    //取得資料
    var data = await db.query(table, columns: null);
    Map markerdata = {'name': '', 'latitude': 0.0, 'longitude': 0.0, 'photosticker': BitmapDescriptor};
    List<Map> markerlist = [];
    var len = data.length;
    for (int i = 0; i < len; i++) {
      var photo = await getMarkerIcon(Base64Decoder().convert(data[i]['photosticker']), Size(150, 150));
      markerdata = {'name': data[i]['name'], 'latitude': data[i]['latitude'], 'longitude': data[i]['longitude'], 'photosticker': photo};
      print('markerdata');
      print(markerdata);
      markerlist.add(markerdata);
    }
    print('markerlist');
    print(markerlist);
    // print(markerlist);
    return markerlist;
  }
}

class DatabaseHelper {
  Future<Database> database() async {
    return openDatabase(
      join(await getDatabasesPath(), 'todo.db'),
      onCreate: (db, version) async {
        await db.execute("CREATE TABLE tasks(id INTEGER PRIMARY KEY, title TEXT, description TEXT)");
        await db.execute("CREATE TABLE todo(id INTEGER PRIMARY KEY, taskId INTEGER, title TEXT, isDone INTEGER)");

        return db;
      },
      version: 1,
    );
  }

  Future<void> updateTaskTitle(int id, String title) async {
    Database _db = await database();
    await _db.rawUpdate("UPDATE tasks SET title = '$title' WHERE id = '$id'");
  }

  Future<void> updateTaskDescription(int id, String description) async {
    Database _db = await database();
    await _db.rawUpdate("UPDATE tasks SET description = '$description' WHERE id = '$id'");
  }

  Future<void> insertTodo(Todo todo) async {
    Database _db = await database();
    await _db.insert('todo', todo.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Todo>> getTodo(int taskId) async {
    Database _db = await database();
    List<Map<String, dynamic>> todoMap = await _db.rawQuery("SELECT * FROM todo WHERE taskId = $taskId");
    return List.generate(todoMap.length, (index) {
      return Todo(id: todoMap[index]['id'], title: todoMap[index]['title'], taskId: todoMap[index]['taskId'], isDone: todoMap[index]['isDone']);
    });
  }

  Future<void> updateTodoDone(int id, int isDone) async {
    Database _db = await database();
    await _db.rawUpdate("UPDATE todo SET isDone = '$isDone' WHERE id = '$id'");
  }

  Future<void> updateTodotitle(int id, String title) async {
    Database _db = await database();
    await _db.rawUpdate("UPDATE todo SET title = '$title' WHERE id = '$id'");
  }

  Future<void> deleteTask(int id) async {
    Database _db = await database();
    await _db.rawDelete("DELETE FROM tasks WHERE id = '$id'");
    await _db.rawDelete("DELETE FROM todo WHERE taskId = '$id'");
  }
}

class NotificationData {
  Future<Database> database() async {
    return openDatabase(
      join(await getDatabasesPath(), 'notice.db'),
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE notice(
          title TEXT,
          content TEXT,
          photo BLOB,
          type TEXT,
          data TEXT,
          isopened INTEGER,
          id INTEGER PRIMARY KEY AUTOINCREMENT
        )
      ''');
      },
      version: 1,
    );
  }

  insert(Map<String, dynamic> notice) async {
    Database db = await database();
    await db.insert('notice', notice);
  }

  queryall() async {
    Database db = await database();
    return await db.query('notice', columns: null);
  }
}

class UsermemoDB {
  // ignore: non_constant_identifier_names
  final String name, content, created_by, date;
  // ignore: non_constant_identifier_names
  final int user_id, finish_status, notes_num;
  // ignore: non_constant_identifier_names
  UsermemoDB({this.user_id, required this.name, required this.notes_num, required this.content, required this.created_by, required this.date, required this.finish_status});
  Map<String, dynamic> tomap() {
    return {
      'user_id': user_id, //自己的id
      'name': name, //創建者名字
      'notes_num': notes_num, //備忘錄編號
      'content': content, //備忘錄內容
      'created_by': created_by, //創建者
      'date': date, //備忘錄日期
      'finish_status': finish_status, //完成狀態
    };
  }

//table name :'table'+'$id'
  Future<Database> opendb() async {
    return openDatabase(
      join(await getDatabasesPath(), 'usermemo.db'),
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE memotable(
          user_id INTEGER,
          name TEXT,
          notes_num INTEGER PRIMARY KEY,
          content TEXT,
          created_by TEXT,
          date TEXT,
          finish_status INTEGER
        )
      ''');
      },
      version: 1,
    );
  }

  void insert() async {
    Database db = await opendb();
    db.insert('memotable', tomap());
  }

  Future<List<Map<String, dynamic>>> queryall(String toid) async {
    Database db = await opendb();
    return db.query('memotable', columns: null);
  }

  Future<List<Map<String, dynamic>>> queryonepseson(String toid, String date) async {
    Database db = await opendb();
    printcolor('date:$date', color: DColor.yellow);
    var data = await db.rawQuery("SELECT * FROM memotable WHERE user_id='$toid' AND date='$date'");
    return data;
  }

  void updatacheck(int check, int num) async {
    printcolor('num:$num', color: DColor.yellow);
    Database db = await opendb();
    await db.rawUpdate("UPDATE memotable SET finish_status = '$check' WHERE notes_num = '$num'");
  }

  void editmemoinformation(int num, String memoinformation) async {
    Database db = await opendb();
    await db.rawUpdate("UPDATE memotable SET content = '$memoinformation' WHERE notes_num = '$num'");
  }

  void delet(int num) async {
    Database db = await opendb();
    await db.rawDelete("DELETE FROM memotable WHERE notes_num='$num'");
  }
}
