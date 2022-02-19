// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// import 'package:newsafer/CustomWidgets/ActionButton.dart';
// import 'package:newsafer/tool/debug.dart';

// import 'package:flutter_blue/flutter_blue.dart';

// class BluetoothSettingsPage extends StatefulWidget {
//   final FlutterBlue flutterBlue = FlutterBlue.instance;
//   final List<_ClassedDevice> devicesList = [];

//   @override
//   State<StatefulWidget> createState() => _BluetoothState();
// }

// class _BluetoothState extends State<BluetoothSettingsPage> {
//   final List<StreamSubscription> subs = [];

// /* -------------------------------------------------------------------------- */
// /*                             Start of the Widget                            */
// /* -------------------------------------------------------------------------- */
//   @override
//   void initState() {
//     super.initState();
//     printcolor('Initiating BluetoothSetting Page', color: DColor.green);
//     // Hook listener to connected device.
//     subs.add(
//       widget.flutterBlue.connectedDevices.asStream().listen((List<BluetoothDevice> devices) {
//         for (BluetoothDevice device in devices) {
//           _addDeviceTolist(device, 'Connected');
//         }
//       }),
//     );
//     // Hook listener to scanned device.
//     subs.add(
//       widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
//         for (ScanResult result in results) {
//           _addDeviceTolist(result.device, 'Scanned', scanResult: result);
//         }
//       }),
//     );
//     // Hook listener to Bluetooth state changes.
//     subs.add(
//       widget.flutterBlue.state.listen((event) {
//         printcolor('BluetoothState: ${event.toString()}');
//       }),
//     );
//     // Starting the scan.
//     try {
//       printcolor('Start scanning devices', color: DColor.green);
//       // widget.flutterBlue.startScan();
//       widget.flutterBlue.startScan(scanMode: ScanMode.lowPower).asStream().listen((scanResult) {});
//     } catch (e) {
//       print('Scanning already in action, keep scanning.');
//     }
//   }

// /* -------------------------------------------------------------------------- */
// /*                             Build of the Widget                            */
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
//             widget.flutterBlue.stopScan();
//             unsubscribeAll();
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
//             icon: const Icon(Icons.countertops),
//             onPressed: () {
//               printcolor('Subs cound: ${subs.length}', color: DColor.magenta);
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
// /*                              End of the Widget                             */
// /* -------------------------------------------------------------------------- */
//   @override
//   void dispose() {
//     super.dispose();
//     widget.devicesList.clear();
//     widget.flutterBlue.stopScan();
//     widget.flutterBlue.connectedDevices.asStream().listen((event) {
//       for (BluetoothDevice device in event) {
//         printcolor('Disconnecting ${device.id}', color: DColor.cyan);
//         device.disconnect();
//       }
//     });
//     unsubscribeAll();
//   }

// /* -------------------------------------------------------------------------- */
// /*                          Unsubscribe all listeners                         */
// /* -------------------------------------------------------------------------- */
//   void unsubscribeAll() {
//     printcolor('Canceling ${subs.length} subscriptions', color: DColor.blue);
//     for (int i = 0; i < subs.length; i++) {
//       subs[0].cancel();
//       subs.removeAt(0);
//     }
//   }

// /* -------------------------------------------------------------------------- */
// /*          Add scanned device to the list, will checks if duplicate.         */
// /* -------------------------------------------------------------------------- */
//   _addDeviceTolist(final BluetoothDevice device, String type, {ScanResult scanResult}) {
//     _ClassedDevice scannedDevice = new _ClassedDevice(device: device, type: type);

//     // check if list already contains the device.
//     bool found = false;
//     for (_ClassedDevice d in widget.devicesList) {
//       if (d.device.id == device.id) {
//         found = true;
//         break;
//       }
//     }
//     // Get device name
//     String deviceName = scanResult.advertisementData.localName ?? device.name;
//     // Add the device to the list.
//     if (found == false) {
//       print('Found $deviceName, id: ${device.id}, founded: $found, type: ${device.type.index}');
//       if (scanResult != null) {
//         print('rssi: ${scanResult.rssi}');
//       }
//       // refresh the page.
//       setState(() {
//         widget.devicesList.add(scannedDevice);
//       });
//     }
//   }

// /* -------------------------------------------------------------------------- */
// /*                         Connecting to given device                         */
// /* -------------------------------------------------------------------------- */
//   void connect(_ClassedDevice _classedDevice) async {
//     widget.flutterBlue.stopScan();
//     BluetoothDevice device = _classedDevice.device;
//     printcolor('Connecting to: ' + device.name, color: DColor.green);
//     device.state.listen((event) {
//       printcolor('BluetoothDeviceState: ${event.toString()}', color: DColor.magenta);
//     });

//     try {
//       device.state.handleError((event) {
//         printcolor(event, color: DColor.red);
//       });
//       await device.connect(timeout: Duration(seconds: 10));
//       // Successfully connect to device.
//       printcolor('Successfully connected to: ${device.id}', color: DColor.green);
//       _classedDevice.isConnected = true;
//     } catch (e) {
//       if (e.code == 'already_connected') {
//         printcolor('Already connected!', color: DColor.green);
//       } else if (e.message == 'Failed to connect in time.') {
//         printcolor('Timed out!, bailing out!', color: DColor.green);
//         return;
//       }
//     } finally {
//       setState(() {});
//       hookListenersToDevice(_classedDevice);
//     }
//   }

// /* -------------------------------------------------------------------------- */
// /*                           Hook Listener to Device                          */
// /* -------------------------------------------------------------------------- */
//   void hookListenersToDevice(_ClassedDevice _classedDevice) async {
//     BluetoothDevice device = _classedDevice.device;

//     // Discover Services
//     List<BluetoothService> services = await device.discoverServices();

//     printcolor('Services: ', color: DColor.cyan);

//     // Looping in Services
//     for (BluetoothService BS in services) {
//       printcolor('\t${BS.isPrimary ? 'Primary: ' : ''}${BS.uuid}', color: DColor.cyan);

//       // Looping in Characteristics
//       for (BluetoothCharacteristic BC in BS.characteristics) {
//         printcolor('\t\tCharacteristic: ${BC.uuid}', color: DColor.cyan);
//         printcolor('\t\t\tReadable: ${BC.properties.read}, Writable: ${BC.properties.write}, Notible: ${BC.properties.notify}', color: DColor.cyan);
//         if (BC.uuid.toString().compareTo('000000a1-0000-1000-8000-00805f9b34fb') != 0) break;
//         // If Characteristic's properties contains read.
//         // if (BC.properties.read) {
//         //   // Hooking Listener to Characteristic.
//         //   subs.add(BC.read().asStream().listen((event) async {
//         //     printcolor('Device: ${device.id}, Service: ${BS.uuid}\nMessage: ${event.toString()}', color: DColor.yellow);
//         //   }));
//         //   printcolor('\t\t\t\tListener Hooked!', color: DColor.cyan);
//         // }
//         if (BC.properties.write) {
//           printcolor('Sets writable characteristic', color: DColor.green);
//           _classedDevice.writableCharacteristic = BC;
//         }
//         if (BC.properties.notify) {
//           printcolor('Setting Notification for: ${BC.uuid}', color: DColor.cyan);
//           await BC.setNotifyValue(true);
//           BC.value.listen((event) {
//             printcolor('Value: $event', color: DColor.yellow);
//           });
//           // subs.add(BC.setNotifyValue(true).asStream().listen((event) async {
//           //   printcolor('Notification!', color: DColor.yellow);
//           //   List<int> values = await BC.read();
//           //   printcolor('Value: $values', color: DColor.yellow);
//           // }));
//         }
//         // for (BluetoothDescriptor BD in BC.descriptors) {
//         //   printcolor(('\t' + BD.uuid.toMac()), color: DColor.cyan);
//         // }
//       }
//     }
//   }

// /* -------------------------------------------------------------------------- */
// /*           Build Widget ListView for scanned or connected Devices           */
// /* -------------------------------------------------------------------------- */
//   ListView _buildListViewOfDevices() {
//     List<Container> containers = [];
//     for (_ClassedDevice classedDevice in widget.devicesList) {
//       containers.add(Container(
//         height: 50,
//         child: Row(
//           children: <Widget>[
//             Expanded(
//               child: Column(
//                 children: <Widget>[
//                   Text(classedDevice.device.name == '' ? '(unknown device)' + ' | ' + classedDevice.type : classedDevice.device.name + ' | ' + classedDevice.type),
//                   Text(classedDevice.device.id.toString()),
//                 ],
//               ),
//             ),
//             ElevatedButton(
//               // * CONNECT BUTTON * //
//               child: Text(
//                 classedDevice.isConnected ? 'Send Message' : 'Connect',
//                 style: TextStyle(color: Colors.white),
//               ),
//               onPressed: () {
//                 // If connected, Open up send message dialog, if not, connect to it.
//                 if (!classedDevice.isConnected)
//                   connect(classedDevice);
//                 else {
//                   final TextFormField textField = TextFormField(
//                     controller: TextEditingController(),
//                   );
//                   showDialog(
//                     context: context,
//                     builder: (_) => AlertDialog(
//                       title: Text('Send Message'),
//                       content: textField,
//                       actions: <Widget>[
//                         TextButton(
//                           child: Text('Send'),
//                           onPressed: () {
//                             const AsciiCodec ascii = AsciiCodec();
//                             List<int> encoded = ascii.encode(textField.controller.text);
//                             printcolor('Sended encoded text: $encoded', color: DColor.orange);
//                             printcolor('Sended to: ${classedDevice.writableCharacteristic.uuid}', color: DColor.orange);
//                             classedDevice.writableCharacteristic.write(encoded);
//                             Navigator.of(context).pop();
//                             setState(() {});
//                           },
//                         ),
//                       ],
//                     ),
//                   );
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

// class _ClassedDevice {
//   BluetoothDevice device;
//   String type;
//   bool isConnected = false;
//   BluetoothCharacteristic writableCharacteristic;
//   _ClassedDevice({this.device, this.type});
// }
