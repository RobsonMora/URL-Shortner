import 'dart:async';

import 'package:flushbar/flushbar.dart';
import 'package:first_app/webRequest.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:animated_card/animated_card.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final PageController pageController = PageController(viewportFraction: 0.8);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,        
      ),
      debugShowCheckedModeBanner: false,
      home: Flex(
        direction: Axis.vertical,
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                height: 1050,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: FractionalOffset.bottomCenter,
                    colors: [Colors.lightBlueAccent, Colors.purple],
                    stops: [0, 1],
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                      height: 900,
                      child: PageView(
                        controller: pageController,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            child: Home(),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            child: HistoryPage(),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SmoothPageIndicator(
                      controller: pageController,
                      count: 2,
                      effect: WormEffect(
                          dotColor: Colors.white,
                          activeDotColor: Colors.purple),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  final TextEditingController _textURLController = TextEditingController();

  final TextEditingController _textShortController = TextEditingController();

  final WebRequest webRequest = WebRequest();

  void _doShort() async {
    String url = _textURLController.text;
    if (url.trim().isEmpty) {
      _reset();
      return;
    }
    final Response response = await webRequest.send(url);

    if (response.statusCode == 201) {
      _btnController.success();
      _reset();
      _textShortController.text = webRequest.getShortenUrl(response);
    } else {
      _reset();
      _textShortController.text = 'Invalid URL!';
    }
  }

  void _reset() async {
    Timer(Duration(seconds: 1), () {
      _btnController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 250,
              height: 70,
              child: TextField(
                controller: _textURLController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  focusColor: Colors.purple,
                  fillColor: Colors.purple,
                  labelText: 'URL',
                ),
                style: TextStyle(decorationColor: Colors.purple),
                onChanged: (value) => setState(() {}),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            RoundedLoadingButton(
              child: Text('Short it!', style: TextStyle(color: Colors.white)),
              color: _textURLController.text.trim().isEmpty
                  ? Colors.blueGrey
                  : Colors.purple,
              controller: _btnController,
              onPressed:
                  _textURLController.text.trim().isEmpty ? null : _doShort,
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              width: 250,
              height: 70,
              child: TextField(
                controller: _textShortController,
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                      icon: Icon(Icons.content_copy),
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: _textShortController.text));

                        Flushbar(
                          message: 'Copied to clipboard!',
                          duration: Duration(seconds: 1),
                        ).show(context);
                        // final snackBar = SnackBar(
                        //   content: Text('Copied to clipboard!'),
                        //   duration: Duration(seconds: 1),
                        // );

                        // Scaffold.of(context).showSnackBar(snackBar);
                      }),
                  labelText: 'Short URL',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  @override
  final list = List.generate(50, (index) => index);

  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Center(
          child: ListView.builder(
              //itemCount: list.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: AnimatedCard(
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: SizedBox(
                        height: 75,
                        width: 500,
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          margin:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          color: Colors.blue,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: FractionalOffset.bottomCenter,
                                colors: [Colors.blueAccent, Colors.purple],
                                stops: [0, 1],
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              })),
    );
  }
}
