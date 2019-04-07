import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';

void main() => runApp(
    new MaterialApp(title: 'Quotter', theme: ThemeData.dark(), home: new HP()));
const ER = "ER";

class HP extends StatefulWidget {
  //final FavQuoteStorage strUt = FavQuoteStorage();
  @override
  State<StatefulWidget> createState() {
    return _HPS();
  }
}

class _HPS extends State<HP> {
  bool _isFav = false;
  String _curPgQt;
  String _auth;
  int _qind;
  List<Quote> _qu;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: new FutureBuilder(
        future: DefaultAssetBundle.of(context).loadString('assets/quotes.json'),
        builder: (context, snapshot) {
          _qu = parseJson(snapshot.data.toString());
          return _buildQuotesPages();
        },
      ),
    );
  }

  Widget _buildQuotesPages() {
    return new PageView.builder(
      itemBuilder: (context, position) {
        return _buildQuoteCard();
      },
      scrollDirection: Axis.horizontal,
      reverse: false,
      physics: BouncingScrollPhysics(),
      onPageChanged: (int index) {
        // if (_isFav) {
        //   widget.strUt.writeFavQuotes(_qind.toString().trim() + ',');
        // }

        setState(() {
          _isFav = false;
          _qind = new Random().nextInt(_qu.length);
        });
      },
    );
  }

  Widget _buildAppBar() {
    return new AppBar(
      centerTitle: true,
      title: Text(
        'Quotter',
        style: new TextStyle(
            color: Colors.yellow,
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Courgette'),
      ),
    );
  }

  Widget _buildQuoteCard() {
    return new Card(
      color: Color(0xff212121),
      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 60.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          new Container(
            margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
            child: _buildQuoteText(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteText() {
    if (_qind == null) _qind = new Random().nextInt(_qu.length);
    _curPgQt = _qu[_qind].quoteText;
    _auth = "- " + _qu[_qind].quoteAuthor;
    return new Column(
      children: <Widget>[
        new Container(
          margin: EdgeInsets.all(20.0),
          child: Text(
            _curPgQt,
            textAlign: TextAlign.justify,
            style: new TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'RobotoSlab',
            ),
          ),
        ),
        new Container(
          margin: EdgeInsets.all(20.0),
          child: Text(
            _auth,
            textAlign: TextAlign.right,
            style: new TextStyle(
              color: Colors.yellow,
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courgette',
            ),
          ),
        ),
      ],
    );
  }
}

List<Quote> parseJson(String response) {
  if (response == null) {
    return [];
  }
  final parsed = json.decode(response).cast<Map<String, dynamic>>();
  return parsed.map<Quote>((json) => new Quote.fromJson(json)).toList();
}

class Quote {
  final String quoteText;
  final String quoteAuthor;
  Quote({this.quoteText, this.quoteAuthor});
  factory Quote.fromJson(Map<String, dynamic> json) {
    return new Quote(
        quoteText: json['quoteText'] as String,
        quoteAuthor: json['quoteAuthor'] as String);
  }
}
