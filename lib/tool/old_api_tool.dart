//連接自行架設的伺服器

import 'dart:convert';
import 'package:newsafer/services/geolocator_service.dart';
import 'package:date_format/date_format.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newsafer/tool/debug.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

const domin = 'https://www.r-dap.com/'; //網域
const notes = domin + 'api/auth/notes/'; //共同notes

class ApiTool_old_memo {
/* ------------------------------ 備忘錄主頁（自己） ----------------------------- */

/* ------------------------------ 備忘錄主頁（給別人） ----------------------------- */

/* ------------------------------ 備忘錄刪除 ----------------------------- */
  static deleteMemo(String notesnum) async {
    Dio dio = Dio();
    final String pathUrl = notes + 'delete/' + '{notes_num}';
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String token = preferences.getString('userToken');
    var data = {'notes_num': notesnum};
    var response = await dio.post(
      pathUrl,
      data: data,
      options: Options(headers: {
        'Content-type': 'application/json; charset=UTF-8', //utf-8解碼
        'Authorization': 'Bearer' + token,
      }),
    );
    return response.data;
  }

/* ------------------------------ 修改備忘錄 ----------------------------- */
  static updatatMemo(int notesnum, String content) async {
    Dio dio = Dio();
    final String pathUrl = notes + 'edit/' + '{notes_num}';
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String token = preferences.getString('userToken');
    var data = {'notes_num': notesnum, 'title': '', 'content': content};
    var response = await dio.post(
      pathUrl,
      data: data,
      options: Options(headers: {
        'Content-type': 'application/json; charset=UTF-8', //utf-8解碼
        'Authorization': 'Bearer' + token,
      }),
    );
    return response.data;
  }

/* ------------------------------ 新增備忘錄 ----------------------------- */
  static insertMemo(String toid, String date, String content) async {
    Dio dio = Dio();
    final String pathUrl = notes + 'create';
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String token = preferences.getString('userToken');
    var data = {'toid': toid, 'date': date, 'title': '', 'content': content};
    var response = await dio.post(
      pathUrl,
      data: data,
      options: Options(headers: {
        'Content-type': 'application/json; charset=UTF-8', //utf-8解碼
        'Authorization': 'Bearer' + token,
      }),
    );
    return response.data;
  }

/* ------------------------------ 備忘錄完成 ----------------------------- */
  static FinishMemo(String notesnum) async {
    Dio dio = Dio();
    final String pathUrl = notes + 'done/' + '{notes_num}';
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String token = preferences.getString('userToken');
    var data = {'notes_num': notesnum};
    var response = await dio.post(
      pathUrl,
      data: data,
      options: Options(headers: {
        'Content-type': 'application/json; charset=UTF-8', //utf-8解碼
        'Authorization': 'Bearer' + token,
      }),
    );
    return response.data;
  }
}
