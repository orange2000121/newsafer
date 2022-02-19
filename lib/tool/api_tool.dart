//連接自行架設的伺服器

import 'dart:convert';
import 'dart:io';
import 'package:newsafer/services/geolocator_service.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newsafer/tool/debug.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthApi {
  static const domin = 'https://r-dap.com/'; //網域
  static const authip = domin + 'api/auth/'; //共同ip位置
  static Future olderLoginGoogle() async {
    final _googleSignIn = GoogleSignIn();
    Dio dio = new Dio();
    String GooglePathUrl = authip + 'login/older/google/getUserDataFromGoogle';
    GoogleSignInAccount result = await _googleSignIn.signIn();
    var ggAuth = await result.authentication;
    String firebasetoken = await FirebaseMessaging.instance.getToken();
    dynamic data = {'token': ggAuth.accessToken, 'fcm_token': firebasetoken};
    // ignore: non_constant_identifier_names
    var Googleresponse = await dio.post(GooglePathUrl, //post用法
        data: data,
        options: Options(headers: {
          'Content-type': 'application/json; charset=UTF-8', //utf-8解碼
        }));
    SharedPreferences Googlepreferences = await SharedPreferences.getInstance();
    if (Googleresponse.data['userToken'] != null) {
      Googlepreferences.setString('userToken', Googleresponse.data['userToken']);
      //將userData的資料全部存到sharepreferences
      for (data in Map<String, dynamic>.from(Googleresponse.data['userData']).keys) {
        Googlepreferences.setString(data, Googleresponse.data['userData'][data].toString());
      }
    }
    return Googleresponse.data;
  }
}

class ApiTool {
  static const domin = 'https://r-dap.com/'; //網域
  static const authip = domin + 'api/auth/'; //共同ip位置
  static const noticeip = domin + 'api/sendNotification/';
  static const forgotpassword = domin + 'api/auth/resetPasswordEmail/';

  /* ---------------------------------- 登入api --------------------------------- */
  static Future loginpost(String email, String password) async {
    //登入api
    Dio dio = new Dio();
    // final String pathUrl = authip + "login"; //api
    final String pathUrl = 'https://r-dap.com/api/auth/login'; //api

    String firebasetoken = await FirebaseMessaging.instance.getToken();
    dynamic data = {'email': email, 'password': password, 'fcm_token': firebasetoken}; //回傳資料
    var response = await dio.post(pathUrl, //post用法
        data: data,
        options: Options(headers: {
          'Content-type': 'application/json; charset=UTF-8', //utf-8解碼
        }));
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (response.data['userToken'] != null) {
      printcolor('apitool.dart 24:30//  userToken: ${response.data['userToken'].runtimeType}', color: DColor.yellow);

      preferences.setString('userToken', response.data['userToken']);
      printcolor('apitool.dart 27:30//  userToken: ${preferences.getString('userToken')}', color: DColor.yellow);
      //將userData的資料全部存到sharepreferences
      for (data in Map<String, dynamic>.from(response.data['userData']).keys) {
        printcolor('$data: ${response.data['userData'][data].toString()}', color: DColor.yellow);
        preferences.setString(data, response.data['userData'][data].toString());
      }
    }
    return response.data;
  }

/* ------------------------------ facebook登入api ----------------------------- */
  static Future facebookloginpost(String token) async {
    //facebook登入api
    Dio dio = new Dio();
    final String pathUrl = authip + "login/facebook/getUserDataFromFB"; //apid
    String firebasetoken = await FirebaseMessaging.instance.getToken();
    dynamic data = {'token': token, 'fcm_token': firebasetoken}; //post資料
    var response = await dio.post(pathUrl, //post用法
        data: data,
        options: Options(headers: {
          'Content-type': 'application/json; charset=UTF-8', //utf-8解碼
          'Authorization': 'Bearer ' + token,
        }));
    print('response:$response');
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('userToken', response.data['userToken']);
    for (data in Map<String, dynamic>.from(response.data['userData']).keys) {
      printcolor('$data: ${response.data['userData'][data].toString()}', color: DColor.yellow);
      preferences.setString(data, response.data['userData'][data].toString());
    }
    return response.data['userToken'];
  }

/* ---------------------------------- 註冊api --------------------------------- */
  static Future signuppost(String name, String email, String password) async {
    //註冊api
    Dio dio = new Dio();
    final String pathUrl = authip + "signup"; //api

    dynamic data = {'name': name, 'email': email, 'password': password}; //回傳資料
    var response = await dio.post(pathUrl,
        data: data,
        options: Options(headers: {
          'Content-type': 'application/json; charset=UTF-8', //utf-8解碼
        }));
    return (response.data);
  }

/* --------------------------------- 忘記密碼api -------------------------------- */
  static Future forGetMailPost(String email) async {
    //忘記密碼api
    Dio dio = new Dio();
    final String pathUrl = forgotpassword; //api

    dynamic data = {'email': email}; //回傳資料
    var response = await dio.post(pathUrl, //post用法
        data: data,
        options: Options(headers: {
          'Content-type': 'application/json; charset=UTF-8', //utf-8解碼
        }));

    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString('ForgotPasswordDynamicLink', response.data['dynamic_link']['shortLink']);
  }

/* -----------------------------------修改密碼api -------------------------------- */
  static Future ChangePasswordPost(String password, String ConfirmPassword, Uri deepLink) async {
    Dio dio = new Dio();
    final String pathUrl = deepLink.toString();
    dynamic data = {'password': password, 'confirmPassword': ConfirmPassword}; //回傳資料
    print(data);
    var response = await dio.post(pathUrl,
        data: data,
        options: Options(headers: {
          'Content-type': 'application/json; charset=UTF-8', //utf-8解碼
        }));
    print(response.data['status']);
    return (response.data['status']);
  }

/* ---------------------------------- 傳送經緯度 --------------------------------- */
  static Future postlocation(latitude, longitude) async {
    //傳送經緯度
    Dio dio = new Dio();
    final String pathUrl = domin + "api/position/userPosition"; //api
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var token = preferences.getString('userToken');
    // print(token);
    dynamic data = {'latitude': latitude, 'longitude': longitude}; //回傳資料
    await dio.post(pathUrl, //post用法
        data: data,
        options: Options(headers: {
          'Content-type': 'application/json; charset=UTF-8', //utf-8解碼
          'Authorization': 'Bearer ' + token,
        }));
  }

/* ------------------------------- userid 搜尋好友 ------------------------------ */
  static Future searchuser(String friendid) async {
    //userid 搜尋好友
    Dio dio = new Dio();
    final String pathUrl = authip + "searchuserbyid"; //api
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String token = preferences.getString('userToken');
    print('token');
    print(token);
    dynamic data = {'searchId': friendid}; //回傳資料
    var response = await dio.post(pathUrl, //post用法
        data: data,
        options: Options(headers: {
          'Content-type': 'application/json; charset=UTF-8', //utf-8解碼
          'Authorization': 'Bearer ' + token,
        }));
    print(response.data);
    return response.data['userData'];
  }

/* --------------------------------- 送出好友邀請 --------------------------------- */
  static Future wantAddFriend(int friendid) async {
    //送出好友邀請
    Dio dio = new Dio();
    final String pathUrl = authip + "wantAddFriend"; //api
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String token = preferences.getString('userToken');
    dynamic data = {'wantBeFriendID': friendid};
    var response = await dio.post(pathUrl, //post用法
        data: data,
        options: Options(headers: {
          'Content-type': 'application/json; charset=UTF-8', //utf-8解碼
          'Authorization': 'Bearer ' + token,
        }));
    Printcolor.log(response.data.toString(), color: DColor.orange);
    return response.data;
  }

/* ---------------------------------- 更改id ---------------------------------- */
  static Future changemyid(String id) async {
    //更改id
    Dio dio = new Dio();
    final String pathUrl = authip + "changemyid"; //api
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String token = preferences.getString('userToken');
    dynamic data = {'newId': id};
    print(token);
    print('id:');
    print(data['newId']);
    var response = await dio.post(
      pathUrl, //post用法
      data: data,
      options: Options(headers: {
        'Content-type': 'application/json; charset=UTF-8', //utf-8解碼
        'Authorization': 'Bearer ' + token,
      }),
    );
    return response.data;
  }

/* --------------------------------- 取得朋友列表 --------------------------------- */
  static Future getUserFriendList() async {
    //取得朋友列表
    Dio dio = new Dio();
    final String pathUrl = authip + "getUserFriendList"; //api
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var token = preferences.getString('userToken');
    if (token == null) {
      return null;
    }
    var response = await dio.post(pathUrl, //post用法
        options: Options(headers: {
          'Content-type': 'application/json; charset=UTF-8', //utf-8解碼
          'Authorization': 'Bearer ' + token,
        }));
    return response.data;
  }

/* -------------------------------- 取的好友邀請列表 -------------------------------- */
  static Future getUserToBeConfirmFriendList() async {
    Dio dio = Dio();
    final String pathUrl = authip + 'getUserToBeConfirmFriendList';
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String token = preferences.getString('userToken');
    var response = await dio.post(
      pathUrl,
      options: Options(headers: {
        'Content-type': 'application/json; charset=UTF-8', //utf-8解碼
        'Authorization': 'Bearer ' + token,
      }),
    );
    return response.data['toBeConfirmList'];
  }

/* -------------------------------- 取得好友邀請列表 -------------------------------- */
  static Future confirmFriend(int confirmId) async {
    Dio dio = Dio();
    final String pathUrl = authip + 'confirmFriend';
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String token = preferences.getString('userToken');
    var data = {'confirmId': confirmId};
    var response = await dio.post(
      pathUrl,
      data: data,
      options: Options(headers: {
        'Content-type': 'application/json; charset=UTF-8', //utf-8解碼
        'Authorization': 'Bearer ' + token,
      }),
    );
    printcolor('api_tool.dart 191:35// response:${response.data}', color: DColor.orange);
    return response.data['toBeConfirmList'];
  }

  /* --------------------------------- 發送緊急通知 --------------------------------- */
  static Future urgentnotice(String title, String context, String event) async {
    Dio dio = Dio();
    const String pathUrl = noticeip + 'urgent';
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('userToken');
    final GeolocatorService geoService = GeolocatorService();
    var position = await geoService.getInitialLocation();
    var data = {
      "type": "urgent",
      "title": title,
      "body": context,
      "boxData": {
        "boxMessage": {"latitude": position.latitude, "longitude": position.longitude, "event": event}
      }
    };
    var response = await dio.post(
      pathUrl,
      data: jsonEncode(data),
      options: Options(
        headers: {
          'Content-type': 'application/json; charset=UTF-8', //utf-8解碼
          'Authorization': 'Bearer ' + token!,
        },
      ),
    );
    printcolor('api_tool.dart 191:35// response:${response.data}', color: DColor.orange);
    // return response.data['toBeConfirmList'];
  }

  /* -------------------------------- 得到所有好友位置 -------------------------------- */
  static Future<List> getUserPosition() async {
    Dio dio = Dio();
    final String pathUrl = domin + 'api/position/friendPosition';
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('userToken');
    var response = await dio.get(
      pathUrl,
      options: Options(headers: {
        'Content-type': 'application/json; charset=UTF-8', //utf-8解碼
        'Authorization': 'Bearer ' + token!,
      }),
    );
    printcolor('api_tool.dart 191:35// response:${response.data}', color: DColor.orange);
    printcolor('user position status runtime type: ${response.data['status'].runtimeType}', color: DColor.green);
    if (response.data['status']) {
      return response.data['data'];
    } else {
      return [];
    }
  }

  /* --------------------------------- 換頭貼 --------------------------------- */
  static Future changeheadshot(File picture) async {
    Dio dio = new Dio();
    final String pathUrl = authip + 'changeMyHeader';
    String fileName = picture.path.split('/').last;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('userToken'); //取得登入token
    FormData formData = FormData.fromMap({
      "image": await MultipartFile.fromFile(picture.path, filename: fileName),
    });

    var response = await dio.post(
        //上傳结果
        pathUrl,
        data: formData,
        options: Options(headers: {
          'Content-type': 'application/json; charset=UTF-8', //utf-8解碼
          'Authorization': 'Bearer ' + token!,
        }));

    preferences.setString('headimage', response.data['url']);
    //data, response.data['userData'][data].toString()
    print('change photo response :${response.data}');
  }

/* --------------------------------- 換名字 --------------------------------- */
  static Future changename(String name) async {
    //更改名字

    Dio dio = new Dio();
    final String pathUrl = authip + "changeName"; //api
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('userToken');
    dynamic data = {'newName': name};
    print('Name:');
    print(data['newName']);
    var response = await dio.post(
      pathUrl, //post用法
      data: data,
      options: Options(headers: {
        'Content-type': 'application/json; charset=UTF-8', //utf-8解碼
        'Authorization': 'Bearer ' + token!,
      }),
    );
    return response.data;
  }

  static Future happenaccident(String latitude, String longitude, String time, String event) async {
    Dio dio = new Dio();
    final String pathUrl = domin + "api/disasternet/happenaccident"; //api
    dynamic data = {'latitude': latitude, 'longitude': longitude, 'time': time, 'event': event};
    var response = await dio.post(
      pathUrl, //post用法
      data: data,
      options: Options(headers: {
        'Content-type': 'application/json; charset=UTF-8', //utf-8解碼
      }),
    );
    return response.data;
  }
  /* ---------------------------------底線-------------------------------- */

} //ApiTool

class MemoApi {
  static const domin = 'https://www.r-dap.com/'; //網域
  static const notes = domin + 'api/auth/notes/';
  static Future<Map<String, dynamic>> createMemo(String toid, String date, String content) async {
    Dio dio = Dio();
    final String pathUrl = notes + 'create';
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('userToken');
    var data = {'toid': toid, 'date': date, 'title': 'a', 'content': content};
    var response = await dio.post(
      pathUrl,
      data: data,
      options: Options(headers: {
        'Content-type': 'application/json; charset=UTF-8', //utf-8解碼
        'Authorization': 'Bearer ' + token!,
      }),
    );
    // var jsondata = jsonDecode(response.data);
    // printcolor('response data : ${jsondata}', color: DColor.yellow);
    // printcolor('response run type : ${jsondata.runtimeType}', color: DColor.yellow);
    return response.data;
  }

  static editMemo(int notesnum, String content) async {
    Dio dio = Dio();
    final String pathUrl = notes + 'edit/' + notesnum.toString();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('userToken');
    var data = {'notes_num': notesnum, 'title': '', 'content': content};
    var response = await dio.post(
      pathUrl,
      data: data,
      options: Options(headers: {
        'Content-type': 'application/json; charset=UTF-8', //utf-8解碼
        'Authorization': 'Bearer ' + token!,
      }),
    );
    // var jsondata = jsonDecode(response.data);
    // printcolor('status : ${jsondata['status']}', color: DColor.blue);
    return response.data;
  }

  static memoDone(int notesnum) async {
    Dio dio = Dio();
    final String pathUrl = notes + 'done/' + notesnum.toString();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('userToken');
    var response = await dio.post(
      pathUrl,
      options: Options(headers: {
        'Content-type': 'application/json; charset=UTF-8', //utf-8解碼
        'Authorization': 'Bearer ' + token!,
      }),
    );
    // var jsondata = jsonDecode(response.data);
    printcolor('status : ${response.data}', color: DColor.blue);
    return response.data;
  }

  static memoDelete(int notesnum) async {
    Dio dio = Dio();
    final String pathUrl = notes + 'delete/' + notesnum.toString();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString('userToken');
    var response = await dio.get(
      pathUrl,
      options: Options(headers: {
        'Content-type': 'application/json; charset=UTF-8', //utf-8解碼
        'Authorization': 'Bearer ' + token!,
      }),
    );
    // var jsondata = jsonDecode(response.data);
    printcolor('status : ${response.data}', color: DColor.blue);
    return response.data;
  }
}
