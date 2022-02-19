import 'dart:async';

import 'package:newsafer/tool/debug.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animarker/core/ripple_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:geocoder/geocoder.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as maptool;

class ElectronicFence extends StatefulWidget {
  @override
  _ElectronicFenceState createState() => _ElectronicFenceState();
}

class _ElectronicFenceState extends State<ElectronicFence> {
  Completer<GoogleMapController> mapcontroller = Completer(); //控制地圖
  late LatLng cameralatlng;
  int numpickervalue = 500;
  TextEditingController addresscontroler = TextEditingController();
  CircleId editcircleid = const CircleId('');
  final markers = <MarkerId, Marker>{}; //google map的所有 marker
  final circles = <CircleId, Circle>{};
  List<Widget> onmapwidgets = [];
  ValueNotifier<bool> settingmarker = ValueNotifier<bool>(false); //控制marker設定視窗出現消失
  ValueNotifier<bool> changemarker = ValueNotifier<bool>(false); //更換用marker出現消失
  Circle tempcircle = const Circle(circleId: CircleId('value'));

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getaddress(LatLng latlng) async {
    final coordinates = new Coordinates(latlng.latitude, latlng.longitude);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    // printcolor("all address ${first.adminArea}: ${first.featureName} : ${first.addressLine}", color: DColor.blue);
    addresscontroler.text = first.addressLine;
  }

  void createmarker(LatLng latLng, {double radius = 100, String idvalue = ''}) {
    if (idvalue.isEmpty) {
      idvalue = '${markers.length}';
    }
    editcircleid = CircleId(idvalue);
    MarkerId thismarkerid = MarkerId(idvalue);
    CircleId thiscircleid = CircleId(idvalue);
    var marker = RippleMarker(
        markerId: thismarkerid,
        position: latLng,
        ripple: false,
        draggable: true,
        onDragEnd: (LatLng newposition) {
          print(newposition);
          getaddress(newposition);
          updatecircle(thiscircleid, latlng: newposition);
        },
        onTap: () {
          print('Tapped! $latLng');
          editcircleid = thiscircleid;
          getaddress(markers[thismarkerid]!.position);
          settingmarker.value = true;
        });
    var circlemarker = Circle(
      center: latLng,
      strokeWidth: 1,
      circleId: thiscircleid,
      radius: radius,
      fillColor: const Color(0x3427EE94),
    );
    setState(() {
      markers[thismarkerid] = marker;
      circles[thiscircleid] = circlemarker;
    });
  }

  // ignore: avoid_init_to_null
  void updatecircle(CircleId circleid, {LatLng? latlng, double? radius}) async {
    latlng ??= circles[circleid]!.center;

    radius ??= circles[circleid]!.radius;
    printcolor('center : $latlng , radius : $radius', color: DColor.blue);
    circles.remove(circleid);
    var circlemarker = Circle(
      center: latlng,
      strokeWidth: 1,
      circleId: circleid,
      radius: radius,
      fillColor: const Color(0x3427EE94),
    );
    setState(() {
      circles[circleid] = circlemarker;
    });
  }

  bool containfence(LatLng point) {
    for (Circle circle in circles.values) {
      if (circle.radius > maptool.SphericalUtil.computeDistanceBetween(maptool.LatLng(point.latitude, point.longitude), maptool.LatLng(circle.center.latitude, circle.center.longitude))) {
        return true; //如果在範圍內回傳true
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        backgroundColor: const Color(0xffB7D1D5),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xff516F7C),
          ),
        ),
        title: const Text(
          '電子圍籬',
          style: const TextStyle(color: Color(0xff516F7C)),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(color: const Color(0xffB7D1D5)),
            child: Container(
              decoration: const BoxDecoration(image: const DecorationImage(image: AssetImage('assets/images/Mask Group 12.png'), fit: BoxFit.cover)),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                              onTap: () {
                                // putwidgetonmap(cameralatlng);
                                createmarker(cameralatlng);
                                getaddress(cameralatlng);
                                printcolor('widgets : ${onmapwidgets[0].runtimeType}', color: DColor.green);
                              },
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/Group 156.png'))),
                              )),
                          const SizedBox(width: 20),
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 150,
                            child: TextFormField(
                              controller: addresscontroler,
                              decoration: const InputDecoration(
                                border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                                labelText: '地址',
                              ),
                            ),
                          ),
                        ],
                      ),
                      // SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 20),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            constraints: const BoxConstraints(minWidth: 250),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.6,
                                  height: 30,
                                  constraints: const BoxConstraints(minWidth: 250),
                                  decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(50))),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      color: Colors.transparent,
                                      child: Row(
                                        children: [
                                          NumberPicker(
                                            step: 500,
                                            value: numpickervalue,
                                            minValue: 500,
                                            maxValue: 5000,
                                            itemHeight: 30,
                                            onChanged: (value) {
                                              print(value);
                                              numpickervalue = value;
                                              updatecircle(editcircleid, radius: value.toDouble());
                                              setState(() {});
                                            },
                                          ),
                                          const Text('公尺'),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    ElevatedButton(
                                      onPressed: () {},
                                      child: const Text('確認設置'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.all(0),
                                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(50))),
                                        fixedSize: const Size(100, 30),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height - 300),
                  decoration: const BoxDecoration(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(28)),
                  ),
                  child: Stack(
                    children: [
                      FutureBuilder(
                        future: Geolocator.getCurrentPosition(),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            return GoogleMap(
                              myLocationButtonEnabled: true,
                              myLocationEnabled: true,
                              mapToolbarEnabled: false,
                              mapType: MapType.normal,
                              markers: markers.values.toSet(),
                              circles: circles.values.toSet(),
                              initialCameraPosition: CameraPosition(target: LatLng(snapshot.data.latitude, snapshot.data.longitude), zoom: 18),
                              onMapCreated: (GoogleMapController controller) async {
                                mapcontroller.complete(controller);
                                cameralatlng = LatLng(snapshot.data.latitude, snapshot.data.longitude);
                              },
                              onCameraMove: (CameraPosition position) async {
                                cameralatlng = position.target;
                              },
                              onTap: (LatLng latlng) {
                                if (!changemarker.value) {
                                  settingmarker.value = false;
                                }
                              },
                            );
                          }
                          return Container();
                        },
                      ),
                      ValueListenableBuilder(
                          valueListenable: settingmarker,
                          builder: (BuildContext context, bool value, Widget? child) {
                            return value
                                ? Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 50, 10, 0),
                                      child: Column(
                                        children: [
                                          InkWell(
                                              onTap: () {
                                                if (changemarker.value) {
                                                  createmarker(cameralatlng, radius: tempcircle.radius, idvalue: tempcircle.circleId.value);
                                                  changemarker.value = false;
                                                } else {
                                                  tempcircle = circles[editcircleid];
                                                  setState(() {
                                                    markers.remove(MarkerId(editcircleid.value));
                                                    circles.remove(editcircleid);
                                                    changemarker.value = true;
                                                  });
                                                }
                                              },
                                              child: Container(
                                                width: 50,
                                                height: 50,
                                                decoration: BoxDecoration(color: Colors.blue[300], borderRadius: BorderRadius.circular(50)),
                                                child: ValueListenableBuilder(
                                                  valueListenable: changemarker,
                                                  builder: (BuildContext context, bool value, Widget child) {
                                                    return Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        value ? const Text('確認') : const Text('變更'),
                                                        const Text('位置'),
                                                      ],
                                                    );
                                                  },
                                                ),
                                              )),
                                          // SizedBox(height: 5),
                                          // InkWell(
                                          //     onTap: () {},
                                          //     child: Container(
                                          //       width: 50,
                                          //       height: 50,
                                          //       decoration: BoxDecoration(color: Colors.blue[300], borderRadius: BorderRadius.circular(50)),
                                          //       child: Column(
                                          //         mainAxisAlignment: MainAxisAlignment.center,
                                          //         children: [
                                          //           Text('離開'),
                                          //           Text('範圍'),
                                          //         ],
                                          //       ),
                                          //     )),
                                          // SizedBox(height: 5),
                                          // InkWell(
                                          //     onTap: () {},
                                          //     child: Container(
                                          //       width: 50,
                                          //       height: 50,
                                          //       decoration: BoxDecoration(color: Colors.blue[300], borderRadius: BorderRadius.circular(50)),
                                          //       child: Column(
                                          //         mainAxisAlignment: MainAxisAlignment.center,
                                          //         children: [
                                          //           Text('進入'),
                                          //           Text('範圍'),
                                          //         ],
                                          //       ),
                                          //     )),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container();
                          }),
                      ValueListenableBuilder(
                        valueListenable: changemarker,
                        builder: (BuildContext context, dynamic value, Widget child) {
                          return value
                              ? Align(
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.location_on,
                                    size: 45,
                                    color: Colors.red[600],
                                  ),
                                )
                              : Container();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ...onmapwidgets,
        ],
      ),
    );
  }
}
