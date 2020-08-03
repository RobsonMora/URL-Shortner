import 'package:first_app/historyPage.dart';
import 'package:first_app/home.dart';
import 'package:flutter/material.dart';
import 'package:scrolling_page_indicator/scrolling_page_indicator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: FractionallySizedBox(
        heightFactor: 1,
        widthFactor: 1,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: FractionalOffset.bottomCenter,
              colors: [Colors.lightBlueAccent, Colors.purple],
              stops: [0, 1],
            ),
          ),
          child: PageItens(),
        ),
      ),
    );
  }
}

class PageItens extends StatefulWidget {
  @override
  _PageItensState createState() => _PageItensState();
}

class _PageItensState extends State<PageItens> {
  final PageController pageController = PageController(viewportFraction: 0.8);

  final List urls = List();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 50,
        ),
        Expanded(
          child: Container(
            child: PageView(
              controller: pageController,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: FractionallySizedBox(
                      child: Home(urls, () => setState(() {}))),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: FractionallySizedBox(child: HistoryPage(urls,  () => setState(() {}))),
                )
              ],
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        ScrollingPageIndicator(
          controller: pageController,
          itemCount: 2,
          dotSpacing: 17,
          dotColor: Colors.grey,
          dotSelectedColor: Colors.white,
          dotSize: 8,
          dotSelectedSize: 12,
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }
}