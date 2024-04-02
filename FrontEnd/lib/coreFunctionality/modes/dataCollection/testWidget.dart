// import 'package:flutter/material.dart';
// import 'package:stop_watch_timer/stop_watch_timer.dart';

// class CountDownTimerPage extends StatefulWidget {
//   static Future<void> navigatorPush(BuildContext context) async {
//     return Navigator.of(context).push<void>(
//       MaterialPageRoute(
//         builder: (_) => CountDownTimerPage(),
//       ),
//     );
//   }

//   @override
//   _State createState() => _State();
// }

// class _State extends State<CountDownTimerPage> {
//   final _isHours = true;

//   final StopWatchTimer _stopWatchTimer = StopWatchTimer(
//     mode: StopWatchMode.countUp,
//     presetMillisecond: StopWatchTimer.getMilliSecFromSecond(0),
//     // onChange: (value) => print('onChange $value'),
//     // onChangeRawSecond: (value) => print('onChangeRawSecond $value'),
//     // onChangeRawMinute: (value) => print('onChangeRawMinute $value'),
//     onStopped: () {
//       print('onStopped');
//     },
//     onEnded: () {
//       print('onEnded');
//     },
//   );

//   final _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     // _stopWatchTimer.rawTime.listen((value) =>
//     //     print('rawTime $value ${StopWatchTimer.getDisplayTime(value)}'));
//     // _stopWatchTimer.minuteTime.listen((value) => print('minuteTime $value'));
//     // _stopWatchTimer.secondTime.listen((value) => print('secondTime $value'));
//     // _stopWatchTimer.records.listen((value) => print('records $value'));
//     // _stopWatchTimer.fetchStopped
//     //     .listen((value) => print('stopped from stream'));
//     // _stopWatchTimer.fetchEnded.listen((value) => print('ended from stream'));

//     /// Can be set preset time. This case is "00:01.23".
//     // _stopWatchTimer.setPresetTime(mSec: 1234);
//   }

//   @override
//   void dispose() async {
//     super.dispose();
//     await _stopWatchTimer.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: <Widget>[
//         /// Display stop watch time
//         StreamBuilder<int>(
//           stream: _stopWatchTimer.rawTime,
//           initialData: _stopWatchTimer.rawTime.value,
//           builder: (context, snap) {
//             final value = snap.data!;
//             final displayTime = StopWatchTimer.getDisplayTime(value,
//                 minute: true, hours: false, milliSecond: false);
//             return Column(
//               children: <Widget>[
//                 Padding(
//                   padding: const EdgeInsets.all(8),
//                   child: Text(
//                     displayTime,
//                     style: const TextStyle(
//                         fontSize: 40,
//                         fontFamily: 'Helvetica',
//                         fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),

//         /// Button
//         Padding(
//           padding: const EdgeInsets.only(bottom: 0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               Flexible(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 4),
//                   child: FilledButton(
//                     onPressed: _stopWatchTimer.onStartTimer,
//                     child: const Text(
//                       'Start',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ),
//               Flexible(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 4),
//                   child: FilledButton(
//                     onPressed: _stopWatchTimer.onStopTimer,
//                     child: const Text(
//                       'Stop',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';

/// Flutter code sample for [DropdownButton].

const List<String> list = <String>['One', 'Two', 'Three', 'Four'];

void main() => runApp(const DropdownButtonApp());

class DropdownButtonApp extends StatelessWidget {
  const DropdownButtonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('DropdownButton Sample')),
        body: const Center(
          child: DropdownButtonExample(),
        ),
      ),
    );
  }
}

class DropdownButtonExample extends StatefulWidget {
  const DropdownButtonExample({super.key});

  @override
  State<DropdownButtonExample> createState() => _DropdownButtonExampleState();
}

class _DropdownButtonExampleState extends State<DropdownButtonExample> {
  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
        });
      },
      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
