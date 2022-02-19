import 'package:flutter/material.dart';
// import '../tool/api_tool.dart';

class ModifyPasswordPage extends StatefulWidget {
  static String tag = 'ModPassword-page';
  @override
  _ModifyPasswordState createState() => new _ModifyPasswordState();
}

class _ModifyPasswordState extends State<ModifyPasswordPage> {
  final _passwordkey = GlobalKey<FormState>(); //判斷password輸入的變數
  final Map<String, dynamic> _passwordData = {
    //輸入的資料
    'password': '',
  };
  @override
  Widget build(BuildContext context) {
    final password = Form(
        key: _passwordkey,
        child: TextFormField(
          keyboardType: TextInputType.emailAddress,
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Email',
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
          ),
          validator: (value) {
            if (value.isEmpty) {
              return '請輸入email';
            }
            _passwordData['password'] = value; //處存email資料
            return null;
          },
        ));
    return Scaffold(
      //拼裝widget
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('修改密碼'),
        backgroundColor: Colors.blue[200],
      ),
      body: Center(
        child: Container(
            padding: EdgeInsets.only(left: 24.0, right: 24.0),
            child: ListView(
              // mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 18,
                ),
                SizedBox(height: 8.0),
                password,
                SizedBox(height: 8.0),
              ],
            )),
      ),
    );
  }
}
