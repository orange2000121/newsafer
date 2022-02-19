import 'package:newsafer/screens/oldmap.dart';
import 'package:newsafer/screens/padetest.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'old_memo.dart';

class old_main_menu extends StatelessWidget {
  const old_main_menu({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      //alignment: Alignment.center, //置中間
      color: Color(0xFFF7F7F7), //底色
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            //定位和樂按鈕
            width: 300,
            height: 85,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pushAndRemoveUntil(
                      context,
                      //跳轉到主頁
                      new MaterialPageRoute(builder: (context) => new Oldmap()),
                      // (route) => route == null)
                      (Route<dynamic> route) => false);
                },
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(image: new DecorationImage(image: new AssetImage("assets/images/老人介面-地圖icon.png"), fit: BoxFit.fill)),
                    ),
                    SizedBox(width: 15.0),
                    Text('定位/和樂',
                        style: TextStyle(
                          color: Color(0xFF456572),
                          fontSize: 28,
                        )),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFDEE7E8),
                  padding: EdgeInsets.fromLTRB(30, 20, 20, 20), //字的位置
                  shadowColor: Color(0x70707070), //按鈕陰影顏色
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
                  elevation: 20, //按鈕陰影大小
                ),
              ),
            ),
          ),
          SizedBox(height: 30.0),
          Container(
            //備忘錄按鈕
            width: 300,
            height: 85,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pushAndRemoveUntil(
                      context,
                      //跳轉到主頁
                      new MaterialPageRoute(builder: (context) => new old_memo()),
                      //(route) => route == null)
                      (Route<dynamic> route) => false);
                },
                child: Row(
                  children: [
                    Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(image: new DecorationImage(image: new AssetImage("assets/images/老人介面-備忘錄icon.png"), fit: BoxFit.fill)),
                    ),
                    SizedBox(width: 15.0),
                    Text('備忘錄',
                        style: TextStyle(
                          color: Color(0xFF456572),
                          fontSize: 28,
                        )),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFDEE7E8),
                  padding: EdgeInsets.fromLTRB(30, 20, 20, 20), //字的位置
                  shadowColor: Color(0x70707070), //按鈕陰影顏色
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
                  elevation: 20, //按鈕陰影大小
                ),
              ),
            ),
          ),
          SizedBox(height: 30.0),
          Container(
            //緊急聯絡人按鈕
            width: 300,
            height: 85,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: ElevatedButton(
                onPressed: () async {
                  // Navigator.pushAndRemoveUntil(
                  //     context,
                  //     //跳轉到主頁
                  //     new MaterialPageRoute(builder: (context) => new checkk()),
                  //     //(route) => route == null)
                  //     (Route<dynamic> route) => false);
                },
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(image: new DecorationImage(image: new AssetImage("assets/images/老人介面-緊急聯絡人icon.png"), fit: BoxFit.fill)),
                    ),
                    SizedBox(width: 15.0),
                    Text('緊急聯絡人',
                        style: TextStyle(
                          color: Color(0xFF456572),
                          fontSize: 28,
                        )),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFDEE7E8),
                  padding: EdgeInsets.fromLTRB(30, 20, 20, 20), //字的位置
                  shadowColor: Color(0x70707070), //按鈕陰影顏色
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
                  elevation: 20, //按鈕陰影大小
                ),
              ),
            ),
          ),
          SizedBox(height: 30.0),
          Container(
            //FM廣播/MP3音樂按鈕
            width: 300,
            height: 85,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: ElevatedButton(
                onPressed: () async {
                  //  Navigator.pushAndRemoveUntil(
                  //      context,
                  //跳轉到主頁
                  //      new MaterialPageRoute(builder: (context) => new Oldmap()),
                  // (route) => route == null)
                  //      (Route<dynamic> route) => false);
                },
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(image: new DecorationImage(image: new AssetImage("assets/images/老人介面-音樂icon.png"), fit: BoxFit.fill)),
                    ),
                    SizedBox(width: 15.0),
                    Text('FM廣播/MP3音樂',
                        style: TextStyle(
                          color: Color(0xFF456572),
                          fontSize: 23,
                        )),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFDEE7E8),
                  padding: EdgeInsets.fromLTRB(30, 20, 20, 20), //字的位置
                  shadowColor: Color(0x70707070), //按鈕陰影顏色
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
                  elevation: 20, //按鈕陰影大小
                ),
              ),
            ),
          ),
          SizedBox(height: 30.0),
          Container(
            //設定按鈕
            width: 300,
            height: 85,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: ElevatedButton(
                onPressed: () async {
                  //  Navigator.pushAndRemoveUntil(
                  //      context,
                  //跳轉到主頁
                  //      new MaterialPageRoute(builder: (context) => new Oldmap()),
                  // (route) => route == null)
                  //      (Route<dynamic> route) => false);
                },
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(image: new DecorationImage(image: new AssetImage("assets/images/老人介面-設定icon.png"), fit: BoxFit.fill)),
                    ),
                    SizedBox(width: 15.0),
                    Text('設定',
                        style: TextStyle(
                          color: Color(0xFF456572),
                          fontSize: 28,
                        )),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFDEE7E8),
                  padding: EdgeInsets.fromLTRB(30, 20, 20, 20), //字的位置
                  shadowColor: Color(0x70707070), //按鈕陰影顏色
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
                  elevation: 20, //按鈕陰影大小
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
