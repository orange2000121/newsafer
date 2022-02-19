/* --------------------------------- Plugin --------------------------------- */
import 'dart:ui';
import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:newsafer/widgets/user_memo.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:laravel_echo/laravel_echo.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:network_image_to_byte/network_image_to_byte.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
/* --------------------------------- Widgets -------------------------------- */
import 'package:newsafer/widgets/infowindow.dart';
import 'package:newsafer/widgets/circle_list.dart';
/* ---------------------------------- Tool ---------------------------------- */
import 'package:newsafer/tool/debug.dart';
import 'package:newsafer/tool/api_tool.dart';
import 'package:newsafer/tool/people_service.dart';
/* --------------------------------- Service -------------------------------- */
import 'package:newsafer/services/marker_map.dart';
import 'package:newsafer/services/geolocator_service.dart';
/* ---------------------------------- Pages --------------------------------- */
import 'package:newsafer/pages/find_friend.dart';
import 'package:newsafer/pages/confirmfriend.dart';
import 'package:newsafer/pages/real_time_image.dart';
import 'package:newsafer/pages/BluetoothSerial.dart';
import 'package:newsafer/pages/electronic_fence.dart';
import 'package:newsafer/pages/auth_ui/login_signup_page.dart';
import 'package:newsafer/pages/profile/basic_information.dart';

class MapPage extends StatefulWidget {
  final Position initialPosition;
  final String token;
  MapPage(this.initialPosition, this.token);

  @override
  State<StatefulWidget> createState() => MapState();
}

class MapState extends State<MapPage> {
/* -------------------------------------------------------------------------- */
/*                                    全域變數                                */
/* -------------------------------------------------------------------------- */
  static MapState instance;
  final GeolocatorService geoService = GeolocatorService();
  final sqlitehelp = FriendData();
  final markers = <MarkerId, Marker>{}; //google map的所有 marker
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin(); //local notifition
  var pic = '';
  var scaffoldKey = GlobalKey<ScaffoldState>();
  bool isExpanded = false; //通知欄是否打開
  bool hideCustomInfoWindow = true; //自訂 infowindow 是否隱藏
  Completer<GoogleMapController> _controller = Completer(); //控制地圖
  Map<String, LatLng> friendposition = {};
  CustomInfoWindowController customInfoWindowController = CustomInfoWindowController();
  BuildContext infowindowcontext;

  /* ---------------------------------- background locator ---------------------------------- */
  ReceivePort port = ReceivePort();

/* -------------------------------------------------------------------------- */
/*                                    START                                   */
/* -------------------------------------------------------------------------- */
  Timer timer;
  @override
  void initState() {
    super.initState();
    instance = this;
    // 每15秒取得使用者位置
    // timer = Timer.periodic(Duration(seconds: 15), (Timer t) => getfriendposition());
    getfriendposition();
    //地圖camera移到目前位置
    geoService.getCurrentLocation().listen((position) {
      centerScreen(position);
    });
    getfriendposition();
    getnotifications();
  }

  @override
  void dispose() {
    customInfoWindowController.dispose();
    timer.cancel();
    super.dispose();
  }

/* -------------------------------------------------------------------------- */
/*                                    BUILD                                   */
/* -------------------------------------------------------------------------- */

  @override
  Widget build(BuildContext context) {
    infowindowcontext = context;
    double _w = MediaQuery.of(context).size.width;
    /* --------------------------- background locator --------------------------- */
    // startLocationService();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawerScrimColor: Colors.transparent,
      key: scaffoldKey,

      /* --------------------------------- DRAWER --------------------------------- */

      drawer: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
        child: SizedBox(
          width: _w,
          child: Drawer(
            elevation: 0,
            //author: danny
            //側邊攔
            child: Container(
              color: Color(0xFFDEE7E8).withOpacity(0.9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top),
                  InkWell(
                    //退出drawer
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/drawericon/Group 162.png'))),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
                      children: [
                        InkWell(
                          onTap: () async {
                            LaunchApp.openApp(androidPackageName: 'com.macrovideo.v380pro');
                          },
                          child: Container(
                            width: _w * 0.7,
                            height: 98,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt,
                                  size: 40,
                                  color: Color(0xff516F7C),
                                ),
                                SizedBox(width: 20),
                                Text('開啟V380 pro', style: TextStyle(fontSize: 35, color: Color(0xff516F7C))),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        InkWell(
                          onTap: () async {
                            SharedPreferences preferences = await SharedPreferences.getInstance();
                            String id = preferences.getString('id');
                            printcolor('id : $id', color: DColor.blue);
                            //自己的備忘錄
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Scaffold(
                                        appBar: AppBar(),
                                        body: UserMemo(id),
                                      )),
                            );
                          },
                          child: Container(
                            width: _w * 0.7,
                            height: 98,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.receipt,
                                  size: 40,
                                  color: Color(0xff516F7C),
                                ),
                                SizedBox(width: 20),
                                Text('我的備忘錄', style: TextStyle(fontSize: 35, color: Color(0xff516F7C))),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        InkWell(
                          onTap: () async {
                            //好友確認
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ConfirmFriend()),
                            );
                          },
                          child: Container(
                            width: _w * 0.7,
                            height: 98,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_add_alt_1_sharp,
                                  size: 40,
                                  color: Color(0xff516F7C),
                                ),
                                SizedBox(width: 20),
                                Text('好友邀請', style: TextStyle(fontSize: 35, color: Color(0xff516F7C))),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        InkWell(
                          onTap: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    //跳轉到加好友頁面
                                    builder: (context) => Findfriend(),
                                    maintainState: false));
                          },
                          child: Container(
                            width: 200,
                            height: 98,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Row(
                              //收尋id
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.group_add_outlined,
                                  size: 40,
                                  color: Color(0xff516F7C),
                                ),
                                SizedBox(width: 20),
                                Text('搜尋朋友', style: TextStyle(fontSize: 35, color: Color(0xff516F7C))),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        InkWell(
                          onTap: () async {
                            SharedPreferences preferences = await SharedPreferences.getInstance();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    //跳轉到基本資料頁面
                                    builder: (context) => BaseInformation(preferences),
                                    maintainState: false));
                          },
                          child: Container(
                            width: 200,
                            height: 98,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Row(
                              //基本資料
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.info,
                                  size: 40,
                                  color: Color(0xff516F7C),
                                ),
                                SizedBox(width: 20),
                                Text('基本資料', style: TextStyle(fontSize: 35, color: Color(0xff516F7C))),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        InkWell(
                          onTap: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    //bluetooth
                                    builder: (context) => ElectronicFence(),
                                    maintainState: false));
                          },
                          child: Container(
                            width: 200,
                            height: 98,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.fence_rounded,
                                  size: 40,
                                  color: Color(0xff516F7C),
                                ),
                                SizedBox(width: 20),
                                Text('電子圍籬', style: TextStyle(fontSize: 35, color: Color(0xff516F7C))),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        InkWell(
                          onTap: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    //bluetooth
                                    builder: (context) => RealTimeImage(),
                                    maintainState: false));
                          },
                          child: Container(
                            width: 200,
                            height: 98,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.fence_rounded,
                                  size: 40,
                                  color: Color(0xff516F7C),
                                ),
                                SizedBox(width: 20),
                                Text('影像傳輸', style: TextStyle(fontSize: 35, color: Color(0xff516F7C))),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        InkWell(
                          onTap: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    //bluetooth
                                    builder: (context) => BluetoothSerialPage(),
                                    maintainState: false));
                          },
                          child: Container(
                            width: 200,
                            height: 98,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.bluetooth,
                                  size: 40,
                                  color: Color(0xff516F7C),
                                ),
                                SizedBox(width: 20),
                                Text('bluetooth', style: TextStyle(fontSize: 35, color: Color(0xff516F7C))),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        InkWell(
                          onTap: () async {
                            //登出
                            //刪除shareprefence
                            SharedPreferences preferences = await SharedPreferences.getInstance();
                            await preferences.clear();
                            //刪除sqlite database
                            await deleteDatabase(join(await getDatabasesPath(), 'usermemo.db'));
                            await deleteDatabase(join(await getDatabasesPath(), 'notice.db'));
                            await deleteDatabase(join(await getDatabasesPath(), 'todo.db'));
                            await deleteDatabase(join(await getDatabasesPath(), 'people.db'));
                            Navigator.pushAndRemoveUntil(
                                context,
                                //跳轉到主頁
                                new MaterialPageRoute(builder: (context) => new LoginPage()),
                                (Route<dynamic> route) => false);
                          },
                          child: Container(
                            width: 200,
                            height: 98,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Row(
                              //登出按鈕
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.logout,
                                  size: 40,
                                  color: Color(0xff516F7C),
                                ),
                                SizedBox(width: 20),
                                Text('log out', style: TextStyle(fontSize: 35, color: Color(0xff516F7C))),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      //todo 影藏通知欄
      // appBar: PreferredSize(
      //   preferredSize: Size.fromHeight(MediaQueryData.fromWindow(window).padding.top),
      //   child: SafeArea(
      //     top: true,
      //     child: Offstage(),
      //   ),
      // ),
      body: Stack(
        children: [
          /* ----------------------------------- 地圖 ----------------------------------- */
          Animarker(
            // marker移動動畫
            curve: Curves.ease,
            rippleRadius: 0.2,
            useRotation: false,
            duration: Duration(milliseconds: 2300),
            mapId: _controller.future.then<int>((value) => value.mapId), //Grab Google Map Id
            markers: markers.values.toSet(),
            child: Stack(children: [
              GoogleMap(
                mapToolbarEnabled: false,
                myLocationEnabled: false,
                zoomControlsEnabled: true,
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(target: LatLng(widget.initialPosition.latitude, widget.initialPosition.longitude), zoom: 10.0),
                onTap: (position) {
                  customInfoWindowController.hideInfoWindow();
                  hideCustomInfoWindow = true;
                },
                onCameraMove: (position) {
                  customInfoWindowController.onCameraMove();
                },
                onMapCreated: (GoogleMapController controller) {
                  controller.setMapStyle(Utils.mapStyles);
                  customInfoWindowController.googleMapController = controller;
                  _controller.complete(controller);
                },
              ),
              CustomInfoWindow(controller: customInfoWindowController, height: 80, width: 200, offset: 50),
            ]),
          ),
          // BottonsheetsWidget(),

          /* ------------------------------- circlelist ------------------------------- */

          Friendcircle(_controller, friendposition, markers, customInfoWindowController, context),

          /* ---------------------------------- 功能列按鈕 --------------------------------- */
          Align(
            //功能列按鈕
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).padding.top, 0, 10),
              child: IconButton(
                icon: Icon(Icons.list),
                iconSize: 50,
                onPressed: () {
                  //打開Drawer
                  scaffoldKey.currentState.openDrawer();
                },
              ),
            ),
          ),

          /* ---------------------------------- 通知區塊 ---------------------------------- */
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).padding.top + 5, 10, 0),
              child: GestureDetector(
                  //author danny
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 45,
                      ),
                      AnimatedContainer(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                        height: !isExpanded ? 0 : 346,
                        width: !isExpanded ? 0 : MediaQuery.of(context).size.width,
                        curve: Curves.fastLinearToSlowEaseIn,
                        duration: Duration(milliseconds: 700),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFEED3D3).withOpacity(0.5),
                              blurRadius: 20,
                              offset: Offset(5, 10),
                            ),
                          ],
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        child: !isExpanded
                            ? null
                            : Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '通知',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      IconButton(
                                          icon: Icon(Icons.cancel, size: 32),
                                          onPressed: () {
                                            setState(() {
                                              isExpanded = false;
                                            });
                                          }),
                                    ],
                                  ),
                                  Divider(
                                    color: Colors.black,
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    height: 242,
                                    child: FutureBuilder(
                                      //通知項目
                                      future: NotificationData().queryall(),
                                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                                        printcolor('map.dart 445:69// length:${snapshot.data.length}', color: DColor.green);
                                        return ListView.builder(
                                          itemCount: snapshot.data.length,
                                          itemBuilder: (context, index) {
                                            return InkWell(
                                                customBorder: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                onTap: () {},
                                                child: Container(
                                                  padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                                                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x2D000000)))),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(
                                                          //大頭貼
                                                          width: 50,
                                                          height: 50,
                                                          margin: EdgeInsets.all(5),
                                                          decoration: BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              image: DecorationImage(
                                                                image: snapshot.data[index]['photo'] != null ? MemoryImage(snapshot.data[index]['photo']) : AssetImage('assets/images/unnamed.jpg'),
                                                                fit: BoxFit.cover,
                                                              ))),
                                                      Column(
                                                        children: [
                                                          Text(
                                                            snapshot.data[index]['title'],
                                                            style: TextStyle(fontSize: 30),
                                                          ),
                                                          Text(
                                                            snapshot.data[index]['content'],
                                                            style: TextStyle(fontSize: 25),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ));
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  )),
            ),
          ),
          /* ---------------------------------- 通知區塊 ---------------------------------- */
        ],
      ),
    );
  }

/* -------------------------------------------------------------------------- */
/*                                  FUNCTION                                  */
/* -------------------------------------------------------------------------- */

/* ------------------------------- 取得marker資料 ------------------------------- */

  getmarkerdata() async {
    //
    await sqlitehelp.open();
    return await sqlitehelp.querymarker();
  }

  getfriendposition() async {
    var datas = await ApiTool.getUserPosition();
    if (datas.isNotEmpty) {
      for (var data in datas) {
        BitmapDescriptor photosticker;
        Uint8List photo;
        if (data['userData']['photo'] != null) {
          photo = await networkImageToByte(data['userData']['photo']); //網路照片轉Uint8List
        } else {
          ByteData imageBytes = await rootBundle.load('assets/images/unnamed.jpg');
          photo = imageBytes.buffer.asUint8List();
        }
        photosticker = await getMarkerIcon(photo, Size(150, 150));
        if (data['position'] != null) {
          newLocationUpdate(
              LatLng(
                data['position']['latitude'].runtimeType == double ? data['position']['latitude'] : double.parse(data['position']['latitude']),
                data['position']['longitude'].runtimeType == double ? data['position']['longitude'] : double.parse(data['position']['longitude']),
              ),
              MarkerId(data['userData']['id'].toString()),
              photosticker,
              photo,
              data['userData']['name']);
        }
      }
    }
    // Create echo instance
    Echo echo = new Echo({
      'broadcaster': 'socket.io',
      // 'host': 'http://r-dap.com:6001',
      'host': 'http://140.128.101.175:6001',
      'client': IO.io,
      'auth': {
        'headers': {'Authorization': 'Bearer ${widget.token}'}
      }
    });
    // Accessing socket instance
    echo.socket.on('connect', (_) => print('marker connected'));
    echo.socket.on('disconnect', (_) => print('marker disconnected'));
    await sqlitehelp.open();
    var frienddata = await sqlitehelp.queryAll();
    printcolor('map.dart 636:26// frienddata:$echo', color: DColor.orange);
    //訂閱所有朋友的位置channel
    for (var data in frienddata) {
      var id = data['id'].toString();
      var photosticker, ui8lphotosticker;
      if (data['photo'] != null) {
        ui8lphotosticker = data['photo'];
      } else {
        ByteData imageBytes = await rootBundle.load('assets/images/photosticker.jfif');
        ui8lphotosticker = imageBytes.buffer.asUint8List();
      }
      photosticker = await getMarkerIcon(ui8lphotosticker, Size(150, 150));
      echo.private('userPosition.' + id.toString()).listen('PostUserLL', (e) {
        printcolor('id:$id echo position ${LatLng(e['data']['latitude'], e['data']['longitude'])}', color: DColor.orange);
        friendposition[id] = LatLng(e['data']['latitude'], e['data']['longitude']);
        newLocationUpdate(LatLng(e['data']['latitude'], e['data']['longitude']), MarkerId(id), photosticker, ui8lphotosticker, data['name']);
        setState(() {});
      });
    }
    printcolor('map.dart 654:30// 成功訂閱');
  }

  getnotifications() async {
    // Create echo instance
    Echo echo = new Echo({
      'broadcaster': 'socket.io',
      'host': 'https://r-dap.com:6001',
      'client': IO.io,
      'auth': {
        'headers': {'Authorization': 'Bearer ${widget.token}'}
      }
    });
    // Accessing socket instance
    echo.socket.on('connect', (_) => print('notification connected'));
    echo.socket.on('disconnect', (_) => print('notification disconnected'));

    SharedPreferences preferences = await SharedPreferences.getInstance();
    var id = preferences.getString('id');
    printcolor('map.dart 555:24 // id=$id', color: DColor.green);
    echo.private('App.Models.User.' + id).notification((notification) {
      switch (notification['type']) {
        case 'App\\Notifications\\friendInvitationNotification':
          putnotificationintodatabase(
            '${notification['data']['userData']['name']}',
            '想成為你好友',
            notification['data']['userData']['photo'],
            notification['type'],
            notification['data'],
          );
          break;
        case 'App\\Notifications\\emegencyNotification':
          putnotificationintodatabase(
            '${notification['data']['userData']['name']}',
            '${notification['data']}',
            notification['data']['userData']['photo'],
            notification['type'],
            notification['data']['latlong'],
          );
      }
    });
  }

  putnotificationintodatabase(String title, String content, String photourl, String type, var data) async {
    printcolor('map.dart 612:26 // 加入通知', color: DColor.green);
    // ignore: avoid_init_to_null
    Uint8List photo = null;
    if (photourl != null) {
      photo = await networkImageToByte(photourl);
    }
    var sqlitehelp = NotificationData();
    var dataform = {
      'title': title,
      'content': content,
      'photo': photo,
      'type': type,
      'data': data,
      'isopened': 0,
    };
    sqlitehelp.insert(dataform);
  }
/* ------------------------------- 更新marker位置 ------------------------------- */

  void newLocationUpdate(LatLng latLng, MarkerId markerid, photo, Uint8List ui8lphotosticker, String name) {
    var marker = RippleMarker(
        icon: photo,
        markerId: markerid,
        position: latLng,
        ripple: false,
        onTap: () {
          print('Tapped! $latLng');
          customInfoWindowController.addInfoWindow(Infowindow(markerid.value, name, ui8lphotosticker, infowindowcontext, latLng.latitude.toString(), latLng.longitude.toString()), latLng);
          hideCustomInfoWindow = false;
        });
    setState(() => markers[markerid] = marker);
  }

/* --------------------------------- 跟隨目前位置 --------------------------------- */

  Future<void> centerScreen(Position position) async {
    if (hideCustomInfoWindow) {
      final GoogleMapController controller = await _controller.future;
      //map camera animation
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 18.0)));
    }
    //當移動時post目前位置
    ApiTool.postlocation(position.latitude, position.longitude);
  }
}

class Utils {
  //地圖樣式
  static String mapStyles = '''[
  {
    "featureType": "administrative.province",
    "stylers": [
      {
        "visibility": "simplified"
      }
    ]
  },
  {
    "featureType": "landscape",
    "stylers": [
      {
        "hue": "#FFBB00"
      },
      {
        "saturation": 43.400000000000006
      },
      {
        "lightness": 37.599999999999994
      },
      {
        "gamma": 1
      }
    ]
  },
  {
    "featureType": "poi",
    "stylers": [
      {
        "hue": "#0a488a"
      },
      {
        "lightness": 10
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "stylers": [
      {
        "hue": "#FF0300"
      },
      {
        "saturation": -100
      },
      {
        "lightness": 51.19999999999999
      },
      {
        "gamma": 1
      }
    ]
  },
  {
    "featureType": "road.highway",
    "stylers": [
      {
        "hue": "#FFC200"
      },
      {
        "saturation": -61.8
      },
      {
        "lightness": 45.599999999999994
      },
      {
        "gamma": 1
      }
    ]
  },
  {
    "featureType": "road.local",
    "stylers": [
      {
        "hue": "#FF0300"
      },
      {
        "saturation": -100
      },
      {
        "lightness": 52
      },
      {
        "gamma": 1
      }
    ]
  },
  {
    "featureType": "water",
    "stylers": [
      {
        "hue": "#0078FF"
      },
      {
        "saturation": -13.200000000000003
      },
      {
        "lightness": 2.4000000000000057
      },
      {
        "gamma": 1
      }
    ]
  }
]''';
}
