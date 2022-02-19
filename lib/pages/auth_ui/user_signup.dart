import 'package:newsafer/tool/api_tool.dart';
import 'package:flutter/material.dart';

class SignUpVarible {
  //Sign UP 所使用到的參數
  var _passwordVisible = false; //可否看見密碼變數
  var _checkpasswordVisible = false; //可否看見密碼變數
  final String regexEmail = "^\\w+([-+.]\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*\$"; //校正SignUp頁面email格式函數
  final String regexPassword = r'^(?=.*?[a-z])(?=.*?[0-9]).{6,30}$'; //校正SignUp頁面password格式函數
  final ValueNotifier<String> _check = ValueNotifier<String>('');
  final _namekey = GlobalKey<FormState>(); //判斷name輸入的變數
  final _emailkey = GlobalKey<FormState>(); //判斷email輸入的變數
  final _passwordkey = GlobalKey<FormState>(); //判斷password輸入的變數
  final _checkpasswordkey = GlobalKey<FormState>(); //判斷checkpassword輸入的變數
  final Map<String, dynamic> _formData = {
    //輸入的資料
    'name': '',
    'id': '',
    'password': '',
    'checkpassword': '',
  };
}

class UserSignup extends StatefulWidget {
  @override
  _UserSignupState createState() => _UserSignupState();
}

class _UserSignupState extends State<UserSignup> {
  var signUp = SignUpVarible(); //引signUp函數庫
  @override
  Widget build(BuildContext context) {
    return Container(
        //Sign Up頁面
        height: MediaQuery.of(context).size.height * 0.4,
        color: const Color(0xFFF3F7E8),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.4,
          color: const Color(0xFFF3F7E8),
          child: ListView(
            children: [
              Column(children: [
                Form(
                  //email輸入框
                  key: signUp._emailkey,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      autofocus: false,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Email',
                        contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                      ),
                      validator: (value) {
                        bool check = RegExp(signUp.regexEmail).hasMatch(value!);
                        if (value!.isEmpty) {
                          return '請輸入email';
                        }
                        if (check != true) {
                          return 'email格式有誤,請查核';
                        }
                        signUp._formData['email'] = value; //處存email資料
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Form(
                  //name輸入框
                  key: signUp._namekey,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: TextFormField(
                      keyboardType: TextInputType.name,
                      autofocus: false,
                      obscureText: false,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: '姓名',
                        contentPadding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter some text';
                        }
                        signUp._formData['name'] = value; //處存name資料
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Form(
                  //password輸入框
                  key: signUp._passwordkey,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: TextFormField(
                      autofocus: false,
                      obscureText: !(signUp._passwordVisible),
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
                            signUp._passwordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          onPressed: () {
                            // Update the state i.e. toogle the state of passwordVisible variable
                            setState(() {
                              signUp._passwordVisible = !(signUp._passwordVisible);
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        bool check = RegExp(signUp.regexPassword).hasMatch(value!);
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
                        signUp._formData['password'] = value; //處存password資料
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Form(
                  //checkpassword輸入框
                  key: (signUp._checkpasswordkey),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: TextFormField(
                      autofocus: false,
                      obscureText: !(signUp._checkpasswordVisible),
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
                            signUp._checkpasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          onPressed: () {
                            // Update the state i.e. toogle the state of passwordVisible variable
                            setState(() {
                              signUp._checkpasswordVisible = !(signUp._checkpasswordVisible); //變更可視狀態
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter some text';
                        }
                        signUp._formData['checkpassword'] = value; //處存checkpassword資料
                        return null;
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Container(
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
                            var check0 = signUp._passwordkey.currentState!.validate(); //更新輸入資料狀態
                            var check1 = signUp._namekey.currentState!.validate(); //更新輸入資料狀態
                            var check2 = signUp._emailkey.currentState!.validate(); //更新輸入資料狀態
                            var check3 = signUp._checkpasswordkey.currentState!.validate(); //更新輸入資料狀態
                            if (check0 && check1 && check2 && check3) {
                              //確認有無輸入
                              if (signUp._formData['password'] != signUp._formData['checkpassword']) {
                                //確認輸入密碼正確
                                signUp._check.value = '確認密碼相同';
                              } else {
                                signUp._check.value = await ApiTool.signuppost(signUp._formData['name'], signUp._formData['email'], signUp._formData['password']) as String; //註冊post
                                print('value=');
                                print(signUp._check.value);
                              }
                            }
                          },
                          child: const Text('Sign Up', style: const TextStyle(color: Colors.white)),
                        ),
                      )),
                ),
                ValueListenableBuilder<String>(
                  builder: (BuildContext context, String value, Widget? child) {
                    return Text('$value');
                  },
                  valueListenable: signUp._check,
                ),
              ]),
            ],
          ),
        ));
  }
}
