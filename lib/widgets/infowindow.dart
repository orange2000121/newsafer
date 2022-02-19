import 'dart:typed_data';

import 'package:newsafer/widgets/triangle.dart';
import 'package:newsafer/widgets/user_memo.dart';
import 'package:flutter/material.dart';

class Infowindow extends StatefulWidget {
  final Uint8List photo;
  final String name, id, lat, lon;
  final BuildContext infowindowcontext;
  Infowindow(this.id, this.name, this.photo, this.infowindowcontext, this.lat, this.lon);

  @override
  _InfowindowState createState() => _InfowindowState();
}

class _InfowindowState extends State<Infowindow> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 550,
          height: 60,
          decoration: const BoxDecoration(color: Color(0xC490B3B6), borderRadius: BorderRadius.all(const Radius.circular(15))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  //大頭貼
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: widget.photo != null ? MemoryImage(widget.photo) : const AssetImage('assets/images/unnamed.jpg') as ImageProvider,
                        fit: BoxFit.cover,
                      ))),
              Expanded(
                child: Center(
                  child: Text(
                    widget.name,
                    overflow: TextOverflow.fade,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      context: widget.infowindowcontext,
                      builder: (BuildContext context) {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.5 + MediaQuery.of(context).viewInsets.bottom,
                          child: UserMemo(widget.id),
                        );
                      });
                },
                child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: const DecorationImage(
                          image: const AssetImage('assets/images/组 162.png'),
                          fit: BoxFit.cover,
                        ))),
              )
            ],
          ),
        ),
        ClipPath(
          clipper: CustomTriangleClipper(),
          child: Container(
            width: 15,
            height: 15,
            color: const Color(0xC490B3B6),
          ),
        ),
      ],
    );
  }
}
