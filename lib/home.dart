import 'dart:async';

import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import 'webRequest.dart';

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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 50),
                Image.asset('assets/\images/\open-graph.png'),
                SizedBox(height: 50),
                Container(
                  height: 70,
                  child: TextField(
                    controller: _textURLController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      focusColor: Colors.purple,
                      fillColor: Colors.purple,
                      labelText: 'URL',
                      suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _textURLController.text = '';
                            _textShortController.text = '';
                          }),
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
                    child: Text('Short it!',
                        style: TextStyle(color: Colors.white)),
                    color: _textURLController.text.trim().isEmpty
                        ? Colors.blueGrey
                        : Colors.blue,
                    controller: _btnController,
                    onPressed: _textURLController.text.trim().isEmpty
                        ? null
                        : _doShort,
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
                              duration: Duration(milliseconds: 1500),
                            ).show(context);
                          }),
                      labelText: 'Short URL',
                    ),
                  ),
                ),
                Container(
                  height: 45,
                  width: 95,
                  child: FlatButton(
                      color: Color(0xF4BEE0FF3),
                      onPressed: () {
                        AddUrl(
                            'https://g1.globo.com/politica/noticia/2020/07/26/presidente-do-stj-testa-positivo-para-coronavirus.ghtml',
                            'https://rel.ink/nr7adv');
                        AddUrl(
                            'https://stackoverflow.com/questions/53577962/better-way-to-load-images-from-network-flutter',
                            'https://rel.ink/kdOolz');
                        AddUrl('https://github.com/RobsonMora/URL-Shortner',
                            'https://rel.ink/kzweGN');
                        onAdd();
                      },
                      child: Text('DEBUG!')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
