import 'package:newsafer/tool/api_tool.dart';
import 'package:flutter/material.dart';
import 'package:timer_count_down/timer_count_down.dart';

class ForgotPassword extends StatefulWidget {
  final signIn;
  ForgotPassword(this.signIn);
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3F7E8),
      child: Column(children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.01,
          color: const Color(0xFFF3F7E8),
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.1,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 30, 0, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  color: const Color(0xFFF3F7E8),
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                InkWell(
                    onTap: () {
                      setState(() {
                        widget.signIn.onForgotPassword.value = true;
                        widget.signIn.timeSet = true;
                      });
                    },
                    child: new Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, image: new DecorationImage(image: new AssetImage("assets/images/Back_Arrow.png"), fit: BoxFit.fill)),
                    )),
              ],
            ),
          ),
        ),
        Column(children: [
          Container(
            child: Text('輸入信箱',
                style: TextStyle(
                  fontSize: 25,
                  color: widget.signIn.onFirstPage ? const Color(0xFF6D7660) : const Color(0x956D7660),
                ),
                textAlign: TextAlign.center),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.05,
            child: Text('即可重新設定密碼',
                style: TextStyle(
                  fontSize: 25,
                  color: widget.signIn.onFirstPage ? const Color(0xFF6D7660) : const Color(0x956D7660),
                ),
                textAlign: TextAlign.center),
          ),
        ]),
        Form(
            key: widget.signIn.forgot_emailkey,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.09,
                child: TextFormField(
                  keyboardType: TextInputType.emailAddress, //輸入型態
                  autofocus: false,

                  controller: widget.signIn.emailController, //給sharedpreference存
                  decoration: InputDecoration(
                    hintText: 'Email',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.fromLTRB(15.0, 10.0, 20.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
                  ),
                  validator: (value) {
                    bool check = RegExp(widget.signIn.regexEmail).hasMatch(value!);
                    if (value!.isEmpty) {
                      return '請輸入email';
                    }
                    if (check != true) {
                      return 'email格式有誤,請查核';
                    }
                    widget.signIn.forgotemail['email'] = value;
                    return null;
                  },
                ),
              ) // Add TextFormFields and ElevatedButton here.
              ,
            )),
        Container(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: (widget.signIn.timeSet)
                  ? () async {
                      if (widget.signIn.forgot_emailkey.currentState.validate()) {
                        widget.signIn.timeSet = false;
                        //更新輸入資料狀態
                        widget.signIn.forgot_emailkey.currentState.validate();
                        setState(() {});
                        widget.signIn.check.value = await ApiTool.forGetMailPost(widget.signIn.forgotemail['email']) as String;
                      }
                    }
                  : null,
              child: const Text('發送郵件', style: const TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                primary: const Color(0xFF5A6248),
                padding: const EdgeInsets.all(12),
                shadowColor: const Color(0xFF5A6248),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
              ),
            ),
          ),
        ),
        widget.signIn.timeSet
            ? const SizedBox()
            : Countdown(
                // controller: _controller,
                seconds: 30,
                build: (_, time) => Text(
                  '再' + time.toInt().toString() + '秒後可重新發送',
                  style: const TextStyle(
                    fontSize: 25,
                  ),
                ),
                interval: const Duration(milliseconds: 1000),
                onFinished: () {
                  widget.signIn.timeSet = true;
                  setState(() {});
                },
              ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        TextButton(
            onPressed: () {
              setState(() {
                {}
              });
            },
            child: const Text(
              '需要幫助?',
              style: TextStyle(color: Color(0x996D7660), fontSize: 15),
            )),
      ]),
    );
  }
}
