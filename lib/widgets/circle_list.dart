/* -------------------------------------------------------------------------- */
/*                      Circle Wheel Scroll View packege                      */
/* -------------------------------------------------------------------------- */
import 'dart:async';
import 'package:circle_wheel_scroll/circle_wheel_scroll_view.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter/material.dart';
import 'package:newsafer/tool/people_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:newsafer/widgets/infowindow.dart';
import 'package:newsafer/screens/map.dart';

class Friendcircle extends StatefulWidget {
  final double outerradius;
  final double interradius;
  final int itemnum;
  final Map<MarkerId, Marker> markers;
  final Completer<GoogleMapController> _controller;
  final Map<String, LatLng> friendposition;
  final CustomInfoWindowController customInfoWindowController;
  final BuildContext infowindowcontext;
  Friendcircle(this._controller, this.friendposition, this.markers, this.customInfoWindowController, this.infowindowcontext, {this.outerradius = 250, this.interradius = 100, this.itemnum = 11});

  @override
  _FriendcircleState createState() => _FriendcircleState();
}

class _FriendcircleState extends State<Friendcircle> {
  final sqlitehelp = FriendData();
  // final _scrollController = FixedExtentScrollController();
  bool openfriendcircle = false;
  bool openfrienddata = false;
  List<Widget> allfriends = [];
  late double angularinterval;
  var frienddatas;
  getAlldata() async {
    //取得好友sqlite資料
    await sqlitehelp.open();
    var datas = await sqlitehelp.queryAll();
    print(allfriends);
    if (allfriends.isEmpty) {
      for (var data in datas) {
        allfriends.add(Center(
          child: Container(
            width: 50,
            height: 50,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: data['photo'] != null ? MemoryImage(data['photo']) : const AssetImage('assets/images/unnamed.jpg') as ImageProvider,
                  fit: BoxFit.cover,
                )),
          ),
        ));
      }
    }

    return datas;
  }

  @override
  void initState() {
    super.initState();
    frienddatas = getAlldata();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        // color: Color(0x10030303),
        height: 300,
        child: Stack(children: [
          openfriendcircle
              ? Positioned(
                  //背景顏色
                  bottom: -300,
                  child: AnimatedContainer(
                    alignment: Alignment.topCenter,
                    duration: const Duration(milliseconds: 1300),
                    height: openfriendcircle ? 600 : 0,
                    width: openfriendcircle ? MediaQuery.of(context).size.width : 0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        ...List.generate(6, (index) => const Color(0xff81A9AC)),
                        ...List.generate(3, (index) => const Color(0xff93B5B8)),
                        ...List.generate(2, (index) => const Color(0xffB2CACD)),
                        ...List.generate(1, (index) => const Color(0xFFDAE5E7)),
                      ]),
                    ),
                    child: const Padding(
                      padding: const EdgeInsets.fromLTRB(0, 80, 0, 0),
                      child: const Icon(
                        Icons.arrow_drop_down,
                        size: 40,
                      ),
                    ),
                  ),
                )
              : Container(
                  width: 0,
                  height: 0,
                  color: Colors.yellow,
                ),
          FutureBuilder(
            future: getAlldata(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return openfriendcircle
                  ? Align(
                      // alignment: Alignment.bottomCenter,
                      child: Container(
                        child: InkWell(
                          onTap: () {
                            // showModalBottomSheet(
                            //     isScrollControlled: true,
                            //     backgroundColor: Colors.transparent,
                            //     context: context,
                            //     builder: (BuildContext context) {
                            //       return Container(
                            //         height: MediaQuery.of(context).size.height * 0.5 + MediaQuery.of(context).viewInsets.bottom,
                            //         child: PageView.builder(
                            //             itemCount: snapshot.data.length,
                            //             itemBuilder: (context, index) {
                            //               return UserMemo('${snapshot.data[index]['id']}');
                            //             }),
                            //       );
                            //     });
                          },
                          child: CircleListScrollView(
                            onSelectedItemChanged: (int index) async {
                              final GoogleMapController controller = await widget._controller.future;
                              String id = snapshot.data[index]['id'].toString();
                              if (widget.markers[MarkerId(id)] != null) {
                                // widget.customInfoWindowController.hideInfoWindow();
                                //map camera animation
                                controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: widget.markers[MarkerId(id)]!.position, zoom: 18.0)));
                                widget.customInfoWindowController.addInfoWindow!(
                                    Infowindow(
                                      id,
                                      snapshot.data[index]['name'],
                                      snapshot.data[index]['photo'],
                                      context,
                                      widget.markers[MarkerId(id)]!.position.latitude.toString(),
                                      widget.markers[MarkerId(id)]!.position.longitude.toString(),
                                    ),
                                    widget.markers[MarkerId(id)]!.position);
                                MapState.instance.hideCustomInfoWindow = false;
                              }
                            },
                            clipToSize: false,
                            renderChildrenOutsideViewport: true,
                            physics: const CircleFixedExtentScrollPhysics(),
                            axis: Axis.horizontal,
                            itemExtent: 60,
                            children: [...allfriends],
                            radius: MediaQuery.of(context).size.width * 0.4,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      width: 0,
                      height: 0,
                      color: Colors.red,
                    );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                // color: Color(0xA826CE82),
                width: widget.interradius,
                height: widget.interradius,
                child: InkWell(
                  onTap: () {
                    openfriendcircle = !openfriendcircle;
                    setState(() {});
                  },
                  child: Container(
                    width: widget.interradius,
                    height: widget.interradius,
                    decoration: BoxDecoration(
                        //Sign-In 頭像
                        color: Colors.white,
                        shape: BoxShape.circle,
                        image: new DecorationImage(image: new AssetImage("assets/images/frient_button.png"), fit: BoxFit.cover)),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
