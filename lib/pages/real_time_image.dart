import 'package:newsafer/tool/people_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

const appId = "cbc9621de1ed4271a83ecb0e3b3ede18";
const token = "006cbc9621de1ed4271a83ecb0e3b3ede18IADRwGN/XpWL8Ur3Q36ke9aIWWRXXofdKqWxAEiwUtQVzNzDPrsAAAAAEABkg7/N2JVaYQEAAQDXlVph";

class RealTimeImage extends StatefulWidget {
  RealTimeImage({Key key}) : super(key: key);

  @override
  _RealTimeImageState createState() => _RealTimeImageState();
}

class _RealTimeImageState extends State<RealTimeImage> {
  VlcPlayerController _videoPlayerController;

  Future<void> initializePlayer() async {}

  @override
  void initState() {
    super.initState();

    _videoPlayerController = VlcPlayerController.network(
      'rtmp://140.128.101.181/live/ryan1',
      hwAcc: HwAcc.FULL,
      autoPlay: true,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([
          VlcAdvancedOptions.networkCaching(200),
        ]),
        subtitle: VlcSubtitleOptions([
          VlcSubtitleOptions.boldStyle(true),
          VlcSubtitleOptions.fontSize(30),
          VlcSubtitleOptions.outlineColor(VlcSubtitleColor.yellow),
          VlcSubtitleOptions.outlineThickness(VlcSubtitleThickness.normal),
          // works only on externally added subtitles
          VlcSubtitleOptions.color(VlcSubtitleColor.navy),
        ]),
        http: VlcHttpOptions([
          VlcHttpOptions.httpReconnect(true),
        ]),
        rtp: VlcRtpOptions([
          VlcRtpOptions.rtpOverRtsp(true),
        ]),
      ),
    );
  }

  @override
  void dispose() async {
    super.dispose();
    await _videoPlayerController.stopRendererScanning();
    await _videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: VlcPlayer(
            controller: _videoPlayerController,
            aspectRatio: 9 / 16,
            placeholder: Center(child: CircularProgressIndicator()),
          ),
        ));
  }
}

class FriendList extends StatefulWidget {
  @override
  _FriendListState createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  @override
  Widget build(BuildContext context) {
    double _w = MediaQuery.of(context).size.width;
    AppBar appbar = AppBar();
    return Scaffold(
      appBar: appbar,
      body: Column(
        children: [
          FutureBuilder(
            future: FriendData().queryAll(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return snapshot.hasData
                  ? Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              SizedBox(height: 10),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => RealTimeImage()),
                                  );
                                },
                                child: Container(
                                  width: _w * 0.9,
                                  height: 98,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(Radius.circular(20)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        padding: EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              image: snapshot.data[index]['photo'] != null ? MemoryImage(snapshot.data[index]['photo']) : AssetImage('assets/images/unnamed.jpg'),
                                              fit: BoxFit.cover,
                                            )),
                                      ),
                                      SizedBox(width: 20),
                                      Text('即時影像', style: TextStyle(fontSize: 35, color: Color(0xff516F7C))),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  : Container();
            },
          ),
        ],
      ),
    );
  }
}
