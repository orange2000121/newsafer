import 'package:newsafer/tool/debug.dart';
import 'package:flutter/material.dart';

class HelpForgetpassword extends StatefulWidget {
  static String tag = 'Help-Forget-password-page';
  @override
  _HelpState createState() => new _HelpState();
}

class _HelpState extends State<HelpForgetpassword> {
  @override
  Widget build(BuildContext context) {
    final phone = TextFormField(
      keyboardType: TextInputType.number,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'HELP',
        contentPadding: EdgeInsets.fromLTRB(15.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(50.0)),
      ),
    );
    final nextStep = Container(
      child: new Column(
        children: [
          new SizedBox(
            height: 18,
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                child: Text(
                  '下一步',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  printcolor('Unimplemented method!', color: DColor.red);
                },
              )
            ],
          ),
        ],
      ),
    );
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            SizedBox(height: 48.0), //填充行距
            phone,
            SizedBox(height: 24.0),
            nextStep,
          ],
        ),
      ),
    );
  }
}
