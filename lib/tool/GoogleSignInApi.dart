import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleSignInApi {
  static Future login() async {
    final _googleSignIn = GoogleSignIn();
    Dio dio = new Dio();
    String GooglePathUrl = 'https://r-dap.com/api/auth/login/google/getUserDataFromGoogle';
    GoogleSignInAccount? result = await _googleSignIn.signIn();
    var ggAuth = await result!.authentication;
    String? firebasetoken = await FirebaseMessaging.instance.getToken();
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
