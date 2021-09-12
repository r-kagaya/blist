import 'package:blist/lib/Isbn.dart';
import 'package:blist/model/book.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class BookDetail extends StatefulWidget {
  BookDetail({Key key, this.book}) : super(key: key);

  final Book book;

  @override
  _BookDetailState createState() => _BookDetailState();
}

class _BookDetailState extends State<BookDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          alignment: Alignment.centerLeft,
          fit: BoxFit.fitWidth,
          child: Text(
            widget.book.title,
            textAlign: TextAlign.left,
          ),
        ),
      ),
      body: Center(
        child: ListView(
          children: [
            Padding(padding: EdgeInsets.only(top: 10)),
            Image.network(
              widget.book.largeImageUrl,
              fit: BoxFit.fitHeight,
              filterQuality: FilterQuality.high,
              height: 150,
            ),
            Padding(padding: EdgeInsets.only(top: 15)),
            _buildTitleColumn(),
            Padding(padding: EdgeInsets.only(top: 10)),
            _buildAuthorColumn(),
            Padding(padding: EdgeInsets.only(top: 10)),
            _buildDescriptionColumn(),
            Padding(padding: EdgeInsets.only(top: 10)),
            _buildPublisherColumn(),
            _buildOptionRow(),
            Padding(padding: EdgeInsets.only(top: 10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  child: FaIcon(
                    FontAwesomeIcons.amazon,
                    color: Colors.black,
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.amberAccent,
                    onPrimary: Color.fromRGBO(191, 0, 0, 1.0),
                    shape: const CircleBorder(
                        side: BorderSide(style: BorderStyle.none)),
                    fixedSize: Size(65, 65),
                  ),
                  onPressed: () {
                    var url =
                        "http://www.amazon.co.jp/dp/${Isbn13(isbn: widget.book.isbn.toString()).convertToIsbn10()}";
                    _launchURL(url);
                  },
                ),
                ElevatedButton(
                  child: FaIcon(
                    FontAwesomeIcons.yahoo,
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.redAccent,
                    shape: const CircleBorder(
                        side: BorderSide(style: BorderStyle.none)),
                    fixedSize: Size(65, 65),
                  ),
                  onPressed: () {
                    _launchURL(
                        "https://shopping.yahoo.co.jp/search?first=&p=${widget.book.isbn.toString()}");
                  },
                ),
                ElevatedButton(
                  child: const Text(
                    'R',
                    style: TextStyle(
                      fontSize: 26,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Color.fromRGBO(191, 0, 0, 1.0),
                    shape: const CircleBorder(
                        side: BorderSide(style: BorderStyle.none)),
                    fixedSize: Size(65, 65),
                  ),
                  onPressed: () {
                    _launchURL(widget.book.itemUrl);
                  },
                ),
              ],
            ),
            Padding(padding: EdgeInsets.only(bottom: 20)),
          ],
        ),
      ),
    );
  }

  _showOpenDialog() async {
    await showDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Open By'),
          backgroundColor: Colors.white,
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () => {
                _launchURL(
                    "http://www.amazon.co.jp/dp/${Isbn13(isbn: widget.book.isbn.toString()).convertToIsbn10()}")
              },
              child: const Text(
                'Amazon',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => {
                _launchURL(
                    "https://shopping.yahoo.co.jp/search?first=&p=${widget.book.isbn.toString()}")
              },
              child: const Text(
                'Yahoo',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => {_launchURL(widget.book.itemUrl)},
              child: const Text(
                'Rakuten',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTitleColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            "title",
            style: Theme.of(context).textTheme.subtitle2,
          ),
        ),
        Card(
          child: ListTile(
            title: Text(
              widget.book.title,
            ),
            subtitle: Text(widget.book.subTitle),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthorColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            "author",
            style: Theme.of(context).textTheme.subtitle2,
          ),
        ),
        Card(
          child: ListTile(
            title: Text(
              widget.book.author,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            "description",
            style: Theme.of(context).textTheme.subtitle2,
          ),
        ),
        Card(
          child: ListTile(
            title: Text(
              widget.book.itemCaption,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPublisherColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            "publisher",
            style: Theme.of(context).textTheme.subtitle2,
          ),
        ),
        Card(
          child: ListTile(
            title: Text(
              widget.book.publisherName,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildOptionRow() {
    final descTextStyle = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w900,
      letterSpacing: 0.5,
      fontSize: 16,
      height: 2,
    );

    return Card(
      child: DefaultTextStyle.merge(
        style: descTextStyle,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Icon(Icons.money, color: Colors.indigo),
                  Text(
                    'price',
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  Text(widget.book.itemPrice.toString() + "円"),
                ],
              ),
              Column(
                children: [
                  Icon(Icons.date_range, color: Colors.blue[500]),
                  Text(
                    'date',
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  Text(widget.book.salesDate),
                ],
              ),
              Column(
                children: [
                  // @see https://api.flutter.dev/flutter/material/Icons-class.html
                  Icon(Icons.star, color: Colors.yellow[500]),
                  Text(
                    'review',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  Text(widget.book.reviewAverage),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
