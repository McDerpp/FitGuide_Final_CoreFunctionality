import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SwipeableContainer(),
    );
  }
}

class SwipeableContainer extends StatefulWidget {
  @override
  _SwipeableContainerState createState() => _SwipeableContainerState();
}

class _SwipeableContainerState extends State<SwipeableContainer> {
  final List<String> information = [
    "Information 1",
    "Information 2",
    "Information 3",
  ];

  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Swipeable Container"),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          // Swipe to the right
          if (details.primaryVelocity! > 0) {
            _pageController.previousPage(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeOut,
            );
          }
        },
        child: PageView.builder(
          controller: _pageController,
          itemCount: information.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.all(16.0),
              child: Text(
                information[index],
                style: TextStyle(fontSize: 20.0),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Move to the next page programmatically
          _pageController.nextPage(
            duration: Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        },
        child: Icon(Icons.arrow_forward),
      ),
    );
  }
}
