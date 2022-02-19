import 'package:newsafer/pages/auth_ui/forgot_password.dart';
import 'package:newsafer/pages/auth_ui/older_login.dart';
import 'package:newsafer/pages/auth_ui/user_login.dart';
import 'package:newsafer/pages/auth_ui/user_signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:animations/animations.dart';
import 'package:geolocator/geolocator.dart';

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var signIn = SignInVarible(); //引入signIn函數庫
  @override
  void initState() {
    //詢問獲取當前位置
    super.initState();
    Geolocator.getCurrentPosition().then((currloc) {
      setState(() {
        signIn.position = currloc;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: signIn.scaffoldKey,
      backgroundColor: Colors.transparent, //底色設為透明
      body: SingleChildScrollView(
        //**SingleChildScrollView**能夠消除pixel不足
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
                        child: const Text(
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
                  color: const Color(0xFFFFFAFA),
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
                          //左右滑動頁面
                          controller: PageController(
                            viewportFraction: 0.85, //旁邊卡片能夠突出
                          ),
                          children: [
                            Padding(
                              //第一張卡片內容
                              padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                              child: Card(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular((20))), //讓卡片邊框變成圓角
                                color: const Color(0xFFF3F7E8),
                                child: Container(
                                  child: Column(children: [
                                    Container(
                                      height: MediaQuery.of(context).size.height * 0.02,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center, //置中
                                      children: [
                                        Container(
                                          width: 125,
                                          height: MediaQuery.of(context).size.height * 0.1,
                                          decoration: BoxDecoration(
                                              //Sign-In 頭像
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              image: new DecorationImage(image: new AssetImage("assets/images/家人1.jpg"), fit: BoxFit.cover)),
                                        )
                                      ],
                                    ),
                                    ValueListenableBuilder(
                                      valueListenable: signIn.onForgotPassword,
                                      builder: (BuildContext context, bool onForgotPassword, Widget? child) {
                                        return PageTransitionSwitcher(
                                            duration: const Duration(milliseconds: 650),
                                            reverse: !(onForgotPassword),
                                            transitionBuilder: (Widget child, Animation<double> animation, Animation<double> secondaryAnimation) {
                                              return SharedAxisTransition(
                                                  child: child, animation: animation, secondaryAnimation: secondaryAnimation, transitionType: SharedAxisTransitionType.horizontal);
                                            },
                                            child: onForgotPassword
                                                ? Column(
                                                    children: [
                                                      Container(
                                                        color: const Color(0xFFF3F7E8),
                                                        height: MediaQuery.of(context).size.height * 0.01,
                                                      ),
                                                      Container(
                                                        color: const Color(0xFFF3F7E8),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Container(
                                                              color: const Color(0xFFF3F7E8),
                                                              height: MediaQuery.of(context).size.height * 0.08,
                                                            ),
                                                            TextButton(
                                                                //Sign In 文字按鈕
                                                                onPressed: () {
                                                                  setState(() {
                                                                    {
                                                                      signIn.onFirstPage = true;
                                                                    }
                                                                  });
                                                                },
                                                                child: Text(
                                                                  'SIGN IN',
                                                                  style: TextStyle(
                                                                    fontSize: 25,
                                                                    color: signIn.onFirstPage ? const Color(0xFF6D7660) : const Color(0x956D7660),
                                                                    decoration: TextDecoration.underline,
                                                                  ),
                                                                )),
                                                            TextButton(
                                                                //Sign Up文字按鈕
                                                                onPressed: () {
                                                                  setState(() {
                                                                    {
                                                                      signIn.onFirstPage = false;
                                                                    }
                                                                  });
                                                                },
                                                                child: Text(
                                                                  'SIGN UP',
                                                                  style: TextStyle(
                                                                    fontSize: 25,
                                                                    color: signIn.onFirstPage ? const Color(0x956D7660) : const Color(0xFF6D7660),
                                                                    decoration: TextDecoration.underline,
                                                                  ),
                                                                ))
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        height: MediaQuery.of(context).size.height * 0.01,
                                                        color: const Color(0xFFF3F7E8),
                                                      ),
                                                      Column(
                                                        children: <Widget>[
                                                          PageTransitionSwitcher(
                                                              //Sign In Sign UP 動畫轉換頁面
                                                              duration: const Duration(milliseconds: 800),
                                                              reverse: !(signIn.onFirstPage),
                                                              transitionBuilder: (Widget child, Animation<double> animation, Animation<double> secondaryAnimation) {
                                                                return SharedAxisTransition(
                                                                    child: child, animation: animation, secondaryAnimation: secondaryAnimation, transitionType: SharedAxisTransitionType.horizontal);
                                                              },
                                                              child: signIn.onFirstPage ? UserLogin(signIn) : UserSignup()),
                                                        ],
                                                      ),
                                                    ],
                                                  )
                                                : ForgotPassword(signIn));
                                      },
                                    ),
                                  ]),
                                ),
                              ),
                            ),
                            Padding(
                              //第二張卡片
                              padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                              child: Card(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular((20))),
                                color: const Color(0xFFF3F7E8),
                                child: OlderLogin(),
                              ),
                            ),
                          ]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
