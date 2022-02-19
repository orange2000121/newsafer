import 'package:newsafer/tool/api_tool.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ConfirmFriend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '好友邀請',
          style: TextStyle(color: Colors.black),
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
      body: FutureBuilder(
        future: ApiTool.getUserToBeConfirmFriendList(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return snapshot.data != null
              ? AnimationLimiter(
                  child: ListView.builder(
                    padding: EdgeInsets.all(_w / 30),
                    physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        delay: Duration(milliseconds: 100),
                        child: SlideAnimation(
                          duration: Duration(milliseconds: 2500),
                          curve: Curves.fastLinearToSlowEaseIn,
                          child: FadeInAnimation(
                            curve: Curves.fastLinearToSlowEaseIn,
                            duration: Duration(milliseconds: 2500),
                            child: Container(
                                margin: EdgeInsets.only(bottom: _w / 20),
                                height: _w / 3.5,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                        //大頭貼
                                        width: _w * 0.3,
                                        height: _w * 0.3,
                                        margin: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              image: AssetImage('assets/images/unnamed.jpg'),
                                              fit: BoxFit.cover,
                                            ))),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${snapshot.data[index]['name']}',
                                          style: TextStyle(fontSize: 23),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(5.0),
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  ApiTool.confirmFriend(snapshot.data[index]['id']);
                                                },
                                                style: ElevatedButton.styleFrom(primary: Colors.blue[700], minimumSize: Size(_w * 0.25, _w / 14)),
                                                child: Text('確認', style: TextStyle(color: Color(0xFFFFFFFF))),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(5.0),
                                              child: ElevatedButton(
                                                  onPressed: () {},
                                                  style: ElevatedButton.styleFrom(primary: Color(0xff81A9AC), minimumSize: Size(_w * 0.25, _w / 14)),
                                                  child: Text('刪除', style: TextStyle(color: Color(0xFF000000)))),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                )),
                          ),
                        ),
                      );
                    },
                  ),
                )
              : Text(
                  '目前沒有好友邀請',
                  style: TextStyle(fontSize: 50),
                );
        },
      ),
    );
  }
}
