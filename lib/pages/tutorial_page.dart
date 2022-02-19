import 'package:flutter/material.dart';
import 'listvalue.dart';

class Tutorial extends StatefulWidget {
  Tutorial({Key key}) : super(key: key);

  @override
  _TutorialState createState() => _TutorialState();
}

class _TutorialState extends State<Tutorial> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Expanded(
          child: PageView.builder(
              itemCount: listofvalue.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular((20))),
                    color: Colors.amber,
                    child: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(listofvalue[index].imagepath))),
                    ),
                  ),
                );
              }),
        )
      ]),
    );
  }
}
