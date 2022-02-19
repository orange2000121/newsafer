import 'package:newsafer/tool/debug.dart';
import 'package:newsafer/tool/old_api_tool.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newsafer/screens/old_main_menu.dart';
import 'package:newsafer/tool/old_memo_database.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class old_memo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return old_memoState();
  }
}

class old_memoState extends State<old_memo> {
  final PageController date_controller = PageController(initialPage: 100);
  // 指定一個控制器，用來控制PageView的滑動，以及初始位置在第100頁
  // 主要爲了實現“無限循環”

  final memo_information_Controller = TextEditingController(); // 建立控制器，用於按鈕偵測輸入框是否有輸入備忘錄內容
  final SlidableController slidableController = SlidableController(); // 建立控制器，一次只能打開一個清單的選項

  final sqlitehelp = oldmemo();

  void insert_old_memo(int notes_num, int id, String name, String memo_information, var create_at, var date, int _checked) async {
    //新增資料
    var m = {'notes_num': notes_num, 'id': id, 'name': name, 'content': memo_information, 'created_by': create_at, 'date': date, 'finish_status': _checked};
    await sqlitehelp.open();
    await sqlitehelp.insert(m);
    queryAll_old_memo_check();
    setState(() {});
  }

  int count; //記錄未完成事項
  int count1; //紀錄已完成事項
  double progress;
  int memo_hasData;
  String date_page;
  Future queryAll_old_memo_check() async {
    //取得資料用於統計完成事項
    await sqlitehelp.open();
    var datas = await sqlitehelp.queryAll_old_memo_information(date_page); //取得表單資料丟到datas，他會存為list，而list裡有好幾個json
    // print('備忘錄資料庫內容：${datas[0]['_checked']}');
    count = 0;
    count1 = 0;
    progress = 0;
    memo_hasData = 0;
    if (datas[0]['num'] != null) {
      for (int i = 0; i < datas.length; i++) {
        if (datas[i]['_checked'] == 0) {
          count++;
        } else if (datas[i]['_checked'] == 1) {
          count1++;
        }
      }
      progress = count1 / datas.length;
      memo_hasData = 1;
    }
    return [count, progress, memo_hasData];
  }

  int update_num;
  bool showTextField = false; //加入備忘錄資料，出現輸入框
  bool showTextField_update = false; //更改備忘錄資料，出現輸入框
  Widget _buildFloatingAddBtn() {
    return Expanded(
      child: Container(
        height: 70.0,
        width: 70.0,
        child: FittedBox(
          child: FloatingActionButton(
            //悬浮按钮
            backgroundColor: Color(0xFFC1D5D5),
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, image: new DecorationImage(image: new AssetImage("assets/images/備忘錄按鈕.png"), fit: BoxFit.fill)),
            ),
            onPressed: () {
              setState(() {
                showTextField = !showTextField;
              });
              if (memo_information_Controller.text != '' && showTextField_update == false) {
                //新增備忘錄內容
                String id = '0'; //先不給值，之後補上
                String memo_information = memo_information_Controller.text;
                var date = date_page;
                int finish_status = 0;
                Map<String, dynamic> oldmemoinfomation = ApiTool_old_memo.insertMemo(
                  id,
                  date,
                  memo_information,
                ); //伺服器新增備忘錄
                printcolor('memo infomation : $oldmemoinfomation', color: DColor.blue);
                insert_old_memo(oldmemoinfomation['notes_num'], oldmemoinfomation['user_id'], oldmemoinfomation['name'], oldmemoinfomation['content'], oldmemoinfomation['created_by'].toString(),
                    oldmemoinfomation['date'], finish_status); //本地端新增備忘錄
                memo_information_Controller.clear();
              } else if (memo_information_Controller.text != '' && showTextField_update == true) {
                //修改備忘錄內容
                int num = update_num;
                String memo_information = memo_information_Controller.text;
                Map<String, dynamic> oldmemoinfomation = ApiTool_old_memo.updatatMemo(
                  num,
                  memo_information,
                ); //伺服器修改備忘錄
                sqlitehelp.updata_memo_information(oldmemoinfomation['content'], oldmemoinfomation['notes_num']);
                showTextField_update = false;
                update_num = null;
                memo_information_Controller.clear();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return Expanded(
      flex: 2, //讓加號按鈕與輸入框貼近
      child: Form(
        //備忘錄輸入框
        //key: signUp._namekey,
        child: Padding(
          padding: EdgeInsets.fromLTRB(25, 0, 0, 0),
          child: TextFormField(
            obscureText: false, //隱藏文字
            autofocus: true, //自動對焦
            keyboardType: TextInputType.text, //普通完整鍵盤
            controller: memo_information_Controller, // 設定控制器
            //inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[a-z,A-Z,0-9]"))], //限制只允许输入字母和数字
            textInputAction: TextInputAction.done, //定義鍵盤enter按鈕
            decoration: InputDecoration(
              filled: true, //需要加這行才可以填充背景色
              fillColor: Color(0xFFF7F7F7), //底色
              hintText: '請輸入提醒事項',
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    memo_information_Controller.dispose(); // 釋放控制器
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(

        /// 一個固定大小的容器，這裏指定了他的高爲250
        height: MediaQuery.of(context).size.height,
        child: Container(
          /// 一個容器，用來設定背景顏色爲灰色
          color: Colors.white,
          child: PageView.builder(
            /// 主角PageView,文字居中顯示當前的索引
            controller: date_controller,
            itemBuilder: (context, index) {
              String date_page_now = formatDate(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + index - 100), [yyyy, '-', mm, '-', dd]);
              date_page = date_page_now;
              return new Center(
                child: Scaffold(
                  //第一張卡片
                  appBar: AppBar(
                    //上排工具列
                    title: Text(
                      //日期
                      '${date_page_now}',
                      // '${formatDate(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + index - 100), [yyyy, '/', mm, '/', dd])}',
                      style: TextStyle(color: Color(0xFF456572), fontSize: 20),
                    ),
                    backgroundColor: Color(0xFFDCEBEB),
                    shadowColor: Colors.transparent, //上列底下陰影
                    //toolbarHeight: 70.0,
                    leading: IconButton(
                      onPressed: () async {
                        Navigator.push(
                            context,
                            //跳轉老人主選單
                            MaterialPageRoute(builder: (context) => old_main_menu(), maintainState: false));
                      },
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xFF456572),
                      ),
                    ),
                  ),

                  body: Container(
                    width: MediaQuery.of(context).size.width, //寬度: 偵查個人手機寬度
                    height: MediaQuery.of(context).size.height, //長度: 偵查個人手機長度
                    child: Stack(
                      children: <Widget>[
                        Container(
                          //藍色區域（頭像資料）
                          width: MediaQuery.of(context).size.width, //寬度: 偵查個人手機寬度
                          height: MediaQuery.of(context).size.height, //長度: 偵查個人手機長度
                          color: Color(0xFFDCEBEB), //底色
                          child: Column(
                            children: [
                              Container(
                                child: Row(
                                  children: [
                                    SizedBox(width: 25.0),
                                    Container(
                                      width: 70,
                                      height: 70,
                                      decoration:
                                          BoxDecoration(color: Colors.white, shape: BoxShape.circle, image: new DecorationImage(image: new AssetImage("assets/images/老人1.jpg"), fit: BoxFit.fill)),
                                    ),
                                    SizedBox(width: 15.0),
                                    FutureBuilder(
                                      future: queryAll_old_memo_check(),
                                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                                        if (memo_hasData == 1) {
                                          return Column(
                                            children: [
                                              Padding(
                                                  //顯示完成事項文字
                                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                  child: Text(
                                                    "今日還有 $count 項未完成哦～",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontWeight: FontWeight.w400, //設定字粗體大小
                                                      color: Color(0xFF707781),
                                                      fontSize: 20,
                                                    ),
                                                  )),
                                              Container(
                                                //進度條
                                                width: MediaQuery.of(context).size.width - 150,
                                                height: 15,
                                                decoration: BoxDecoration(color: Colors.blueGrey[50], border: Border.all(color: Colors.teal[300], width: 2), borderRadius: BorderRadius.circular(50)),
                                                child: Stack(
                                                  children: [
                                                    LayoutBuilder(
                                                      builder: (context, constraints) => Container(
                                                        width: (MediaQuery.of(context).size.width - 150) * progress,
                                                        decoration: BoxDecoration(
                                                          gradient: LinearGradient(colors: [
                                                            Colors.teal[300],
                                                            Colors.teal[100],
                                                          ]),
                                                          borderRadius: BorderRadius.circular(50),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                        return Column(
                                          children: [
                                            Padding(
                                                //顯示完成事項文字
                                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                child: Text(
                                                  "今日還沒有新增事項哦～",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontWeight: FontWeight.w400, //設定字粗體大小
                                                    color: Color(0xFF707781),
                                                    fontSize: 20,
                                                  ),
                                                )),
                                            Container(
                                              //進度條
                                              width: MediaQuery.of(context).size.width - 150,
                                              height: 15,
                                              decoration: BoxDecoration(color: Colors.blueGrey[50], border: Border.all(color: Colors.teal[300], width: 2), borderRadius: BorderRadius.circular(50)),
                                              child: Stack(
                                                children: [
                                                  LayoutBuilder(
                                                    builder: (context, constraints) => Container(
                                                      width: (MediaQuery.of(context).size.width - 150) * 1,
                                                      decoration: BoxDecoration(
                                                        gradient: LinearGradient(colors: [
                                                          Colors.teal[300],
                                                          Colors.teal[100],
                                                        ]),
                                                        borderRadius: BorderRadius.circular(50),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Align(
                          //白色區域（備忘錄提醒資料）
                          alignment: Alignment.bottomLeft, //貼底置中
                          child: Container(
                            alignment: Alignment.bottomLeft, //貼底置中
                            width: MediaQuery.of(context).size.width, //寬度: 偵查個人手機寬度，且減去100
                            height: MediaQuery.of(context).size.height - 200, //長度: 偵查個人手機長度，且減去100
                            decoration: BoxDecoration(
                                color: Color(0xFFF7F7F7), //底色
                                borderRadius: BorderRadius.vertical(
                                  //設置圓角
                                  top: Radius.circular(50),
                                  bottom: Radius.zero,
                                )),
                            child: FutureBuilder(
                                //取得備忘錄的資料庫內容
                                future: sqlitehelp.queryAll_old_memo_information(date_page_now), //需要給future，但需要確定資料庫已經open，寫在最前面
                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                  if (snapshot.hasData) {
                                    List oldmemo = snapshot.data; //抓取老人備忘錄資料庫的資料
                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(30, 35, 30, 35),
                                      child: AnimationLimiter(
                                        child: ListView.builder(
                                            itemCount: oldmemo.length, //告訴他元素總共是snapshot.data裡面的陣列
                                            itemBuilder: (context, index) {
                                              return AnimationConfiguration.staggeredList(
                                                position: index,
                                                duration: const Duration(milliseconds: 375),
                                                child: SlideAnimation(
                                                  //滑動動畫
                                                  verticalOffset: 10.0,
                                                  child: FadeInAnimation(
                                                    //漸隱漸現動畫
                                                    child: Container(
                                                      margin: EdgeInsets.all(5),
                                                      // color:
                                                      //     Theme.of(context).primaryColor,
                                                      child: Slidable(
                                                        //右邊展開選項（更改、刪除）
                                                        controller: slidableController,
                                                        actionPane: SlidableDrawerActionPane(),
                                                        actionExtentRatio: 0.30, // 每個 action 大小佔全部百分比
                                                        // 右邊展開事件選項
                                                        secondaryActions: <Widget>[
                                                          IconSlideAction(
                                                              // caption: 'update',
                                                              color: Colors.blueGrey[500],
                                                              icon: Icons.border_color_rounded,
                                                              onTap: () async {
                                                                showTextField = true;
                                                                showTextField_update = true;
                                                                update_num = snapshot.data[index]['num'];
                                                                setState(() {});
                                                              }),
                                                          IconSlideAction(
                                                              // caption: 'Delete',
                                                              color: Colors.red[500],
                                                              icon: Icons.delete,
                                                              onTap: () async {
                                                                await sqlitehelp.delete(snapshot.data[index]['num']);
                                                                queryAll_old_memo_check();
                                                                setState(() {});
                                                              }),
                                                        ],
                                                        child: Container(
                                                          height: 65.0,
                                                          child: Row(
                                                            children: [
                                                              SizedBox(width: 10.0),
                                                              InkWell(
                                                                onTap: () async {
                                                                  snapshot.data[index]['_checked'] == 1
                                                                      ? await sqlitehelp.updata_checked(0, snapshot.data[index]['num'])
                                                                      : await sqlitehelp.updata_checked(1, snapshot.data[index]['num']);
                                                                  queryAll_old_memo_check();
                                                                  setState(() {});
                                                                },
                                                                child: Container(
                                                                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blueGrey[200]),
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(2.0),
                                                                    child: snapshot.data[index]['_checked'] == 1
                                                                        ? Icon(
                                                                            Icons.check,
                                                                            size: 30.0,
                                                                            color: Colors.white,
                                                                          )
                                                                        : Icon(
                                                                            Icons.circle,
                                                                            size: 30.0,
                                                                            color: Colors.white,
                                                                          ),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(width: 30.0),
                                                              Text(
                                                                '${snapshot.data[index]['memo_information']}',
                                                                style: TextStyle(
                                                                  fontFamily: 'Poppins',
                                                                  fontWeight: FontWeight.w400, //設定字粗體大小
                                                                  color: Color(0x996D7660),
                                                                  fontSize: 28,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                      ),
                                    );
                                  }
                                  return Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        '目前還未新增備忘錄內容',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w400, //設定字粗體大小
                                          color: Color(0x996D7660),
                                          fontSize: 25,
                                        ),
                                      )); //如果沒有資料，就給他Container
                                }),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              //padding: EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
                              child: Row(
                                children: <Widget>[
                                  showTextField
                                      ? _buildTextField()
                                      : Container(
                                          //讓加號按鈕靠右下
                                          width: MediaQuery.of(context).size.width - 130, //寬度: 偵查個人手機寬度
                                        ),
                                  _buildFloatingAddBtn(),
                                ],
                              ),
                            ),
                            Container(
                              height: 35.0,
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ));
  }
}
