
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BannerGalleryWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _BannerGalleryWidgetState();
  }
}

class _BannerGalleryWidgetState extends State<BannerGalleryWidget> {
  final PageController controller = PageController(initialPage: 100);
  /// 指定一個控制器，用來控制PageView的滑動，以及初始位置在第200頁
  /// 主要爲了實現“無限循環”

  // void _pageChanged(int index) {
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return SizedBox( /// 一個固定大小的容器，這裏指定了他的高爲250
        height: 250.0,
        child: Container( /// 一個容器，用來設定背景顏色爲灰色
          color: Colors.grey,
          child: PageView.builder( /// 主角PageView,文字居中顯示當前的索引
            controller: controller,
            itemBuilder: (context, index) {
              return new Center(
                child: new Text('頁面 ${(index-100)}'),
              );
            },
          ),
        ));
  }

//把佈局容器改一下，用一個列包裹PageView和Indicator
//給PageView加一個onPageChanged，檢查當頁面修改的時候setState()刷新UI就好了
  // Widget build(BuildContext context) {
  //   return Column(
  //     children: <Widget>[
  //       SizedBox(
  //           height: MediaQuery.of(context).size.height-100,
  //           child: Container(
  //             color: Colors.grey,
  //             child: PageView.builder(
  //               onPageChanged: _pageChanged,
  //               controller: controller,
  //               itemBuilder: (context, index) {
  //                 return new Center(
  //                   child: new Text('頁面 ${index}'),
  //                 );
  //               },
  //             ),
  //           )),
  //       Indicator(
  //         controller: controller,
  //         itemCount: 5,
  //       ),
  //     ],
  //   );
  // }
  ///
}


//  class Indicator extends StatelessWidget {
//   Indicator({
//     this.controller,
//     this.itemCount: 0,
//   }) : assert(controller != null);

//   /// PageView的控制器
//   final PageController controller;

//   /// 指示器的個數
//   final int itemCount;

//   /// 普通的顏色
//   final Color normalColor = Colors.blue;

//   /// 選中的顏色
//   final Color selectedColor = Colors.red;

//   /// 點的大小
//   final double size = 8.0;

//   /// 點的間距
//   final double spacing = 4.0;

//   /// 點的Widget
//   Widget _buildIndicator(
//       int index, int pageCount, double dotSize, double spacing) {
//     // 是否是當前頁面被選中
//     bool isCurrentPageSelected = index ==
//         (controller.page != null ? controller.page.round() % pageCount : 0);

//     return new Container(
//       height: size,
//       width: size + (2 * spacing),
//       child: new Center(
//         child: new Material(
//           color: isCurrentPageSelected ? selectedColor : normalColor,
//           type: MaterialType.circle,
//           child: new Container(
//             width: dotSize,
//             height: dotSize,
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return new Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: new List<Widget>.generate(itemCount, (int index) {
//         return _buildIndicator(index, itemCount, size, spacing);
//       }),
//     );
//   }
// }

