//import 'package:newsafer/tool/api_tool.dart';
import 'package:flutter/material.dart'; //引入 Material Design 設計風格的基礎包
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newsafer/pages/profile/editprofilepage.dart';

class BaseInformation extends StatefulWidget {
  //BaseInformation繼承了 StatelessWidget，這會使應用本身也成为一个 widget
  //(note):Flutter 中有一切皆 widget 的概念，
  //widget 分為 StatelessWidget（無狀態 widget）和 StatefulWidget（有状態 widget）。

  final SharedPreferences preferences; //定義一個SharedPreferences接收傳入值，用於個人資料的顯示
  BaseInformation(this.preferences);
  @override
  ProfilePage createState() => ProfilePage(); // Dart 程序的入口，使用了 => 符号，這是 Dart 中單行函數或方法的簡寫
}

//Image headphoto;

class ProfilePage extends State<BaseInformation> {
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //build 方法用来描述如何用其他較低级别的 widget 来顯示自身

    return Scaffold(
        //Scaffold 是 Material Design 布局结構的基本實现 内部包含了 appBar 和 body
        appBar: AppBar(
            //為應用程序欄，它在 Scaffold 的顶部
            elevation: 0.0,
            backgroundColor: Color(0xFF80CBC4),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black87,
                size: 30,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )),
        body: Stack(
          //將一個小部件重疊在另一個小部件上
          //body為Scaffold 的主要内容
          alignment: Alignment.center,
          children: [
            CustomPaint(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
              painter: HeaderCurvedContainer(),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "使用者資料",
                  style: TextStyle(
                    fontSize: 40,
                    letterSpacing: 2,
                    color: Colors.black87,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                width: 200,
                child: ClipOval(
                  child: CircleAvatar(
                    radius: 100,
                    backgroundImage: widget.preferences.getString('headimage') == null ? AssetImage('assets/images/unnamed.jpg') : NetworkImage(widget.preferences.getString('headimage')),

                    ///FileImage(File(widget.preferences.getString('imagepath'))),
                  ),
                ),
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  border: new Border.all(
                    color: Colors.white,
                    width: 4.0,
                  ),
                ),
              ),
            ]),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                    height: 550,
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 10), //元件間距vertical: 垂直間距, horizontal: 水平間距
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly, //將空白區域均分，使各子控件間格相同
                      children: [
                        Card(
                          child: Container(
                            alignment: Alignment.topLeft,
                            padding: EdgeInsets.all(15),
                            child: Column(
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    ...ListTile.divideTiles(
                                      color: Colors.grey,
                                      tiles: [
                                        ListTile(
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4), //元件間距
                                          leading: Icon(Icons.person, size: 50),
                                          title: Text(
                                            "姓名",
                                            style: TextStyle(
                                              //可以設定字體大小、顏色等樣式
                                              fontSize: 20,
                                              letterSpacing: 2,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Text(
                                            widget.preferences.getString('name'),
                                            style: TextStyle(
                                              fontSize: 30,
                                              letterSpacing: 2,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.blur_linear, size: 50),
                                          title: Text(
                                            "R-DAP ID",
                                            style: TextStyle(
                                              fontSize: 20,
                                              letterSpacing: 2, //每個字母之間添加的空間量（以邏輯像素為單位）。可以使用負值使字母更接近
                                              color: Colors.black87,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Text(
                                            widget.preferences.getString('user_id'),
                                            style: TextStyle(
                                              fontSize: 30,
                                              letterSpacing: 2,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                            height: 55,
                            width: double.infinity,
                            child: ElevatedButton(
                                onPressed: () async {
                                  SharedPreferences preferences = await SharedPreferences.getInstance();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          //跳轉到基本資料頁面
                                          builder: (context) => EditProfilePage(preferences),
                                          maintainState: false));
                                },
                                style: ElevatedButton.styleFrom(primary: Color(0xFF80CBC4)),
                                child: Center(
                                    child: Text("修改資料",
                                        style: TextStyle(
                                          fontSize: 25,
                                          letterSpacing: 2,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w600,
                                        )))))
                      ],
                    ))
              ],
            ),
          ],
        ));
  }
}

class HeaderCurvedContainer extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Color(0xFF80CBC4);
    Path path = Path()
      ..relativeLineTo(0, 150)
      ..quadraticBezierTo(size.width / 2, 225, size.width, 150)
      ..relativeLineTo(0, -150)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
