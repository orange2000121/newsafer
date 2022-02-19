import 'dart:async';

import 'package:newsafer/tool/debug.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animarker/core/ripple_marker.dart';
import 'package:flutter_animarker/flutter_map_marker_animation.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapTest extends StatefulWidget {
  @override
  _MapTestState createState() => _MapTestState();
}

class _MapTestState extends State<MapTest> {
  Completer<GoogleMapController> mapcontroller = Completer(); //控制地圖
  LatLng cameralatlng;
  int numpickervalue = 500;
  TextEditingController addresscontroler = TextEditingController();
  final markers = <MarkerId, Marker>{}; //google map的所有 marker
  final circles = <CircleId, Circle>{};
  List<Widget> onmapwidgets = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
            future: Geolocator.getCurrentPosition(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return Animarker(
                  mapId: mapcontroller.future.then<int>((value) => value.mapId),
                  child: GoogleMap(
                    myLocationButtonEnabled: true,
                    myLocationEnabled: true,
                    mapToolbarEnabled: false,
                    mapType: MapType.normal,
                    circles: circles.values.toSet(),
                    markers: markers.values.toSet(),
                    // markers: markers.values.toSet(),
                    initialCameraPosition: CameraPosition(target: LatLng(snapshot.data.latitude, snapshot.data.longitude), zoom: 18),
                    onMapCreated: (GoogleMapController controller) async {
                      mapcontroller.complete(controller);
                      cameralatlng = LatLng(snapshot.data.latitude, snapshot.data.longitude);
                    },
                    onCameraMove: (CameraPosition position) async {
                      cameralatlng = position.target;
                    },
                  ),
                );
              }
              return Container();
            },
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: IconButton(
                onPressed: () {
                  newLocationUpdate(cameralatlng);
                  getaddress(cameralatlng);
                },
                icon: Icon(
                  Icons.fence,
                  size: 50,
                )),
          ),
          ...onmapwidgets
        ],
      ),
    );
  }

  void getaddress(LatLng latlng) async {
    final coordinates = new Coordinates(latlng.latitude, latlng.longitude);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    // printcolor("all address ${first.adminArea}: ${first.featureName} : ${first.addressLine}", color: DColor.blue);
    addresscontroler.text = first.addressLine;
  }

  void newLocationUpdate(LatLng latLng) {
    var marker = RippleMarker(
        markerId: MarkerId('${markers.length}'),
        position: latLng,
        ripple: false,
        draggable: true,
        onDragEnd: (LatLng newposition) {
          print(newposition);
          getaddress(newposition);
          putwidgetonmap(newposition);
        },
        onTap: () {
          print('Tapped! $latLng');
        });
    var circlemarker = Circle(
      center: latLng,
      strokeWidth: 1,
      circleId: CircleId('${markers.length}'),
      radius: 100,
      fillColor: Color(0x3427EE94),
    );
    setState(() {
      markers[MarkerId('${markers.length}')] = marker;
      circles[CircleId('${markers.length}')] = circlemarker;
    });
  }

  void putwidgetonmap(LatLng latlng) async {
    GoogleMapController controler = await mapcontroller.future;
    controler.getScreenCoordinate(latlng).asStream().listen((value) {
      printcolor('value xy : ${value.x.toDouble()} ${value.y.toDouble()}', color: DColor.blue);
      onmapwidgets.add(
        Positioned(
            top: value.y.toDouble() / 3 /*+ MediaQuery.of(context).padding.top*/,
            left: value.x.toDouble() / 3,
            child: Container(
              width: 10,
              height: 10,
              color: Colors.green,
            )),
      );
      printcolor('mapwidget : ${onmapwidgets.length}', color: DColor.cyan);
      setState(() {});
    });
  }
}
