import 'package:sqflite/sqflite.dart';

class oldmemo {
  final sqlFileName = 'oldmemo.db';
  final table = 'oldmemo_data';
  Database db;
  open() async {
    String path = "${await getDatabasesPath()}/$sqlFileName";
    if (db == null) {
      //如果資料庫內容沒有資料，會先新增資料
      db = await openDatabase(
        path,
        version: 1,
        onCreate: (db, ver) async {
          //version: 1為設定版本號碼，提供資料庫升版或降版使用
          //需要值唯一加 primary key
          await db.execute('''
          Create Table oldmemo_data(
          notes_num INTEGER PRIMARY KEY,
          id TEXT,  
          name TEXT,
          content TEXT,
          created_by TEXT,
          date TEXT,
          finish_status INTEGER
        );
        ''');
        },
        onUpgrade: (Database db, int oldVersion, int newVersion) async {
          // 資料庫升級
        },
      );
    }
    return db;
  }

  insert(Map<String, dynamic> m) async {
    //插入資料
    return await db.insert(
      table, //讓他知道是存入前面的final table = 'oldmemo_data';的表單
      m,
      conflictAlgorithm:
          ConflictAlgorithm.replace, //當資料發生衝突，定義將會採用 replace 覆蓋之前的資料
    );
  }

  queryAll() async {
    //取得資料
    return await db.query(table, columns: null); //如果columns是null，預設值會把所有資料叫回來
  }

  delete(int num) async {
    //刪除資料
    return await db.delete(table, where: 'notes_num = $num');
  }

  updata_checked(int checked, int num) async {
    //更新、修改資料(備忘錄勾勾check)
    Database db = await open();
    return await db.rawUpdate("UPDATE oldmemo_data SET finish_status = '$checked' WHERE notes_num = $num");
  }

  updata_memo_information(String memo_information, int num) async {
    //更新、修改資料(備忘錄內容memo_information)
    Database db = await open();
    return await db.rawUpdate("UPDATE oldmemo_data SET memo_information = '$memo_information' WHERE notes_num = $num");
  }


  Future queryAll_old_memo_information(String date) async {
    //判斷取得相對應日期資料
    Database db = await open();
    var datas = await db.rawQuery("SELECT * FROM oldmemo_data WHERE date = '$date'");
    return datas;
  }


}
