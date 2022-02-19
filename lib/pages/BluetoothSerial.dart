// /*
//  * Copyright 2021 R-Dap
//  * Bluetooth setting for Classic BLuetooth.
//  * @Author: XiaNight 賴資敏
// */

// import 'dart:async';
// import 'dart:convert';
// import 'dart:typed_data';

// import 'package:newsafer/tool/api_tool.dart';
// import 'package:newsafer/tool/debug.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:flutter/material.dart';

// import 'package:newsafer/CustomWidgets/ActionButton.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class BluetoothSerialPage extends StatefulWidget {
//   BluetoothSerialPage({required Key key}) : super(key: key) {
//     instance = this;
//   }
//   static BluetoothSerialPage instance;
//   final List<ClassedBTDevice> avalibleDevices = [];
//   final List<BluetoothConnection> connectedDevices = [];
//   final List<StreamSubscription> subs = [];
//   final List<int> messageBuffer = [];

//   final _BluetoothSerialPageState state = _BluetoothSerialPageState();

//   @override
//   _BluetoothSerialPageState createState() => state;
// }

// class _BluetoothSerialPageState extends State<BluetoothSerialPage> {
//   Function messageHandler = (string) {
//     // print(string);
//   };
//   /* -------------------------------------------------------------------------- */
// /*                               Start Scanning                               */
// /* -------------------------------------------------------------------------- */
//   void startScan({bool onlyRDAP = true}) async {
//     // stop the previous scan if scanning is in process.
//     if (await FlutterBluetoothSerial.instance.isDiscovering) {
//       FlutterBluetoothSerial.instance.cancelDiscovery();
//     }
//     // restart the scanning process.
//     printcolor('Scanning...', color: DColor.green);
//     FlutterBluetoothSerial.instance.startDiscovery().listen((event) {
//       ClassedBTDevice cbtd = ClassedBTDevice(event.device, ClassedDeviceType.Scanned);
//       printcolor('Found Device: ${cbtd.getDeviceName()}', color: DColor.magenta);
//       // filter out non R-DAP hardwares.
//       if (!onlyRDAP || isRDAPHarware(cbtd.device.name)) {
//         addDeviceToList(cbtd);
//       }
//     }).onDone(() {
//       printcolor('Finished scanning', color: DColor.cyan);
//     });
//   }

// /* -------------------------------------------------------------------------- */
// /*                             R-DAP Harware Test                             */
// /* -------------------------------------------------------------------------- */
//   bool isRDAPHarware(String devicename) {
//     if (devicename == null) return false;
//     return devicename.compareTo("R-DAP-BT") == 0;
//   }

// /* -------------------------------------------------------------------------- */
// /*                                  Stop Scan                                 */
// /* -------------------------------------------------------------------------- */
//   void stopScan() async {
//     await FlutterBluetoothSerial.instance.cancelDiscovery();
//   }

// /* -------------------------------------------------------------------------- */
// /*                                  Close All                                 */
// /* -------------------------------------------------------------------------- */
//   void closeAll() async {
//     stopScan();
//     printcolor('Closing ${widget.subs.length} streams', color: DColor.cyan);
//     for (var sub in widget.subs) {
//       await sub.cancel();
//     }
//     printcolor('Disconnecting: ${widget.connectedDevices.length} devices.', color: DColor.cyan);
//     for (var conn in widget.connectedDevices) {
//       await conn.close();
//     }
//     printcolor('Finished closing.', color: DColor.cyan);
//   }

// /* -------------------------------------------------------------------------- */
// /*                              Connect to Device                             */
// /* -------------------------------------------------------------------------- */
//   void connectTo(ClassedBTDevice cbtd) async {
//     final displayName = '${cbtd.device.name ?? cbtd.device.address.toString()}';
//     printcolor('Connecting to: $displayName', color: DColor.green);

//     try {
//       // start connecting to the device with fn toAddress(<device-address>)
//       cbtd.connection = await BluetoothConnection.toAddress(cbtd.device.address);

//       printcolor('Connected to: $displayName', color: DColor.green);
//       cbtd.isConnected = true;

//       // adds the connected device to connect list
//       widget.connectedDevices.add(cbtd.connection);

//       setState(() {});
//       cbtd.connection.input.listen((Uint8List data) {
//         for (int i = 0; i < data.length; i++) {
//           if (data[i] == 10) {
//             // EOL
//             String decoded = ascii.decode(widget.messageBuffer);
//             messageHandler(decoded);
//             widget.messageBuffer.clear();
//           } else {
//             widget.messageBuffer.add(data[i]);
//           }
//         }
//       }).onDone(() {
//         printcolor('Disconnected by remote request', color: DColor.red);
//       });
//     } catch (exception) {
//       printcolor('Failed to connect to: $displayName', color: DColor.red);
//       printcolor('$exception', color: DColor.red);
//     }
//   }

// /* -------------------------------------------------------------------------- */
// /*                             Set Message Handler                            */
// /* -------------------------------------------------------------------------- */
//   void setMessageHandler(void handler(String s)) {
//     messageHandler = handler;
//   }

// /* -------------------------------------------------------------------------- */
// /*                             Start Discoverable                             */
// /* -------------------------------------------------------------------------- */
//   void startDiscoverable() async {
//     // if (discoverable) {
//     //   Debug.Log('Start Advertising', color: DebugColor.green);
//     //   FlutterBluetoothSerial.instance.requestDiscoverable(60);
//     // }
//     await FlutterBluetoothSerial.instance.requestDiscoverable(60);
//     bool discoverable = await FlutterBluetoothSerial.instance.isDiscoverable;
//     printcolor('This device is ${discoverable ? '' : 'not'} discoverable', color: DColor.cyan);
//   }

// /* -------------------------------------------------------------------------- */
// /*                             Add Devide to List                             */
// /* -------------------------------------------------------------------------- */
//   void addDeviceToList(ClassedBTDevice cbtd) {
//     for (ClassedBTDevice device in widget.avalibleDevices) {
//       if (device.device.address == cbtd.device.address) {
//         printcolor('Devide already in list', color: DColor.red);
//         return;
//       }
//     }
//     printcolor('Scanned: ${cbtd.device.name}, address: ${cbtd.device.address}', color: DColor.yellow);
//     widget.avalibleDevices.add(cbtd);
//     setState(() {});
//   }

// /* -------------------------------------------------------------------------- */
// /*                            Listen Connect State                            */
// /* -------------------------------------------------------------------------- */
//   void listenConnectState(BluetoothState event) {
//     printcolor('BluetoothState: $event', color: DColor.magenta);
//   }

// /* -------------------------------------------------------------------------- */
// /*                             Get Bonded Devices                             */
// /* -------------------------------------------------------------------------- */
//   StreamSubscription<dynamic> getBondedDevices() {
//     printcolor('Searching for bounded device.', color: DColor.green);
//     StreamSubscription<dynamic> sub = FlutterBluetoothSerial.instance.getBondedDevices().asStream().listen((event) {
//       for (var device in event) {
//         printcolor('Bonded: ${device.name ?? 'Unknown Device'}, Connected: ${device.isConnected}', color: DColor.cyan);
//         addDeviceToList(ClassedBTDevice(device, ClassedDeviceType.Bonded));
//       }
//     });
//     return sub;
//   }

// /* -------------------------------------------------------------------------- */
// /*                               Bluetooth Setup                              */
// /* -------------------------------------------------------------------------- */
//   void bluetoothSetup() {
//     FlutterBluetoothSerial.instance.onStateChanged().listen(listenConnectState);

//     // for incomming BT devices, returns true for accepting connection.
//     FlutterBluetoothSerial.instance.setPairingRequestHandler((request) => Future(() => true));
//   }

// /* -------------------------------------------------------------------------- */
// /*                                  initState                                 */
// /* -------------------------------------------------------------------------- */
//   @override
//   void initState() {
//     super.initState();
//     bluetoothSetup();
//     getBondedDevices().onDone(() {
//       printcolor('Finished scanning bonnded device.', color: DColor.cyan);
//       startScan(onlyRDAP: true);
//     });
//     setMessageHandler((s) async {
//       Position position = await Geolocator.getCurrentPosition();
//       SharedPreferences preferences = await SharedPreferences.getInstance();
//       ApiTool.urgentnotice('緊急通知', '${preferences.getString('name')}$s', s.toString());
//       ApiTool.happenaccident(position.latitude.toString(), position.longitude.toString(), DateTime.now().toString(), s);
//       const AndroidNotificationChannel channel = AndroidNotificationChannel(
//         'high_importance_channel', // id
//         'High Importance Notifications', // title
//         'This channel is used for important notifications.', // description
//         importance: Importance.max,
//       );
//       final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//       flutterLocalNotificationsPlugin.show(
//         s.hashCode,
//         '緊急通知',
//         '${preferences.getString('name')}$s',
//         NotificationDetails(
//           android: AndroidNotificationDetails(
//             channel.id,
//             channel.name,
//             channel.description,
//             // icon: android?.smallIcon,
//             // other properties...
//           ),
//         ),
//       );
//     });
//     /* ---------------------------- local notifition ---------------------------- */
//     FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
//     const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('new_logo');
//     final InitializationSettings initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//     );
//     flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }

// /* -------------------------------------------------------------------------- */
// /*                                    build                                   */
// /* -------------------------------------------------------------------------- */
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Bluetooth'),
//         leading: ActionButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           elevation: 0.0,
//         ),
//         actions: <Widget>[
//           ActionButton(
//             elevation: 0,
//             icon: const Icon(Icons.help),
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (_) => AlertDialog(
//                   title: Text('Make sure to enable GPS service.'),
//                   actions: <Widget>[
//                     TextButton(
//                       child: Text('Got it!'),
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                         setState(() {});
//                       },
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//           ActionButton(
//             elevation: 0,
//             icon: const Icon(Icons.restore),
//             onPressed: () {
//               startScan(onlyRDAP: true);
//             },
//           ),
//           ActionButton(
//             elevation: 0,
//             icon: Icon(Icons.bluetooth_searching),
//             onPressed: () async {
//               startDiscoverable();
//             },
//           ),
//         ],
//       ),
//       body: Center(
//         child: _buildListViewOfDevices(),
//       ),
//     );
//   }

// /* -------------------------------------------------------------------------- */
// /*                              Build Device List                             */
// /* -------------------------------------------------------------------------- */
//   ListView _buildListViewOfDevices() {
//     List<Container> containers = [];
//     for (ClassedBTDevice cbtd in widget.avalibleDevices) {
//       BluetoothDevice device = cbtd.device;

//       // if (cbtd.type == ClassedDeviceType.Bonded && device.isConnected == false) continue;

//       containers.add(Container(
//         height: 50,
//         child: Row(
//           children: <Widget>[
//             Expanded(
//               child: Column(
//                 children: <Widget>[
//                   Text(cbtd.getDeviceName()),
//                   Text(device.address.toString()),
//                 ],
//               ),
//             ),
//             ElevatedButton(
//               // * CONNECT BUTTON * //
//               child: Text(
//                 cbtd.isConnected ? 'Disconnect' : 'Connect',
//                 style: TextStyle(color: Colors.white),
//               ),
//               onPressed: () async {
//                 if (cbtd.isConnected) {
//                   cbtd.disconnect().then((value) => setState(() {}));
//                 } else {
//                   connectTo(cbtd);
//                 }
//               },
//             ),
//           ],
//         ),
//       ));
//     }

//     return ListView(
//       padding: const EdgeInsets.all(8),
//       children: <Widget>[
//         ...containers,
//       ],
//     );
//   }
// }

// class ClassedBTDevice {
//   BluetoothDevice device;
//   ClassedDeviceType type;
//   bool isConnected = false;
//   BluetoothConnection connection;

//   ClassedBTDevice(this.device, this.type, {this.connection, this.isConnected = false});

//   Future disconnect() async {
//     connection.close();
//     connection.dispose();
//     isConnected = false;
//   }

//   String getDeviceName() {
//     return device.name == null ? '(unknown device)' + ' | ' + device.type.stringValue ?? 'unknown' : device.name + ' | ' + device.type.stringValue ?? 'unknown';
//   }
// }

// enum ClassedDeviceType { Bonded, Scanned }
