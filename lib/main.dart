import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:path_provider/path_provider.dart';

void main() => runApp(new MaterialApp(
    title: 'Quotter', theme: ThemeData.dark(), home: new HomePage()));

const ERROR_LOADING_FILE = "ERROR_LOADING_FILE";

class HomePage extends StatefulWidget {
  final FavQuoteStorage favQuoteStorageUtil = FavQuoteStorage();
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  bool _isFav = false;
  String _currentPageQuote;
  String _currentPageQuoteAuthor;
  int _quoteIndex;
  List<Quote> _quotes;

  // void initState(){
  //   super.initState();
  //   widget.favQuoteStorageUtil.readFavQuotes().
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      //backgroundColor: Colors.white,
      body: new FutureBuilder(
        future: DefaultAssetBundle.of(context).loadString('assets/quotes.json'),
        builder: (context, snapshot) {
          _quotes = parseJson(snapshot.data.toString());
          return _buildQuotesPages();
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.list,
              ),
              //iconSize: 40.0,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FavoriteQuoteScreen()));
              },
            )
          ],
        ),
        shape:
            CircularNotchedRectangle(), // notch for center docked action button
        notchMargin: 10.0,
        //color: Colors.blueGrey,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isFav = !_isFav;
          });
        },
        //backgroundColor: this._isFav ? Colors.white : Color(0xff424242),
        backgroundColor: Color(0xff424242),
        child: Icon(
          Icons.favorite,
          color: this._isFav ? Colors.red : Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
        // save quotes to local file, if fav icon is clicked
        // instead on saving to local file onPressed event of floating action button,
        // it is done here because this avoids the need to delete the written data if user toggles the button again

        if (_isFav) {
          widget.favQuoteStorageUtil
              .writeFavQuotes(_quoteIndex.toString().trim() + ',');
        }

        setState(() {
          _isFav = false;
          _quoteIndex = new Random().nextInt(_quotes.length);
        });
      },
      //pageSnapping: false,
      //itemCount: 3,
    );
  }

  Widget _buildAppBar() {
    return new AppBar(
      centerTitle: true,
      title: Text(
        'Quotter',
        style: new TextStyle(
            //fontStyle: FontStyle.italic,
            color: Colors.yellow,
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'Courgette'
            //color: Colors.red,
            ),
      ),
      //backgroundColor: Colors.transparent,
    );
  }

  Widget _buildQuoteCard() {
    return new Card(
      //color: Colors.red,
      color: Color(0xff212121),
      //margin: EdgeInsets.all(20.0),
      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 60.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          new Container(
            // height: 1000.0,
            // width: 1000.0,
            //padding: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0),
            margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),

            //padding: EdgeInsets.all(0.0),
            //color: Colors.transparent,
            //transform: new Matrix4.rotationZ(0.5),
            child: _buildQuoteText(),
          ),
          // new Container(
          //   margin: EdgeInsets.all(30.0),
          //   child: IconButton(
          //     icon: new Icon(Icons.favorite),
          //     iconSize: 50.0,
          //     color: Colors.yellow,
          //     onPressed: () {},
          //   ),
          // )
        ],
      ),
    );
  }

  Widget _buildQuoteText() {
    if (_quoteIndex == null) _quoteIndex = new Random().nextInt(_quotes.length);
    _currentPageQuote = _quotes[_quoteIndex].quoteText;
    _currentPageQuoteAuthor = "- " + _quotes[_quoteIndex].quoteAuthor;

    return new Column(
      children: <Widget>[
        // Quote Text Container
        new Container(
          margin: EdgeInsets.all(20.0),
          child: Text(
            _currentPageQuote,
            textAlign: TextAlign.justify,
            style: new TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'RobotoSlab',
            ),
          ),
        ),
        // Quote Author Container
        new Container(
          margin: EdgeInsets.all(20.0),
          child: Text(
            _currentPageQuoteAuthor,
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

class FavoriteQuoteScreen extends StatefulWidget {
  final FavQuoteStorage favQuoteStorageUtil = new FavQuoteStorage();
  @override
  State<StatefulWidget> createState() {
    return _FavoriteQuoteScreenState();
  }
}

class _FavoriteQuoteScreenState extends State<FavoriteQuoteScreen> {
  String _favQuotesIndices;
  List<Quote> _quotes;

  @override
  void initState() {
    super.initState();
    widget.favQuoteStorageUtil.readFavQuotes().then((values) {
      setState(() {
        _favQuotesIndices = values;
      });
    }).catchError((err) {
      setState(() {
        _favQuotesIndices = ERROR_LOADING_FILE;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text('Favourite Quotes'),
      ),
      //body: Container(child: Text(this._favQuotesIndices)),
      body: FutureBuilder(
        future: DefaultAssetBundle.of(context).loadString('assets/quotes.json'),
        builder: (context, snapshot) {
          _quotes = parseJson(snapshot.data.toString());
          if (this._favQuotesIndices == ERROR_LOADING_FILE) {
            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              //color: Colors.red,
              color: Color(0xff212121),
              margin: EdgeInsets.all(20.0),
              child: new Container(
                //color: Colors.red,
                margin: EdgeInsets.all(20.0),
                child: Text(
                  "Too bad, you didn't like any of our Quotes. \n Please Favorite few Quotes !!",
                  textAlign: TextAlign.justify,
                  style: new TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'RobotoSlab',
                  ),
                ),
              ),
            );
          }
          return new ListView.builder(
            // length -1 because _favQuotesIndices have a trailing "," appended to it
            itemCount: this._favQuotesIndices.split(",").length - 1,
            itemBuilder: (context, position) {
              List<String> favQuotesIndicesArr =
                  this._favQuotesIndices.split(",");
              // NOTE: listview has items count equal to items in favQuotesIndicesArr
              // for each item in favQuotesIndicesArr, position here is iterator, get the index in which the quote is present in thejson file
              int indexInQuotesJson = int.parse(favQuotesIndicesArr[position]);
              return new Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                //color: Colors.red,
                color: Color(0xff212121),
                margin: EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    // Quote Text Container
                    new Container(
                      //color: Colors.red,
                      margin: EdgeInsets.all(20.0),
                      child: Text(
                        _quotes[indexInQuotesJson].quoteText,
                        textAlign: TextAlign.justify,
                        style: new TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'RobotoSlab',
                        ),
                      ),
                    ),
                    // Quote Author Container
                    new Container(
                      margin: EdgeInsets.all(15.0),
                      child: Text(
                        "- " + _quotes[indexInQuotesJson].quoteAuthor,
                        textAlign: TextAlign.right,
                        style: new TextStyle(
                          color: Colors.yellow,
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Courgette',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow,
        child: Icon(
          Icons.home,
          size: 40.0,
          //color: Color(0xf424242),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}

/***************************
 *  Class to read and write to local storage
 *************************/
class FavQuoteStorage {
  Future<String> get _favFilePath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _favFile async {
    final pathToFile = await _favFilePath;

    var quotesFile = File('$pathToFile/favQuotes4.csv');
    return quotesFile;
  }

  Future<String> readFavQuotes() async {
    try {
      final favFile = await _favFile;
      String contents = await favFile.readAsString();
      return contents;
    } catch (e) {
      return ERROR_LOADING_FILE;
    }
  }

  Future<File> writeFavQuotes(String contents) async {
    final favFile = await _favFile;
    return favFile.writeAsString('$contents', mode: FileMode.append);
  }
}

/***********************************
UTILITY FOR PARSING JSON QUOTES
 **********************************/
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
