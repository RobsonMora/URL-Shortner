import 'dart:async';

import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:first_app/openGraphParser.dart';
import 'package:flushbar/flushbar.dart';
import 'package:first_app/webRequest.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:animated_card/animated_card.dart';
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
                  child: FractionallySizedBox(child: HistoryPage(urls)),
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

class Home extends StatefulWidget {
  final List urls;

  final VoidCallback onAdd;

  @override
  _HomeState createState() => _HomeState(urls, onAdd);

  Home(
    this.urls,
    this.onAdd,
  );
}

class _HomeState extends State<Home> {
  final List urls;
  final VoidCallback onAdd;

  _HomeState(this.urls, this.onAdd);

  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  final TextEditingController _textURLController = TextEditingController();

  final TextEditingController _textShortController = TextEditingController();

  final WebRequest webRequest = WebRequest();

  void AddUrl(String urlLong, String urlShort) {
    urls.add({'urlLong': urlLong, 'urlShort': urlShort});
  }

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
      AddUrl(url, _textShortController.text);
      onAdd();
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
        child: FractionallySizedBox(
          widthFactor: 0.70,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
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
              Container(
                child: RoundedLoadingButton(
                  child:
                      Text('Short it!', style: TextStyle(color: Colors.white)),
                  color: _textURLController.text.trim().isEmpty
                      ? Colors.blueGrey
                      : Colors.purple,
                  controller: _btnController,
                  onPressed:
                      _textURLController.text.trim().isEmpty ? null : _doShort,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
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
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  @override
//  final list = List.generate(50, (index) => index);
  final List urls;

  HistoryPage(this.urls);

  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Center(
            child: ListView.builder(
                itemCount: urls.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: AnimatedCard(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Item(urls, index),
                      ),
                    ),
                  );
                })),
      ),
    );
  }
}

class Item extends StatelessWidget {
  final List urls;
  final int index;
  final OpenGraphParser htmlPreview = OpenGraphParser();

  Item(this.urls, this.index);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ExpansionTileCard(
        title: Text(urls.elementAt(index)["urlShort"]),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(urls.elementAt(index)["urlLong"]),
        ),
        elevation: 5,
        onExpansionChanged: (value) => {htmlPreview},
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'texto para mostrar no expansor',
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(fontSize: 16),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ButtonBar(
                buttonHeight: 52.0,
                buttonMinWidth: 70.0,
                children: <Widget>[
                  FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0)),
                      onPressed: () {},
                      child: Column(
                        children: <Widget>[
                          Icon(Icons.delete),
                          Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2)),
                          Text('Delete')
                        ],
                      )),
                  FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0)),
                      onPressed: () {},
                      child: Column(
                        children: <Widget>[
                          Icon(Icons.open_in_browser),
                          Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2)),
                          Text('Open')
                        ],
                      )),
                  FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.0)),
                      onPressed: () {},
                      child: Column(
                        children: <Widget>[
                          Icon(Icons.content_copy),
                          Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2)),
                          Text('Copy')
                        ],
                      )),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
