// import 'dart:typed_data';

// import 'package:newsafer/services/marker_map.dart';
// import 'package:newsafer/tool/debug.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:network_image_to_byte/network_image_to_byte.dart';
// import 'package:url_launcher/url_launcher.dart';

// class EmegencyNoticePage extends StatefulWidget {
//   final LatLng latlng;
//   final Map<String, dynamic> userData, boxData;
//   EmegencyNoticePage(this.latlng, {this.userData, this.boxData});
//   @override
//   _EmegencyNoticePageState createState() => _EmegencyNoticePageState();
// }

// class _EmegencyNoticePageState extends State<EmegencyNoticePage> {
//   final markers = <MarkerId, Marker>{}; //google map的所有 marker
//   @override
//   void initState() {
//     super.initState();
//     newLocationUpdate();
//   }

//   @override
//   Widget build(BuildContext context) {
//     printcolor('event : ${widget.boxData['event']}', color: DColor.blue);
//     return MaterialApp(
//       title: 'EmegencyNoticePage',
//       home: Scaffold(
//           backgroundColor: Color(0xff19232D),
//           body: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               SizedBox(height: MediaQuery.of(context).padding.top),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   InkWell(
//                     onTap: () {
//                       Navigator.pop(context);
//                     },
//                     child: Container(
//                       margin: EdgeInsets.all(8),
//                       width: 70,
//                       height: 70,
//                       decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/emegencypage/组 165.png'))),
//                     ),
//                   ),
//                   Container(
//                     margin: EdgeInsets.all(8),
//                     width: 70,
//                     height: 70,
//                     decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/emegencypage/截圖 2021-05-15 下午4.31.49.png'))),
//                   ),
//                 ],
//               ),
//               Container(
//                 width: MediaQuery.of(context).size.width * 0.9,
//                 height: MediaQuery.of(context).size.width * 0.8,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.all(Radius.circular(15)),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
//                   child: Column(
//                     children: [
//                       Text('警告'),
//                       Divider(thickness: 4),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           Image.asset('assets/images/emegencypage/截圖 2021-05-15 下午4.31.49.png'),
//                           SizedBox(width: 30),
//                           Text(
//                             '${widget.userData['name']}${widget.boxData['event'] == '1' ? '發生傾倒' : widget.boxData['event'] == '2' ? '發生碰撞' : '沒事'}',
//                             style: TextStyle(fontSize: 23, color: Color(0xffA5A5A4)),
//                           ),
//                         ],
//                       ),
//                       Divider(thickness: 4),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             '撥打給${widget.userData['name']}',
//                             style: TextStyle(fontSize: 30, color: Color(0xffA5A5A4)),
//                           ),
//                           InkWell(
//                             onTap: () => launch('tel://'),
//                             child: Image.asset('assets/images/emegencypage/组 168.png'),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 10),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             '撥打給電話給119',
//                             style: TextStyle(fontSize: 30, color: Color(0xffA5A5A4)),
//                           ),
//                           InkWell(
//                             onTap: () => launch('tel://'),
//                             child: Image.asset('assets/images/emegencypage/组 168.png'),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               Text(
//                 '75%',
//                 style: TextStyle(color: Colors.white),
//               ),
//               Container(
//                 width: MediaQuery.of(context).size.width * 0.4,
//                 height: 50,
//                 decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/images/emegencypage/组 33.png'))),
//               ),
//               Container(
//                 width: MediaQuery.of(context).size.width,
//                 height: 300,
//                 child: GoogleMap(
//                   initialCameraPosition: CameraPosition(target: widget.latlng, zoom: 10),
//                   markers: markers.values.toSet(),
//                 ),
//               ),
//             ],
//           )),
//     );
//   }

//   void newLocationUpdate() async {
//     BitmapDescriptor photo;
//     if (widget.userData['photo'] != null) {
//       Uint8List image = await networkImageToByte(widget.userData['photo']);
//       photo = await getMarkerIcon(image, Size(150, 150));
//     } else {
//       photo = BitmapDescriptor.defaultMarker;
//     }
//     var marker = Marker(
//       icon: photo,
//       markerId: MarkerId('0'),
//       position: widget.latlng,
//     );
//     setState(() => markers[MarkerId('0')] = marker);
//   }
// }
