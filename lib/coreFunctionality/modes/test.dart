// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// final counterProvider = StateProvider((ref) => 0);

// void main() {
//   runApp(
//     ProviderScope(
//       child: MaterialApp(
//         home: MyStatefulWidget(),
//       ),
//     ),
//   );
// }

// class MyStatefulWidget extends StatefulWidget {
//   @override
//   _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
// }

// class _MyStatefulWidgetState extends State<MyStatefulWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Counter example'),
//       ),
//       body: Center(
//         child: Consumer(
//           builder: (context, ref, _) {
//             final count = ref.watch(counterProvider);
//             return Text('$count');
//           },
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Use ref.read instead of context.read
//           ref.read(counterProvider.notifier).state++;
//         },
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }
