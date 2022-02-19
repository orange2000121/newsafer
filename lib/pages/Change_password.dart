import 'package:newsafer/tool/debug.dart';
import 'package:flutter/material.dart';
// import 'already_send_mail.dart';
import 'auth_ui/login_signup_page.dart';
import 'package:newsafer/tool/api_tool.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChangePassword extends StatefulWidget {
  final Uri deepLink;
  ChangePassword(this.deepLink);
  static String tag = 'change-password-page';
  @override
  _ChangePasswordState createState() => new _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _changepasswordkey = GlobalKey<FormState>(); //判斷password輸入的變數
  final _changecheckpasswordkey = GlobalKey<FormState>(); //判斷checkpassword輸入的變數
  var _passwordVisible = false; //可否看見密碼變數
  var _checkpasswordVisible = false; //可否看見密碼變數
  final ValueNotifier<String> _check = ValueNotifier<String>('');
  final String regexPassword = r'^(?=.*?[a-z])(?=.*?[0-9]).{6,30}$'; //校正SignUp頁面password格式函數
  final Map<String, dynamic> _formData = {
    //輸入的資料
    'password': '',
    'checkpassword': '',
  };
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
          child: Container(
        width: MediaQuery.of(context).size.width, //寬度: 偵查個人手機寬度
        height: MediaQuery.of(context).size.height, //長度: 偵查個人手機長度
        decoration: new BoxDecoration(image: new DecorationImage(image: new AssetImage("assets/images/logo2.png"), fit: BoxFit.fill)), //底圖
        child: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                      //頂部文字
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Text(
                        'Welcome To Safer',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontSize: 35,
                        ),
                      ))
                ],
              ),
              const Divider(
                //分隔線
                height: 10,
                thickness: 3,
                indent: 50,
                endIndent: 50,
                color: Color(0xFFFFFAFA),
              ),
              SizedBox(
                  //填充分隔線與底下的距離
                  height: MediaQuery.of(context).size.height * 0.01),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.7,
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.rectangle,
                    ),
                    child: PageView(
                      controller: PageController(
                        viewportFraction: 0.85, //旁邊卡片能夠突出
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular((20))), //讓卡片邊框變成圓角
                            color: const Color(0xFFF3F7E8),
                            child: Container(
                                child: Column(
                              children: [
                                Container(
                                  height: MediaQuery.of(context).size.height * 0.02,
                                ),
                                Container(
                                  width: 125,
                                  height: MediaQuery.of(context).size.height * 0.1,
                                  decoration: BoxDecoration(
                                      //Sign-In 頭像
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      image: new DecorationImage(image: new AssetImage("assets/images/家人1.jpg"), fit: BoxFit.cover)),
                                ),
                                Container(
                                  color: const Color(0xFFF3F7E8),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: MediaQuery.of(context).size.height * 0.1,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(20, 30, 0, 10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                color: const Color(0xFFF3F7E8),
                                                height: MediaQuery.of(context).size.height * 0.01,
                                              ),
                                              InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(builder: (context) => LoginPage()),
                                                      );
                                                    });
                                                  },
                                                  child: new Container(
                                                    width: 35,
                                                    height: 35,
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        shape: BoxShape.circle,
                                                        image: new DecorationImage(image: new AssetImage("assets/images/Back_Arrow.png"), fit: BoxFit.fill)),
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: MediaQuery.of(context).size.height * 0.1,
                                        child: const Text('重新設定密碼', style: TextStyle(fontSize: 25, color: Color(0xFF6D7660)), textAlign: TextAlign.center),
                                      ),
                                      Form(
                                        //password輸入框
                                        key: _changepasswordkey,
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                          child: TextFormField(
                                            autofocus: false,
                                            obscureText: !(_passwordVisible),
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              hintText: '密碼',
                                              contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                                              suffixIcon: IconButton(
                                                //改變密碼可視
                                                icon: Icon(
                                                  // Based on passwordVisible state choose the icon
                                                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                                  color: Theme.of(context).primaryColorDark,
                                                ),
                                                onPressed: () {
                                                  // Update the state i.e. toogle the state of passwordVisible variable
                                                  setState(() {
                                                    _passwordVisible = !(_passwordVisible);
                                                  });
                                                },
                                              ),
                                            ),
                                            validator: (value) {
                                              bool check = RegExp(regexPassword).hasMatch(value!);
                                              if (value!.isEmpty) {
                                                return 'Please enter some text';
                                              }
                                              if (value.length < 6) {
                                                return '密碼長度至少需要6字';
                                              }
                                              if (value.length >= 30) {
                                                return '密碼長度過長';
                                              }
                                              if (check != true) {
                                                return '密碼強度不足,至少一個小寫字母與數字';
                                              }
                                              _formData['password'] = value; //處存password資料
                                              return null;
                                            },
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: MediaQuery.of(context).size.height * 0.01,
                                        color: Colors.transparent,
                                      ),
                                      Form(
                                        //checkpassword輸入框
                                        key: (_changecheckpasswordkey),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                          child: TextFormField(
                                            autofocus: false,
                                            obscureText: !(_checkpasswordVisible),
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              hintText: '確認密碼',
                                              contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                                              suffixIcon: IconButton(
                                                //改變密碼可視
                                                icon: Icon(
                                                  // Based on passwordVisible state choose the icon
                                                  _checkpasswordVisible ? Icons.visibility : Icons.visibility_off,
                                                  color: Theme.of(context).primaryColorDark,
                                                ),
                                                onPressed: () {
                                                  // Update the state i.e. toogle the state of passwordVisible variable
                                                  setState(() {
                                                    _checkpasswordVisible = !(_checkpasswordVisible); //變更可視狀態
                                                  });
                                                },
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Please enter some text';
                                              }
                                              _formData['checkpassword'] = value; //處存checkpassword資料
                                              return null;
                                            },
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: MediaQuery.of(context).size.height * 0.03,
                                        color: Colors.transparent,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                        child: Container(
                                          height: MediaQuery.of(context).size.height * 0.1,
                                          width: double.infinity,
                                          child: Padding(
                                            //註冊按鈕
                                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(24),
                                                ),
                                                padding: const EdgeInsets.all(12),
                                                primary: const Color(0xFF5A6248),
                                              ),
                                              onPressed: () async {
                                                var check0 = _changepasswordkey.currentState!.validate(); //更新輸入資料狀態
                                                var check1 = _changecheckpasswordkey.currentState!.validate(); //更新輸入資料狀態
                                                if (check0 && check1) {
                                                  //確認有無輸入
                                                  if (_formData['password'] != _formData['checkpassword']) {
                                                    //確認輸入密碼正確
                                                    _check.value = '確認密碼相同';
                                                  } else {
                                                    var check_response = await ApiTool.ChangePasswordPost(_formData['password'], _formData['checkpassword'], widget.deepLink); //註冊post
                                                    printcolor(check_response.toString(), color: DColor.green);
                                                    if (check_response) {
                                                      Fluttertoast.showToast(
                                                          msg: "修改密碼成功",
                                                          toastLength: Toast.LENGTH_SHORT,
                                                          gravity: ToastGravity.BOTTOM,
                                                          timeInSecForIosWeb: 1,
                                                          backgroundColor: Colors.green,
                                                          textColor: Colors.white,
                                                          fontSize: 16.0);
                                                      Navigator.pushAndRemoveUntil(
                                                          context,
                                                          //跳轉到主頁
                                                          new MaterialPageRoute(builder: (context) => LoginPage()),
                                                          // (route) => route == null)
                                                          (Route<dynamic> route) => false);
                                                    } else {
                                                      Fluttertoast.showToast(
                                                          msg: "修改失敗,請重新嘗試",
                                                          toastLength: Toast.LENGTH_SHORT,
                                                          gravity: ToastGravity.BOTTOM,
                                                          timeInSecForIosWeb: 1,
                                                          backgroundColor: Colors.red,
                                                          textColor: Colors.white,
                                                          fontSize: 16.0);
                                                    }
                                                  }
                                                }
                                              },
                                              child: const Text('修改密碼', style: const TextStyle(color: Colors.white)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      )),
    );
  }
}
