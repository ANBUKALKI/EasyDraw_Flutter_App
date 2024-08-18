// import 'package:flutter/material.dart';
// import 'package:knob_widget/knob_widget.dart';
// import 'dart:math';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Knob Widget Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: KnobDemo(),
//     );
//   }
// }
//
// class KnobDemo extends StatefulWidget {
//   @override
//   _KnobDemoState createState() => _KnobDemoState();
// }
//
// class _KnobDemoState extends State<KnobDemo> {
//   final double _minimum = 10;
//   final double _maximum = 40;
//   late KnobController _controller;
//   late double _knobValue;
//
//   @override
//   void initState() {
//     super.initState();
//     _knobValue = _minimum;
//     _controller = KnobController(
//       initial: _knobValue,
//       minimum: _minimum,
//       maximum: _maximum,
//       startAngle: 0,
//       endAngle: 180,
//     );
//     _controller.addOnValueChangedListener(valueChangedListener);
//   }
//
//   void valueChangedListener(double value) {
//     if (mounted) {
//       setState(() {
//         _knobValue = value;
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     _controller.removeOnValueChangedListener(valueChangedListener);
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Knob Widget Demo'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Knob(
//               controller: _controller,
//               width: 200,
//               height: 200,
//               style: KnobStyle(
//                 labelStyle: Theme.of(context).textTheme.headline6,
//                 tickOffset: 5,
//                 labelOffset: 10,
//                 minorTicksPerInterval: 5,
//               ),
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Current Value: ${_knobValue.toStringAsFixed(1)}',
//               style: Theme.of(context).textTheme.headline5,
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 var value = Random().nextDouble() * (_maximum - _minimum) + _minimum;
//                 _controller.setCurrentValue(value);
//               },
//               child: const Text('Update Knob Value'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }