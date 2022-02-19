import 'dart:convert';
import 'dart:typed_data';

import 'package:newsafer/main.dart';
import 'package:newsafer/pages/emegency_notice_page.dart';
import 'package:newsafer/tool/debug.dart';
import 'package:newsafer/tool/people_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:network_image_to_byte/network_image_to_byte.dart';

/* -------------------------------------------------------------------------- */
/*                                   處理FCM通知                              */
/* -------------------------------------------------------------------------- */

/* ---------------------------- local notifition ---------------------------- */
Future<void> localNotifition(RemoteMessage message) async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    'This channel is used for important notifications.', // description
    importance: Importance.max,
  );
  final AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  // local notification to show to users using the created channel.
  if (notification != null && android != null) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channel.description,
          icon: android?.smallIcon,
          // other properties...
        ),
      ),
    );
  }
  var boxjson = jsonDecode(message.data['message']);
  printcolor('message  : $boxjson', color: DColor.green);
  /* -------------------------------- 點擊通知觸發事件 -------------------------------- */
  await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: (value) {
    Navigator.push(
        navigatorKey.currentState!.context,
        MaterialPageRoute(
          builder: (context) => EmegencyNoticePage(
            LatLng(boxjson['boxData']['latitude'], boxjson['boxData']['longitude']),
            userData: boxjson['userData'],
            boxData: boxjson['boxData'],
          ),
        ));
    return;
  });
}

void putnotificationintodatabase(String title, String content, String photourl, String type, var data) async {
  //將通知放入資料庫
  // ignore: avoid_init_to_null
  Uint8List photo = null;
  if (photourl != null) {
    photo = await networkImageToByte(photourl); //網路照片轉Uint8List
  }
  var sqlitehelp = NotificationData();
  var dataform = {
    'title': title,
    'content': content,
    'photo': photo,
    'type': type,
    'data': data,
    'isopened': 0,
  };
  sqlitehelp.insert(dataform);
}

Future<void> messageHandler(RemoteMessage notification) async {
  //依照不同通知執行
  var datas = json.decode(notification.data['message']);
  print(datas.toString());
  switch (datas['type']) {
    //好友邀請通知
    case 'App\\Notifications\\friendInvitationNotification':
      putnotificationintodatabase(
        '${datas['userData']['name']}',
        '想成為你好友',
        datas['userData']['photo'],
        datas['type'],
        datas,
      );
      break;
    case 'urgent': //緊急通知
      localNotifition(notification);
      putnotificationintodatabase(
        '${datas['userData']['name']}',
        '${datas['body']}',
        datas['userData']['photo'],
        datas['type'],
        datas['boxData']['boxMessage'],
      );
      break;
    case 'create_notes': //同步新增備忘錄
      UsermemoDB(
              user_id: datas['user_id'],
              name: datas['name'],
              notes_num: datas['notes_num'],
              content: datas['content'],
              created_by: datas['created_by'].toString(),
              date: datas['date'],
              finish_status: 0)
          .insert();
      break;
    case 'edit_notes': //同步修改備忘錄
      UsermemoDB().editmemoinformation(int.parse(datas['notes_num']), datas['content']);
      break;
    case 'delete_notes': //同步刪除備忘錄
      UsermemoDB().delet(int.parse(datas['notes_num']));
      break;
    case 'done_notes': //同步完成狀態
      UsermemoDB().updatacheck(datas['finish_status'], datas['notes_num']);
      break;
    default:
      localNotifition(notification);
  }
}
