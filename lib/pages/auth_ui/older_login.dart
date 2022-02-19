import 'package:newsafer/screens/old_main_menu.dart';
import 'package:newsafer/tool/api_tool.dart';
import 'package:newsafer/tool/people_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:network_image_to_byte/network_image_to_byte.dart';

class OlderLogin extends StatefulWidget {
  @override
  _OlderLoginState createState() => _OlderLoginState();
}

class _OlderLoginState extends State<OlderLogin> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        SizedBox(height: 50.0), //填充行距
        Column(
          mainAxisAlignment: MainAxisAlignment.center, //置中
          children: [
            Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, image: new DecorationImage(image: new AssetImage("assets/images/老人合照.jpg"), fit: BoxFit.fill)),
            )
          ],
        ),
        SizedBox(height: 30.0), //填充行距
        Form(
          //name輸入框
          //key: signUp._namekey,
          child: Padding(
            padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: '姓名',
                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
              ),
            ),
          ),
        ),
        Container(
          //Login 按鈕(go)
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.fromLTRB(80, 40, 80, 0),
            child: ElevatedButton(
              onPressed: () async {
                Navigator.pushAndRemoveUntil(
                    context,
                    //跳轉到主頁
                    new MaterialPageRoute(builder: (context) => new old_main_menu()),
                    // (route) => route == null)
                    (Route<dynamic> route) => false);
                Fluttertoast.showToast(
                    msg: "登入成功", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Colors.green, textColor: Colors.white, fontSize: 20.0);
              },
              child: Text('GO', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF7CA7A1),
                padding: EdgeInsets.all(12),
                shadowColor: Color(0xFFFFFFFF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              //google icon
              color: Colors.red[600],
              icon: Icon(FontAwesomeIcons.google),
              iconSize: 40.0,
              onPressed: () async {
                final googleres = await AuthApi.olderLoginGoogle();
                if (googleres['status'] == 'user exit') {
                  Fluttertoast.showToast(
                      msg: "登入成功", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Colors.green, textColor: Colors.white, fontSize: 20.0);
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
                  Navigator.pushAndRemoveUntil(
                      context,
                      //跳轉到主頁
                      new MaterialPageRoute(builder: (context) => new old_main_menu()),
                      // (route) => route == null)
                      (Route<dynamic> route) => false);
                } else {
                  Fluttertoast.showToast(
                      msg: "登入失敗", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 20.0);
                }
              },
            ),
          ],
        )
      ]),
    );
  }
  /* -------------------------------------------------------------------------- */
  /*                                  Function                                  */
  /* -------------------------------------------------------------------------- */

}
