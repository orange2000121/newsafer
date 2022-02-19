import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tool/api_tool.dart';
import '../tool/debug.dart';
import 'package:camera/camera.dart';

class Findfriend extends StatefulWidget {
  @override
  _FindfriendState createState() => _FindfriendState();
}

class _FindfriendState extends State<Findfriend> {
  TextEditingController idcontroller = TextEditingController();
  String friendid; //輸入id的變數
  dynamic frienddata; //回傳資料
  String prompttext = '';
  ValueNotifier<bool> openqrcode = ValueNotifier<bool>(false);
  final idkey = GlobalKey<FormState>();
  CameraController controller;
  List<CameraDescription> cameras;
  void camera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void initState() {
    camera();
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        // onNewCameraSelected(controller.description);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '搜尋好友',
          style: TextStyle(color: Color(0xFF0A0C0E)),
        ),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF22C27F),
          ),
        ),
      ),
      body: Container(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Form(
              key: idkey,
              child: TextFormField(
                keyboardType: TextInputType.text, //輸入型態
                autofocus: false,
                controller: idcontroller, //給sharedpreference存
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[a-z,A-Z,0-9]"))], //限制只允许输入字母和数字
                textInputAction: TextInputAction.search, //定義鍵盤enter按鈕
                onFieldSubmitted: (value) async {
                  //按下enter鍵執行動作
                  Printcolor.log(idkey.currentState.validate().toString(), color: DColor.blue);
                  if (idcontroller.text.isNotEmpty) {
                    frienddata = await ApiTool.searchuser(idcontroller.text);
                  }
                  setState(() {});
                },
                decoration: InputDecoration(
                  //樣式
                  icon: Icon(Icons.person),
                  hintText: 'Rdap ID',
                  labelText: 'ID *',
                  suffixIcon: SizedBox(
                    width: 100,
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              openqrcode.value = !openqrcode.value;
                            },
                            icon: Icon(Icons.qr_code_scanner)),
                        IconButton(
                            //收尋按鈕
                            icon: Icon(Icons.search),
                            onPressed: () async {
                              print(idkey.currentState.validate());
                              if (idcontroller.text.isNotEmpty) {
                                frienddata = await ApiTool.searchuser(idcontroller.text);
                              }
                              setState(() {});
                            }),
                      ],
                    ),
                  ),
                ),
                validator: (value) {
                  if (value.isNotEmpty) {
                    return '';
                  } else {
                    return '請輸入id';
                  }
                },
              ),
            ),
          ),
          ValueListenableBuilder(
            //監聽是否開啟qrcode功能
            valueListenable: openqrcode,
            builder: (BuildContext context, bool qrcodeopen, Widget child) {
              ValueNotifier<bool> scancontainer = ValueNotifier<bool>(true);
              return qrcodeopen
                  ? Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.width * 0.8 + 70,
                      decoration:
                          BoxDecoration(color: Color(0xffE1E9EA), borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: ValueListenableBuilder(
                        //監聽是否開啟掃描功能
                        valueListenable: scancontainer,
                        builder: (BuildContext context, bool qrscan, Widget child) {
                          return Column(
                            children: [
                              Container(
                                width: 180,
                                margin: EdgeInsets.all(20),
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(23)),
                                ),
                                child: Stack(
                                  children: [
                                    TweenAnimationBuilder(
                                      duration: const Duration(milliseconds: 300),
                                      tween: Tween(begin: qrscan ? 90 : 0, end: qrscan ? 0 : 90),
                                      builder: (BuildContext context, int value, Widget child) {
                                        return Positioned(
                                          left: value.toDouble(),
                                          child: Container(
                                            width: 90,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: Color(0xff4E6E7A),
                                              borderRadius: BorderRadius.all(Radius.circular(23)),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                          child: IconButton(
                                              onPressed: () {
                                                scancontainer.value = true;
                                              },
                                              icon: Icon(Icons.qr_code_scanner)),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                          child: IconButton(
                                              onPressed: () {
                                                scancontainer.value = false;
                                              },
                                              icon: Icon(Icons.qr_code_2)),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.64,
                                height: MediaQuery.of(context).size.width * 0.64,
                                child: qrscan
                                    ? CameraPreview(controller)
                                    : Container(
                                        decoration: BoxDecoration(
                                            image: DecorationImage(image: AssetImage('assets/images/qr.ioi.tw.png'))),
                                      ),
                              )
                            ],
                          );
                        },
                      ),
                    )
                  : frienddata == null
                      ? Container()
                      : Container(
                          child: (!frienddata['status'])
                              ? Text(
                                  '使用者不存在',
                                  style: TextStyle(fontSize: 25),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 0.6,
                                    // height: MediaQuery.of(context).size.height * 0.3,
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 120,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              image: (frienddata['photo'] != null)
                                                  ? NetworkImage(frienddata['photo'])
                                                  : AssetImage("assets/images/unnamed.jpg"),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          frienddata['name'],
                                          style: TextStyle(fontSize: 30),
                                        ),
                                        Container(
                                            width: 150,
                                            alignment: Alignment.center,
                                            child: (frienddata['alreadyBeFriend'])
                                                ? Text(
                                                    '已加好友',
                                                    style: TextStyle(fontSize: 18),
                                                  )
                                                : (frienddata['searchMyself'])
                                                    ? Text(
                                                        '無法加自己為好友',
                                                        style: TextStyle(fontSize: 18, color: Color(0x9D000000)),
                                                      )
                                                    : ElevatedButton(
                                                        onPressed: () async {
                                                          var response = await ApiTool.wantAddFriend(frienddata['id']);
                                                          prompttext = response['reason'];
                                                          setState(() {});
                                                        },
                                                        style: ElevatedButton.styleFrom(primary: Color(0xFF5A6248)),
                                                        child: Text(
                                                          '加入好友',
                                                          style: TextStyle(color: Colors.white),
                                                        ),
                                                      )),
                                        Text(prompttext),
                                      ],
                                    ),
                                  ),
                                ));
            },
          ),
        ],
      )),
    );
  }
  /* -------------------------------------------------------------------------- */
  /*                                     副程式                                    */
  /* -------------------------------------------------------------------------- */

}
