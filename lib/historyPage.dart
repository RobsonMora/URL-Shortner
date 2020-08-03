import 'package:animated_card/animated_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'openGraphParser.dart';

class HistoryPage extends StatelessWidget {
  @override
//  final list = List.generate(50, (index) => index);
  final List urls;
  final VoidCallback onChange;

  HistoryPage(this.urls, this.onChange);

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
                        child: Item(key: ValueKey(urls[index]), urls: urls, index: index, onChange: onChange),
                      ),
                    ),
                  );
                })),
      ),
    );
  }
}

class Item extends StatefulWidget {
  final List urls;
  final int index;
  final VoidCallback onChange;
  Item({Key key, this.urls, this.index, this.onChange}): super(key: key);

  @override
  _ItemState createState() => _ItemState();
}

class _ItemState extends State<Item> {
  final OpenGraphParser htmlPreview = OpenGraphParser();

  String imageUrl = "http://via.placeholder.com/150x150";
  String title = "...";
  String description = "...";

  void _loadImage() async {

    Map<String, dynamic> og = await OpenGraphParser.getOpenGraphData(
        widget.urls.elementAt(widget.index)['urlLong']);

    imageUrl = og['image'] ?? '"http://via.placeholder.com/150x150"';
    title = og['title'];
    description = og['description'];
    if(mounted){
      setState(() {});
    }    
  }

  void _deleteItem() {    
    widget.urls.removeAt(widget.index);    
    widget.onChange();
  }

  Future<void> _openUrl() async {
    String url = widget.urls.elementAt(widget.index)["urlShort"];
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      Flushbar(
        message: 'Cannot open this URL!',
        duration: Duration(milliseconds: 1500),
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ExpansionTileCard(
        title: Text(widget.urls.elementAt(widget.index)["urlShort"]),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            widget.urls.elementAt(widget.index)["urlLong"],
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.0,
              fontFamily: 'Roboto',
              color: Color(0xFF212121),
            ),
          ),
        ),
        elevation: 5,
        onExpansionChanged: (value) => {
          if (value)
            {_loadImage()}
        },
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: SizedBox(
                          width: 100,
                          height: 75,                        
                          child: CachedNetworkImage(                            
                            imageUrl: imageUrl,
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              title,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontFamily: 'Roboto',
                                color: Color(0xFF212121),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Divider(
                              height: 5,
                            ),
                            Text(
                              description,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                fontSize: 10.0,
                                fontFamily: 'Roboto',
                                color: Color(0xFF212121),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: ButtonBar(
                  buttonHeight: 52.0,
                  buttonMinWidth: 70.0,
                  alignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0)),
                        onPressed: () {
                          
                          _deleteItem();                          
                        },
                        child: Column(
                          children: <Widget>[
                            Icon(Icons.delete),
                            Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2)),
                            Text('Delete')
                          ],
                        )),
                    FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0)),
                        onPressed: () => _openUrl(),
                        child: Column(
                          children: <Widget>[
                            Icon(Icons.open_in_browser),
                            Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2)),
                            Text('Open')
                          ],
                        )),
                    FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0)),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(
                              text: widget.urls
                                  .elementAt(widget.index)["urlShort"]));

                          Flushbar(
                            message: 'Copied to clipboard!',
                            duration: Duration(milliseconds: 1500),
                          ).show(context);
                        },
                        child: Column(
                          children: <Widget>[
                            Icon(Icons.content_copy),
                            Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2)),
                            Text('Copy')
                          ],
                        )),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
