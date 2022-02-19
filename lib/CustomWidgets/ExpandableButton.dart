// import 'dart:math' as math;

// import 'package:flutter/material.dart';

// @immutable
// class ExpandableFab extends StatefulWidget {
//   const ExpandableFab({
//     Key key,
//     this.initialOpen,
//     this.duration,
//     this.distance,
//     this.defaultIcon,
//     this.children,
//   }) : super(key: key);

//   /// Drafule IconData when Fab is closed.
//   final IconData defaultIcon;

//   /// The initial state of the Fab, 0: Closed, 1: Opened
//   final bool initialOpen;

//   /// The distance of the child buttons to travel.
//   final double distance;

//   /// The buttons os child.
//   final List<Widget> children;

//   /// The expand duration(milliseconds) with both direction. Default 250ms
//   final Duration duration;

//   @override
//   _ExpandableFabState createState() {
//     return new _ExpandableFabState();
//   }
// }

// class _ExpandableFabState extends State<ExpandableFab>
//     with SingleTickerProviderStateMixin {
//   AnimationController _controller;
//   Animation<double> _expandAnimation;
//   Icon _defaultIcon;
//   bool _open = false;

//   _ExpandableFabState() {
//     // if (widget == null) print('ERROR: widget is null!!');
//     // if (widget.defaultIcon == null) print('ERROR: defaultIcon is null!!');
//     _defaultIcon = Icon(widget.defaultIcon);
//     _controller = AnimationController(
//       value: _open ? 1.0 : 0.0,
//       duration: widget.duration ?? Duration(milliseconds: 250),
//       vsync: this,
//     );
//     _expandAnimation = CurvedAnimation(
//       curve: Curves.fastOutSlowIn,
//       reverseCurve: Curves.easeOutQuad,
//       parent: _controller,
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     _open = widget.initialOpen ?? false;
//   }

//   @override
//   void dispose() {
//     // Dispose when widget get destroys
//     _controller.dispose();
//     super.dispose();
//   }

//   /// Toggle the Fab to expand and retract.
//   void _toggle() {
//     setState(() {
//       _open = !_open;
//       if (_open) {
//         _controller.forward();
//       } else {
//         _controller.reverse();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox.expand(
//       child: Stack(
//         alignment: Alignment.bottomRight,
//         clipBehavior: Clip.none,
//         children: [
//           _buildTapToCloseFab(),
//           ..._buildExpandingActionButtons(),
//           _buildTapToOpenFab(),
//         ],
//       ),
//     );
//   }

//   Widget _buildTapToCloseFab() {
//     return SizedBox(
//       width: 56.0,
//       height: 56.0,
//       child: Center(
//         child: Material(
//           shape: const CircleBorder(),
//           clipBehavior: Clip.antiAlias,
//           elevation: 4.0,
//           child: InkWell(
//             onTap: _toggle,
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Icon(
//                 Icons.close,
//                 color: Theme.of(context).primaryColor,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   List<Widget> _buildExpandingActionButtons() {
//     final children = <Widget>[];
//     final count = widget.children.length;
//     final step = 90.0 / (count - 1);
//     for (var i = 0, angleInDegrees = 0.0;
//         i < count;
//         i++, angleInDegrees += step) {
//       children.add(
//         _ExpandingActionButton(
//           directionInDegrees: angleInDegrees,
//           maxDistance: widget.distance,
//           progress: _expandAnimation,
//           child: widget.children[i],
//         ),
//       );
//     }
//     return children;
//   }

//   Widget _buildTapToOpenFab() {
//     return IgnorePointer(
//       ignoring: _open,
//       child: AnimatedContainer(
//         alignment: Alignment.center,
//         transform: Matrix4.diagonal3Values(
//           _open ? 0.7 : 1.0,
//           _open ? 0.7 : 1.0,
//           1.0,
//         ),
//         duration: const Duration(milliseconds: 250),
//         curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
//         child: AnimatedOpacity(
//           opacity: _open ? 0.0 : 1.0,
//           curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
//           duration: const Duration(milliseconds: 250),
//           child: FloatingActionButton(
//             onPressed: _toggle,
//             child: _defaultIcon,
//           ),
//         ),
//       ),
//     );
//   }
// }

// @immutable
// class _ExpandingActionButton extends StatelessWidget {
//   _ExpandingActionButton({
//     Key key,
//     this.directionInDegrees,
//     this.maxDistance,
//     this.progress,
//     this.child,
//   }) : super(key: key);

//   final double directionInDegrees;
//   final double maxDistance;
//   final Animation<double> progress;
//   final Widget child;

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: progress,
//       builder: (context, child) {
//         final offset = Offset.fromDirection(
//           directionInDegrees * (math.pi / 180.0),
//           progress.value * maxDistance,
//         );
//         return Positioned(
//           right: 4.0 + offset.dx,
//           bottom: 4.0 + offset.dy,
//           child: Transform.rotate(
//             angle: (1.0 - progress.value) * math.pi / 2,
//             child: child,
//           ),
//         );
//       },
//       child: FadeTransition(
//         opacity: progress,
//         child: child,
//       ),
//     );
//   }
// }
