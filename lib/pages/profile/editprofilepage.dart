import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
//
//改ID
//import 'package:newsafer/tool/api_tool.dart';
import 'package:newsafer/tool/debug.dart';
import 'package:newsafer/widgets/send.dart';
import 'package:flutter/services.dart';

import 'package:flutter_image_compress/flutter_image_compress.dart';

class headshot {
  File image; //存儲所選圖像的地方
  // File compress;
  bool isEdit;
}

class name {
  String username;
  bool nameedit;
}

class id {
  String idnumber;
  bool idedit;
}

Image headimage;

/*class FlutterNativeImage {
  static const MethodChannel _channel =
      const MethodChannel('flutter_native_image');

  /// Compress an image
  ///
  /// Compresses the given [fileName].
  /// [percentage] controls by how much the image should be resized. (0-100)
  /// [quality] controls how strong the compression should be. (0-100)
  /// Use [targetWidth] and [targetHeight] to resize the image for a specific
  /// target size.
  static Future<File> compressImage(String fileName,
      {int percentage = 70, //int percentage：默認70，控制圖片大小
      int quality = 70, //int quality：默認70,控制壓縮强度
      int targetWidth = 0, //int targetWidget：默認0，和targetHeight一起重新設置image的大小
      int targetHeight = 0}) } async {
   var file = await _channel.invokeMethod("compressImage", {
      'file': fileName,
      'quality': quality,
      'percentage': percentage,
      'targetWidth': targetWidth,
      'targetHeight': targetHeight
    });
    return new File(file);
  } */

class ChangeVarible {
  //final _namekey_ = GlobalKey<FormState>(); //判斷name輸入的變數
  //final _id_ = GlobalKey<FormState>(); //判斷password輸入的變數
  final String regexPassword = r'^(?=.*?[a-z])(?=.*?[0-9]).{6,30}$'; //校正頁面password格式函數
}

class EditProfilePage extends StatefulWidget {
  final SharedPreferences preferences; //定義一個SharedPreferences接收傳入值，用於個人資料的顯示
  EditProfilePage(this.preferences);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  //頭貼要用的
  headshot imageobj = headshot();
  Image headimage;
  name user_name = name();
  id user_id = id();

  ChangeVarible info = ChangeVarible();

  /*
  //取得 getApplicationDocumentsDirectory 的路徑
  Future<String> get appDocPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
*/
//選照片
  void _openCamera(BuildContext context) async {
    //異步測試不知選照片要多久
    //讓用戶從圖庫或相機選圖像
    var theImage = await ImagePicker().getImage(source: ImageSource.camera);
    //創建一個變量存儲用戶選擇的圖像(從用戶選擇圖像並保存在局部變量中)
    String targetpath = theImage.path.replaceFirst(theImage.path.split("/").last, '') + 'temp.jpg';
    printcolor('image pathh: $targetpath', color: DColor.blue);
    var result = await FlutterImageCompress.compressAndGetFile(
      theImage.path,
      targetpath,
      quality: 88,
    );
    setState(() {
      //設置狀態變量_imageFile
      //imageobj.image = File(theImage.path);
      imageobj.image = result;
      print(imageobj.image.lengthSync());
      imageobj.isEdit = true;
    });
    Navigator.pop(context); //跳出對話框
  }

  void _openGallery(BuildContext context) async {
    var theImage = await ImagePicker().getImage(source: ImageSource.gallery);
    String targetpath = theImage.path.replaceFirst(theImage.path.split("/").last, '') + 'temp.jpg';
    printcolor('image pathh: $targetpath', color: DColor.blue);
    var result = await FlutterImageCompress.compressAndGetFile(
      theImage.path,
      targetpath,
      quality: 88,
    );
    setState(() {
      //設置狀態變量_imageFile
      imageobj.image = result; //(原本)File(theImage.path);
      print(imageobj.image.lengthSync());
      imageobj.isEdit = true;
    });
    Navigator.pop(context);
  }

//文字編輯控制器
  final userdata = GlobalKey<FormState>();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController idcontroller = TextEditingController();
  var data;

  //改ID
  @override
  void initState() {
    super.initState();
    namecontroller..text = widget.preferences.getString('name');
    idcontroller..text = widget.preferences.getString('user_id');
    //LoadImage();
    imageobj.isEdit == false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Scaffold 是 Material Design 布局结構的基本實现 内部包含了 appBar 和 body
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black87,
            size: 24,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          '編輯個人資料',
          style: TextStyle(
            fontSize: 30,
            letterSpacing: 2,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Container(
        padding: EdgeInsets.only(left: 16, top: 25, right: 16),
        child: GestureDetector(
          //檢測如點擊、拖動、保持等交互變簡單(偵測互動手勢)
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context); //用FocusScope.of(context)來獲取 current FocusNode，
            //與我們的文本字段關聯的節點​​（假設您點擊該字段激活它）。
            if (!currentFocus.hasPrimaryFocus) {
              //檢查hasPrimaryFocus，以防止 Flutter 在嘗試使樹頂部的節點不聚焦時拋出異常
              currentFocus.unfocus();
            }
            //檢查當前FocusNode是否具有“主要焦點”。如果沒有，調用unfocus()當前節點移除焦點並觸發鍵盤關閉。
            //如果嘗試 unfocus() 當前具有主要焦點的節點，Flutter 拋出異常。
          },

          child: ListView(padding: EdgeInsets.symmetric(horizontal: 32), physics: BouncingScrollPhysics(), //當列表結束時返回列表
              children: [
                Center(
                  child: Stack(
                    children: [
                      ClipOval(
                        child: imageobj.isEdit != true
                            ? CircleAvatar(
                                radius: 100,
                                backgroundImage: widget.preferences.getString('headimage') != null ? NetworkImage(widget.preferences.getString('headimage')) : AssetImage('assets/images/unnamed.jpg'))
                            : CircleAvatar(
                                radius: 100,
                                backgroundImage: imageobj.image != null ? FileImage(imageobj.image) : AssetImage('assets/images/unnamed.jpg'),
                              ),
                      ),
                      Positioned(
                          bottom: 0,
                          right: 4,
                          child: ElevatedButton(
                            onPressed: () => showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                      title: Text('頭貼更換方式', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.black)),
                                      content: SingleChildScrollView(
                                        child: ListBody(
                                          children: [
                                            InkWell(
                                              onTap: () => _openCamera(context),

                                              splashColor: Color(0xFFB2DFDB), //按下時更改文本按鈕的初始顏色
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Icon(
                                                      Icons.camera,
                                                      color: Color(0xFF26A69A),
                                                    ),
                                                  ),
                                                  Text(
                                                    '相機',
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.black,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            InkWell(
                                              onTap: () => _openGallery(context),
                                              splashColor: Color(0xFFB2DFDB), //按下時更改文本按鈕的初始顏色
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Icon(
                                                      Icons.image,
                                                      color: Color(0xFF26A69A),
                                                    ),
                                                  ),
                                                  Text(
                                                    '相簿',
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.black,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            InkWell(
                                              //onTap: () => RemoveImage(),
                                              splashColor: Color(0xFFB2DFDB), //按下時更改文本按鈕的初始顏色
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Icon(
                                                      Icons.remove_circle,
                                                      color: Color(0xFF26A69A),
                                                    ),
                                                  ),
                                                  Text(
                                                    '移除原先頭貼',
                                                    style: TextStyle(
                                                      fontSize: 24,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.black,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ));
                                }),
                            style: ElevatedButton.styleFrom(
                                primary: Color(0xFF26A69A),
                                //包含了許多「按鈕」的基本定義
                                elevation: 10, //陰影
                                padding: EdgeInsets.all(15),
                                shape: CircleBorder(),
                                side: BorderSide(
                                  width: 2,
                                  color: Colors.white,
                                )),
                            child: Icon(
                              Icons.add_a_photo,
                              color: Colors.white,
                            ),
                          )),
                    ],
                  ),
                ),
                SizedBox(
                  height: 35,
                ),
                Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Container(
                    height: 280,
                    width: double.infinity,
                    // width: MediaQuery.of(context).size.width, //和螢幕一樣大
                    //margin: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                        //將空白區域均分，使各子控件間格相同
                        children: [
                          Material(
                            elevation: 4,
                            shadowColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextFormField(
                              //  initialValue://不能同時跑controller 跟initialValue
                              //      widget.preferences.getString('name'), //起始預設
                              keyboardType: TextInputType.visiblePassword, //輸入型態
                              autofocus: false,
                              controller: namecontroller, //給sharedpreference存
                              onChanged: (value) {
                                setState(() {
                                  user_name.username = this.namecontroller.text;
                                  user_name.nameedit = true;
                                });
                              },
                              decoration: InputDecoration(
                                  labelText: '名字',
                                  labelStyle: TextStyle(
                                    fontSize: 25,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  hintText: '更換顯示的名字',
                                  hintStyle: TextStyle(
                                    letterSpacing: 2,
                                    //color: Colors.black,
                                    fontSize: 20,
                                  ),
                                  fillColor: Colors.white30,
                                  filled: true,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none)),
                              /*validator: (value) {
                                if (value.isNotEmpty) {
                                  info._formData_['name'] = value; //處存name資料
                                  prefences.setString(
                                  info.nameedit = true;
                                  return null;
                                }
                                return '';
                              },
                              */
                            ),
                          ),
                          SizedBox(
                            height: 35,
                          ),
                          Material(
                            elevation: 4,
                            shadowColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextFormField(
                              keyboardType: TextInputType.visiblePassword, //輸入型態
                              autofocus: false,
                              controller: idcontroller, //給sharedpreference存
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[a-z,A-Z,0-9]"))], //限制只允许输入字母和数字
                              onChanged: (value) {
                                setState(() {
                                  user_id.idnumber = this.idcontroller.text;
                                  user_id.idedit = true;
                                });
                              },
                              decoration: InputDecoration(
                                  labelText: 'R-DAP ID',
                                  labelStyle: TextStyle(
                                    fontSize: 25,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  hintText: '做讓大家能找到你的編號',
                                  hintStyle: TextStyle(
                                    letterSpacing: 2,
                                    //color: Colors.black,
                                    fontSize: 20,
                                  ),
                                  fillColor: Colors.white30,
                                  filled: true,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none)),
                              /*validator: (value) {
                                if (value.isNotEmpty) {
                                  info._formData_['id'] = value; //處存name資料
                                 // info.idedit = true;
                                  return null;
                                }
                                return '';
                              },
                              */
                            ),
                          ),
                        ]),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Column(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            side: BorderSide(width: 2, color: Color(0xFF26A69A))),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("取消編輯", style: TextStyle(fontSize: 30, letterSpacing: 2.2, color: Color(0xFF26A69A))),
                      ),
                      //
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32),
                          child: Sendchangeid(
                            idcontroller,
                            imageobj,
                            user_name,
                            user_id,
                            namecontroller,
                            info,
                          ), //調用widgets/send.dart
                        ),
                      )
                    ],
                  )
                ]),
              ]),
        ),
      ),
    );
  }
}
 //RemoveImage() async {
 //   SharedPreferences preferences = await SharedPreferences.getInstance();
 //   preferences.remove('imagepath');
 // }
// var check1 = info._namekey_.currentState.validate(); //更新輸入資料狀態
//if (check1 ) {
//preferences.setString('email',
