import 'dart:io';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:network_image_to_byte/network_image_to_byte.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'background_fetch.dart';
import 'pages/auth_ui/login_signup_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'pages/Change_password.dart';

import 'package:newsafer/tool/debug.dart';
import 'package:newsafer/tool/people_service.dart';
import 'package:newsafer/screens/map.dart';
import 'package:newsafer/tool/api_tool.dart';
import 'package:newsafer/services/geolocator_service.dart';
import 'package:newsafer/tool/message_handel.dart';

//添加此段才能連接https伺服器
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  printcolor('app start', color: DColor.green);
  //呼叫HttpOverrides才能連接https伺服器
  // Timer.periodic(Duration(milliseconds: 1000), (timer) => print('tick'));
  HttpOverrides.global = new MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized(); //要記得在void main() async {}的第一行加入：
  /* ---------------------------------- 介面設定 ---------------------------------- */
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); //設定直屏
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent)); //設定通知欄字體顏色與背景顏色
  }
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top]); //顯示狀態欄
  /* ----------------------------------- FCM ---------------------------------- */
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true, // Required to display a heads up notification
    badge: true,
    sound: true,
  );
  FirebaseMessaging.onBackgroundMessage(messageHandler);
  FirebaseMessaging.onMessage.listen(messageHandler);
/* ---------------------------------- 進入app --------------------------------- */
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String? userToken = preferences.getString('userToken');
  printcolor('main.dart 39:26//  user token:$userToken', color: DColor.blue);
  print('APP start.');
  runApp(MaterialApp(
    navigatorKey: navigatorKey,
    home: MyApp(userToken!),
    // home: MyApp(),
  ));
  // Register to receive BackgroundFetch events after app is terminated.
  // Requires {stopOnTerminate: false, enableHeadless: true}
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

final routes = <String, WidgetBuilder>{
  LoginPage.tag: (context) => LoginPage(),
  // HomePage.tag: (context) => HomePage(),
};

class MyApp extends StatefulWidget {
  final String userToken;
  MyApp(this.userToken);

  @override
  _MyAppState createState() => _MyAppState();
}

//WidgetsBindingObserver 註冊到 Widgets 層綁定的類的接口。
class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final geoService = GeolocatorService();
  bool isopenpermisionsetting = false;
  void getfriend() async {
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
  }

  void checkPermission() async {
    /* ---------------------------------- 要求權限 ---------------------------------- */
    //當前權限
    Permission permission = Permission.locationAlways;
    //權限狀態
    PermissionStatus status = await permission.status;
    if (status.isDenied) {
      //用戶點擊了拒絕
      showDialog(
          context: context,
          builder: (context) => WillPopScope(
                onWillPop: () async => false,
                child: CupertinoAlertDialog(
                  title: Text('前往權限設定'),
                  content: Text('需要位置權限才能使用app'),
                  actions: [
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      onPressed: () => exit(0),
                      child: Text("退出app"),
                    ),
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      onPressed: () async {
                        isopenpermisionsetting = await openAppSettings();
                      },
                      child: Text("前往權限設定"),
                    )
                  ],
                ),
              ));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this); //建立後臺切換監聽
    checkPermission();
    // initDynamicLinks();
    getfriend();
  }

  // void initDynamicLinks() async {
  //   //dynamic link navigate
  //   // SharedPreferences preferences = await SharedPreferences.getInstance();
  //   // var FPDL = preferences.getString('ForgotPasswordDynamicLink');
  //   FirebaseDynamicLinks.instance.onLink(onSuccess: (PendingDynamicLinkData FPDL) async {
  //     final Uri deepLink = FPDL?.link;
  //     print("deeplink found");
  //     if (deepLink != null) {
  //       print(deepLink);
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(builder: (context) => ChangePassword(deepLink)),
  //       );
  //     }
  //   }, onError: (OnLinkErrorException e) async {
  //     print("deeplink error");
  //     print(e.message);
  //   });
  // }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //監聽後台切換到app
    print("-didChangeAppLifecycleState-" + state.toString());
    if (state == AppLifecycleState.resumed && isopenpermisionsetting) {
      Navigator.pop(context);
      checkPermission();
    }
  }

  @override
  void dispose() {
    //取消後台切換監聽
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.userToken == null
        ? MaterialApp(
            title: 'Kodeversitas',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.lightBlue,
              fontFamily: 'Nunito',
            ),
            home: AnimatedSplashScreen(
              splash: Image.asset(
                'assets/images/R-DAP.png',
              ),
              nextScreen: LoginPage(),
              splashTransition: SplashTransition.scaleTransition,
              backgroundColor: Colors.black,
              duration: 3000,
            ),
            routes: routes,
          )
        : FutureProvider(
            create: (context) => geoService.getInitialLocation(),
            child: MaterialApp(
              title: 'SAFER',
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              home: Consumer<Position>(
                builder: (context, position, providerWidget) {
                  return (position != null)
                      ? AnimatedSplashScreen(
                          splash: Image.asset(
                            'assets/images/R-DAP.png',
                          ),
                          nextScreen: MapPage(position, widget.userToken))
                      : Center(
                          child: // 模糊进度条(会执行一个旋转动画)
                              CircularProgressIndicator(
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation(Colors.blue),
                          ),
                        );
                },
              ),
            ),
          );
  }
}
