import 'package:newsafer/tool/api_tool.dart';
import 'package:newsafer/tool/debug.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_state_button/progress_button.dart';

import 'package:newsafer/pages/profile/editprofilepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

//壓縮照片

// ignore: must_be_immutable
class Sendchangeid extends StatefulWidget {
  // final SharedPreferences preferences; //定義一個SharedPreferences接收傳入值，用於個人資料的顯示
  headshot imageobj;
  name user_name;
  id user_id;
  TextEditingController namecontroller;
  TextEditingController idcontroller;
  ChangeVarible info;
  Sendchangeid(this.idcontroller, this.imageobj, this.user_name, this.user_id, this.namecontroller, this.info);
  bool returning = false;
  @override
  _SendchangeidState createState() => _SendchangeidState();
}

class _SendchangeidState extends State<Sendchangeid> {
  late Image headimage;
  ButtonState stateOnlyText = ButtonState.idle;
  ButtonState stateTextWithIcon = ButtonState.idle;
  Map<String, dynamic> data = {"status": null, "editSuccess": null, "newOldSameId": null, "duplicateId": null, "newId": null, "reason": null};
  var status;

  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: Column(
        children: [
          Text(
            (status == null || status)
                ? ''
                : !data['newOldSameId']
                    ? 'id相同'
                    : !data['duplicateId']
                        ? '與起他人id相同'
                        : '',
            style: TextStyle(color: Colors.red),
          ),
          widget.idcontroller.text.isNotEmpty
              ? ProgressButton(
                  stateWidgets: {
                    ButtonState.idle: Text(
                      "儲存更改",
                      style: TextStyle(color: Colors.white, fontSize: 30, letterSpacing: 2.2, fontWeight: FontWeight.w500),
                    ),
                    ButtonState.loading: Text(
                      "執行中",
                      style: TextStyle(color: Colors.white, fontSize: 30, letterSpacing: 2.2, fontWeight: FontWeight.w600),
                    ),
                    ButtonState.fail: Text(
                      "重新傳送",
                      style: TextStyle(color: Colors.white, fontSize: 30, letterSpacing: 2.2, fontWeight: FontWeight.w600),
                    ),
                    ButtonState.success: Text(
                      "更改成功",
                      style: TextStyle(color: Colors.white, fontSize: 30, letterSpacing: 2.2, fontWeight: FontWeight.w600),
                    )
                  },
                  stateColors: {
                    ButtonState.idle: Color(0xFF26A69A),
                    ButtonState.loading: Colors.deepPurple.shade700,
                    ButtonState.fail: Colors.red.shade300,
                    ButtonState.success: Colors.green.shade400,
                  },
                  onPressed: onPressedIconWithText,
                  state: stateTextWithIcon,
                )
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    color: Color(0xFFC1BDD6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send, color: Colors.white),
                      Text(
                        '不能為空',
                        style: TextStyle(color: Color(0xFF252729)),
                      ),
                    ],
                  ),
                )
        ],
      ),
    );
  }

  @override
  void setState(void Function() fn) {
    super.setState(fn);
    if (stateTextWithIcon == ButtonState.success) {
      if (widget.returning == false) {
        widget.returning = true;
        printcolor('Returning to previous page.', color: DColor.blue);
        Future.delayed(Duration(seconds: 1), () => Navigator.pop(context));
      }
    }
  }

  Future<void> onPressedIconWithText() async {
    //頭貼
    if (widget.imageobj.isEdit == true) {
      ApiTool.changeheadshot(widget.imageobj.image);

      // Saveimage(widget.imageobj.image.path);
      //  loadnetpicture();

    }

    if (widget.user_name.nameedit = true) {
      ApiTool.changename(widget.namecontroller.text);
      Savename(widget.user_name.username);
    }
    if (widget.user_id.idedit == true) {
      Saveid(widget.user_id.idnumber);
    }
    //id
    if (widget.idcontroller.text.isNotEmpty) {
      switch (stateTextWithIcon) {
        case ButtonState.idle:
          stateTextWithIcon = ButtonState.loading;
          data = await ApiTool.changemyid(widget.idcontroller.text);
          status = data['status'];

          stateTextWithIcon = ButtonState.success;
          /* if (status != null) {
            status
                ?
                : stateTextWithIcon = ButtonState.fail;
          }*/
          setState(() {});
          break;
        case ButtonState.loading:
          break;
        case ButtonState.success:
          Future.delayed(Duration(seconds: 1));
          Navigator.pop(context);
          break;
        case ButtonState.fail:
          // stateTextWithIcon = ButtonState.loading;
          // data = await ApiTool.changemyid(widget.idcontroller.text);
          // status = data['status'];
          // if (status != null) {
          //   status
          //       ? stateTextWithIcon = ButtonState.success
          //       : stateTextWithIcon = ButtonState.fail;
          // }
          setState(() {});
          break;
      }
    }

    setState(
      () {
        stateTextWithIcon = stateTextWithIcon;
      },
    );
  }
/*
  void Saveimage(path) async {
    SharedPreferences saveimage = await SharedPreferences.getInstance();
    saveimage.setString("imagepath", path);
    //ApiTool.changeheadshot(path);
  }
*/
/*
  void loadnetpicture() async {

            final Uint8List bytes = imageData.buffer.asUint8List();

          headimage= Image.memory(bytes);//  用 Image.memory 小布件顯示它

  }
*/

  void Savename(string) async {
    SharedPreferences savename = await SharedPreferences.getInstance();
    savename.setString('name', string);
  }

  void Saveid(string) async {
    SharedPreferences saveid = await SharedPreferences.getInstance();
    saveid.setString('user_id', string);
  }
}


/*class UserPreferences {
  static SharedPreferences preferences;

  static const _keyUser = 'username';

  static Future init() async =>
      preferences = await SharedPreferences.getInstance();

  static Future setUsername(String username) async =>
      await preferences.getString(_keyUser, username);

  static String getUsername() => preferences.getString(_keyUser);
}
*/