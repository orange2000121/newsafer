import 'package:newsafer/screens/map.dart';
import 'package:newsafer/tool/GoogleSignInApi.dart';
import 'package:newsafer/tool/api_tool.dart';
import 'package:newsafer/tool/debug.dart';
import 'package:newsafer/tool/people_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:network_image_to_byte/network_image_to_byte.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInVarible {
  //Sign IN 所使用到的參數
  late Position position;
  bool onFirstPage = true;
  bool timeSet = true; //時間設定
  var _passwordVisible = false; //判斷密碼是否可視函數
  final _passwordKey = GlobalKey<FormState>(); //判斷password輸入的變數
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _accountkey = GlobalKey<FormState>();
  // ignore: non_constant_identifier_names
  final forgot_emailkey = GlobalKey<FormState>(); //判斷email輸入的變數
  final String regexEmail = "^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*\$"; //校正SignIn頁面email格式函數
  final ValueNotifier<String> check = ValueNotifier<String>(''); //確認post回傳值狀態
  final ValueNotifier<bool> onForgotPassword = ValueNotifier<bool>(true);
  final Map<String, dynamic> _formData = {
    //帳號密碼回傳格式型態
    'email': '',
    'password': '',
  };
  final Map<String, dynamic> forgotemail = {
    //帳號密碼回傳格式型態
    'email': '',
  };
  String message = 'Log in/out by pressing the buttons below.';
  TextEditingController emailController = TextEditingController(); //給sharedpreference存
  TextEditingController passController = TextEditingController();
}

class UserLogin extends StatefulWidget {
  final signIn;
  UserLogin(this.signIn);
  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      //Sign IN 頁面
      color: Color(0xFFF3F7E8),
      child: ListView(
        children: [
          Form(
              key: widget.signIn._accountkey, //設定email的key
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.09,
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress, //輸入型態
                    autofocus: false,

                    controller: widget.signIn.emailController, //給sharedpreference存
                    decoration: InputDecoration(
                      hintText: 'Email',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 20.0, 10.0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return '請輸入email';
                      }
                      widget.signIn._formData['email'] = value; //處存email資料
                      return null;
                    },
                  ),
                ) // Add TextFormFields and ElevatedButton here.
                ,
              )),
          Container(
            height: MediaQuery.of(context).size.height * 0.08,
            child: Form(
                key: widget.signIn._passwordKey, //設定password key
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: TextFormField(
                    obscureText: !widget.signIn._passwordVisible, //是否可視
                    autofocus: false,
                    controller: widget.signIn.passController, //給sharedpreference存
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'password',
                      suffixIcon: IconButton(
                        //改變密碼可視
                        icon: Icon(
                          // Based on passwordVisible state choose the icon
                          widget.signIn._passwordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        onPressed: () {
                          // Update the state i.e. toogle the state of passwordVisible variable
                          setState(() {
                            widget.signIn._passwordVisible = !widget.signIn._passwordVisible; //改變可視狀態
                          });
                        },
                      ),
                      contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 20.0, 10.0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return '請輸入密碼';
                      }
                      widget.signIn._formData['password'] = value; //處存password資料
                      return null;
                    },
                  ) // Add TextFormFields and ElevatedButton here.
                  ,
                )),
          ),
          Container(
            //Login 按鈕
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.all(12),
              child: ElevatedButton(
                onPressed: () async {
                  SystemChannels.textInput.invokeMethod('TextInput.hide');

                  widget.signIn._passwordKey.currentState.validate();
                  widget.signIn._accountkey.currentState.validate();
                  if (widget.signIn._passwordKey.currentState.validate() && widget.signIn._accountkey.currentState.validate()) {
                    Map CheckSignInResponse = await ApiTool.loginpost(widget.signIn._formData['email'], widget.signIn._formData['password']); //傳送email password資料給後端
                    if (CheckSignInResponse['status'] == null) {
                      Fluttertoast.showToast(
                          msg: "登入成功", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Colors.green, textColor: Colors.white, fontSize: 20.0);
                      tomap();
                    }
                    printcolor('CheckSignInResponse:$CheckSignInResponse', color: DColor.blue);
                    if (CheckSignInResponse['status'] == 'false') {
                      Fluttertoast.showToast(
                          msg: "登入失敗", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 20.0);
                    }
                  }
                },
                child: Text('Login', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF5A6248),
                  padding: EdgeInsets.all(12),
                  shadowColor: Color(0xFF5A6248),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                ),
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.1,
            child: Row(
              //icon的row
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, //中間分隔
              children: [
                IconButton(
                  //google icon
                  color: Colors.red[600],
                  icon: Icon(FontAwesomeIcons.google),
                  iconSize: 40.0,
                  onPressed: () async {
                    await googlelogin();
                  },
                ),
                IconButton(
                  //line icon
                  color: Colors.green[600],
                  icon: Icon(FontAwesomeIcons.line),
                  iconSize: 40.0,
                  onPressed: () {},
                ),
                IconButton(
                  //facebook icon
                  color: Colors.blue[600],
                  // 第三方庫icon圖示
                  icon: Icon(FontAwesomeIcons.facebook),
                  iconSize: 40.0,
                  onPressed: () {
                    _login();
                  },
                ),
              ],
            ),
          ),
          TextButton(
              //忘記密碼按鈕
              onPressed: () {
                setState(() {
                  {
                    widget.signIn.onForgotPassword.value = false;
                  }
                });
              },
              child: Text(
                'Forgot Password ?',
                style: TextStyle(color: Color(0x996D7660), fontSize: 15),
              )),
          ValueListenableBuilder<String>(
            builder: (BuildContext context, String value, Widget? child) {
              return Text(value);
            },
            valueListenable: widget.signIn.check,
          )
        ],
      ),
    );
  }

  void tomap() async {
    if (widget.signIn.check.value != null) {
      final sqhelper = FriendData();
      final datas = await ApiTool.getUserFriendList(); //從伺服器取得所有好友資訊
      if (datas == null) {
        return;
      }
      // await sqhelper.open();
      for (var data in datas) {
        //將每個好友資訊存入
        if (data['photo'] != null) {
          final String pathUrl = data['photo'];
          data['photo'] = await networkImageToByte(pathUrl);
        }
        sqhelper.insert(data); //插入好友資料
      }
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString('email', widget.signIn.emailController.text);
      preferences.setString('password', widget.signIn.emailController.text);
      (widget.signIn.position != null) //如果Position為空，則轉圈圈不給進
          ? Navigator.pushAndRemoveUntil(
              context,
              //跳轉到主頁
              new MaterialPageRoute(builder: (context) => new MapPage(widget.signIn.position, widget.signIn.check.value)),
              // (route) => route == null)
              (Route<dynamic> route) => false)
          : Center(
              child: // 模糊进度条(会执行一个旋转动画)
                  CircularProgressIndicator(
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(Colors.blue),
              ),
            );
    }
  }

  void GoogleToMap() async {
    final sqhelper = FriendData();
    final datas = await ApiTool.getUserFriendList(); //從伺服器取得所有好友資訊
    if (datas == null) {
      return;
    }
    // await sqhelper.open();
    for (var data in datas) {
      //將每個好友資訊存入
      if (data['photo'] != null) {
        final String pathUrl = data['photo'];
        data['photo'] = await networkImageToByte(pathUrl);
      }
      sqhelper.insert(data); //插入好友資料
    }
    (widget.signIn.position != null) //如果Position為空，則轉圈圈不給進
        ? Navigator.pushAndRemoveUntil(
            context,
            //跳轉到主頁
            new MaterialPageRoute(builder: (context) => new MapPage(widget.signIn.position, widget.signIn.check.value)),
            // (route) => route == null)
            (Route<dynamic> route) => false)
        : Center(
            child: // 模糊进度条(会执行一个旋转动画)
                CircularProgressIndicator(
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(Colors.blue),
            ),
          );
  }

  Future googlelogin() async {
    final googleres = await GoogleSignInApi.login();
    if (googleres['status'] == 'user exit') {
      Fluttertoast.showToast(msg: "登入成功", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Colors.green, textColor: Colors.white, fontSize: 20.0);
      GoogleToMap();
    } else {
      Fluttertoast.showToast(msg: "登入失敗", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 20.0);
    }
  }

  Future<Null> _login() async {
    final LoginResult result = await FacebookAuth.instance.login(); // by default we request the email and the public profile

    // or FacebookAuth.i.login()
    if (result.status == LoginStatus.success) {
      // you are logged
      final AccessToken? accessToken = result.accessToken;
      widget.signIn.check.value = await ApiTool.facebookloginpost(accessToken!.token) as String; //傳送email password資料給後端
      tomap();
    } else {
      print(result.status);
      print(result.message);
    }
  }
}
