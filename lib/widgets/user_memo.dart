import 'package:newsafer/tool/api_tool.dart';
import 'package:newsafer/tool/debug.dart';
import 'package:newsafer/tool/people_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class UserMemo extends StatefulWidget {
  final String id;
  UserMemo(this.id);
  @override
  _UserMemoState createState() => _UserMemoState();
}

class _UserMemoState extends State<UserMemo> {
  /* -------------------------------- variable -------------------------------- */
  TextEditingController memoinfomationcontroler = TextEditingController();
  ValueNotifier<bool> openinputbox = ValueNotifier<bool>(false);
  ValueNotifier<int> completenum = ValueNotifier<int>(0);
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  bool editmemo = false;
  int delta = 0;
  late int memonum;
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((message) {
      setState(() {});
    });
  }

  /* ---------------------------------- Build --------------------------------- */
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: const Radius.circular(20), topRight: Radius.circular(20)),
        color: Color(0xffDAE6E7),
      ),
      child: FutureBuilder(
        future: memoinfomation(),
        builder: (BuildContext context, AsyncSnapshot memodata) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Column(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 15),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              onPressed: () {
                                delta -= 1;
                                setState(() {});
                              },
                              icon: const Icon(Icons.chevron_left)),
                          Container(
                            //日期
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(15, 3, 15, 3),
                              child: Text(
                                '${formatter.format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + delta))}',
                                style: const TextStyle(fontSize: 15, color: Colors.black),
                              ),
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                delta += 1;
                                setState(() {});
                              },
                              icon: const Icon(Icons.chevron_right)),
                        ],
                      ),
                      Row(
                        //進度條
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FutureBuilder(
                            future: FriendData().queryonepeople(int.parse(widget.id)),
                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                              return Container(
                                  //大頭貼
                                  width: 50,
                                  height: 50,
                                  margin: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: snapshot.data.isNotEmpty
                                            ? snapshot.data[0]['photo'] != null
                                                ? MemoryImage(snapshot.data[0]['photo'])
                                                : const AssetImage('assets/images/unnamed.jpg') as ImageProvider
                                            : const AssetImage('assets/images/unnamed.jpg'),
                                        fit: BoxFit.cover,
                                      )));
                            },
                          ),
                          Column(
                            children: [
                              ValueListenableBuilder(
                                valueListenable: completenum,
                                builder: (BuildContext context, dynamic value, Widget? child) {
                                  return Text('今天還有 $value項 未完成喔~');
                                },
                              ),
                              ValueListenableBuilder(
                                valueListenable: completenum,
                                builder: (BuildContext context, dynamic num, Widget? child) {
                                  return Container(
                                    width: MediaQuery.of(context).size.width * 0.45,
                                    child: LinearProgressIndicator(
                                      value: !memodata.hasData || memodata.data.length == 0 ? 0 : (memodata.data.length - num) / memodata.data.length,
                                      backgroundColor: Colors.white,
                                      color: const Color(0xffA5C2C0),
                                    ),
                                  );
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Container(
                      //備忘錄
                      // color: Colors.white,
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: ListView.builder(
                        itemCount: memodata.hasData ? memodata.data.length : 0,
                        itemBuilder: (BuildContext context, int index) {
                          return Slidable(
                            actionPane: const SlidableDrawerActionPane(),
                            actionExtentRatio: 0.25,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(50, 0, 50, 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (memodata.data[index]['finish_status'] == 1) {
                                        UsermemoDB().updatacheck(0, memodata.data[index]['notes_num']);
                                      } else {
                                        UsermemoDB().updatacheck(1, memodata.data[index]['notes_num']);
                                        MemoApi.memoDone(memodata.data[index]['notes_num']);
                                      }

                                      setState(() {});
                                    },
                                    child: Container(
                                      width: 25,
                                      height: 25,
                                      padding: const EdgeInsets.all(1),
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: memodata.data[index]['finish_status'] == 1 ? const Color(0xffA5C2C0) : Colors.white),
                                      child: memodata.data[index]['finish_status'] == 1 ? const Icon(Icons.check, size: 25, color: Colors.white) : null,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Text(
                                    memodata.data[index]['content'],
                                    style: TextStyle(fontSize: 25, decoration: memodata.data[index]['finish_status'] == 1 ? TextDecoration.lineThrough : TextDecoration.none),
                                  ),
                                ],
                              ),
                            ),
                            secondaryActions: <Widget>[
                              IconSlideAction(
                                caption: '編輯',
                                color: Colors.black45,
                                icon: Icons.border_color_rounded,
                                onTap: () {
                                  editmemo = true;
                                  memonum = memodata.data[index]['notes_num'];
                                  openinputbox.value = true;
                                },
                              ),
                              IconSlideAction(
                                caption: '刪除',
                                color: Colors.red,
                                icon: Icons.delete,
                                onTap: () {
                                  MemoApi.memoDelete(memodata.data[index]['notes_num']);
                                  UsermemoDB().delet(memodata.data[index]['notes_num']);
                                  setState(() {});
                                },
                              ),
                            ],
                          );
                        },
                      )),
                ],
              ),
              Positioned(
                bottom: MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ValueListenableBuilder(
                        valueListenable: openinputbox,
                        builder: (BuildContext context, dynamic value, Widget? child) {
                          return openinputbox.value
                              ? Container(
                                  width: MediaQuery.of(context).size.width * 0.7,
                                  child: TextFormField(
                                    autofocus: true,
                                    controller: memoinfomationcontroler,
                                    onFieldSubmitted: (value) => inputAndEditMemoInformation(),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.fromLTRB(15.0, 10.0, 20.0, 10.0),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                                    ),
                                  ),
                                )
                              : Container(width: MediaQuery.of(context).size.width * 0.7);
                        },
                      ),
                      InkWell(
                        onTap: () => inputAndEditMemoInformation(),
                        child: Container(
                          padding: const EdgeInsets.all(0.1),
                          decoration: const BoxDecoration(
                            // borderRadius: BorderRadius.circular(50),
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Icon(
                            editmemo ? Icons.edit : Icons.add_circle,
                            color: const Color(0xffC1D5D5),
                            size: MediaQuery.of(context).size.width * 0.2,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /* -------------------------------- Function -------------------------------- */
  Future memoinfomation() async {
    completenum.value = 0;
    var memodata = await UsermemoDB().queryonepseson(widget.id, formatter.format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + delta)));
    for (var data in memodata) {
      if (data['finish_status'] == 0) completenum.value += 1;
      printcolor('data:$data', color: DColor.yellow);
    }
    return memodata;
  }

  void inputAndEditMemoInformation() async {
    openinputbox.value = !openinputbox.value;
    if (memoinfomationcontroler.text.isNotEmpty) {
      //是否填寫文字
      await SharedPreferences.getInstance();
      if (editmemo) {
        //修改備忘錄
        MemoApi.editMemo(memonum, memoinfomationcontroler.text);
        UsermemoDB().editmemoinformation(memonum, memoinfomationcontroler.text);
      } else {
        //新增備忘錄
        printcolor('create memo', color: DColor.yellow);
        DateTime now = DateTime.now();
        Map<String, dynamic> memoinfomation = await MemoApi.createMemo(
          widget.id,
          formatter.format(DateTime(now.year, now.month, now.day + delta)),
          memoinfomationcontroler.text,
        ); //伺服器新增備忘錄
        printcolor('memo infomation : $memoinfomation', color: DColor.blue);
        UsermemoDB(
                user_id: memoinfomation['user_id'],
                name: memoinfomation['name'],
                notes_num: memoinfomation['notes_num'],
                content: memoinfomation['content'],
                created_by: memoinfomation['created_by'].toString(),
                date: memoinfomation['date'],
                finish_status: 0)
            .insert(); //本地端新增備忘錄
      }
      setState(() {});
      memoinfomationcontroler.clear(); //刪除備忘錄輸入框
    }
    editmemo = false;
  }
}
