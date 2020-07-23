import 'dart:async';

import 'package:first_app/webRequest.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  final TextEditingController _textURLController = TextEditingController();
  final TextEditingController _textShortController = TextEditingController();
  final WebRequest webRequest = WebRequest();

  void _doSomething() async {
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
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlueAccent,
          title: Text(
            'URL-Zip',
          ),
        ),
        body: Center(
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
                    labelText: 'URL',
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              RoundedLoadingButton(
                child: Text('Short it!', style: TextStyle(color: Colors.white)),
                controller: _btnController,
                onPressed: _doSomething,
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                width: 250,
                height: 50,
                child: TextField(
                  controller: _textShortController,
                  readOnly: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
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
