import 'package:blist/component/EmptyView.dart';
import 'package:blist/component/Toaster.dart';
import 'package:blist/domain/book.dart';
import 'package:blist/infrastrcture/BookSearchRepository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'book_detail.dart';

class ListPage extends StatefulWidget {
  ListPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final List<Book> listItems = [];
  var database;

  Future fetchBookList() async {
    EasyLoading.show(status: 'loading...');
    new Future.delayed(
      new Duration(seconds: 1),
    ).then(
      (_) => EasyLoading.dismiss(),
    );

    database = await openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'blist_database.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          'CREATE TABLE books('
          'isbn INTEGER PRIMARY KEY, '
          'title TEXT, '
          'author TEXT, '
          'subTitle TEXT, '
          'itemCaption TEXT, '
          'publisherName TEXT, '
          'reviewAverage TEXT, '
          'itemPrice INTEGER, '
          'salesDate TEXT, '
          'largeImageUrl TEXT, '
          'itemUrl TEXT'
          ')',
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
    final List<Map<String, dynamic>> maps = await database.query('books');
    listItems.clear();
    List.generate(maps.length, (i) {
      listItems.add(Book(
          isbn: maps[i]["isbn"],
          title: maps[i]["title"],
          author: maps[i]["author"],
          subTitle: maps[i]["subTitle"],
          itemCaption: maps[i]["itemCaption"],
          reviewAverage: maps[i]["reviewAverage"],
          publisherName: maps[i]["publisherName"],
          itemPrice: maps[i]["itemPrice"],
          salesDate: maps[i]["salesDate"],
          largeImageUrl: maps[i]["largeImageUrl"],
          itemUrl: maps[i]["itemUrl"]));
    });
    listItems.reversed.toList();
  }

  // Define a function that inserts dogs into the database
  Future<void> insertBook(Book book, BuildContext context) async {
    final db = await database;

    if (listItems.where((i) => i.isbn == book.isbn).isNotEmpty) {
      Toaster.show("既に存在しています");
    } else {
      await db.insert(
        'books',
        book.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: fetchBookList(),
        builder: (BuildContext context, snapshot) {
          return Center(
            child: listItems.isNotEmpty
                ? ListView.builder(
                    itemCount: listItems.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          leading: Icon(Icons.book),
                          minLeadingWidth: 20.0,
                          title: Text(listItems[index].title),
                          trailing: IconButton(
                            icon: Icon(Icons.more_vert),
                            onPressed: () async {
                              _showOptionDialog(listItems[index], context);
                            },
                          ),
                          subtitle: Text(listItems[index].author),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookDetail(
                                  book: listItems[index],
                                ),
                              ),
                            );
                          },
                          isThreeLine: true,
                        ),
                      );
                    },
                  )
                : EmptyView(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _scanQrCode(context),
        tooltip: "Add",
        child: Icon(Icons.add),
      ),
    );
  }

  Future _scanQrCode(BuildContext context) async {
    final isbn = await FlutterBarcodeScanner.scanBarcode(
      '#EB394B',
      'Cancel',
      true,
      ScanMode.QR,
    );
    if (!mounted || isbn == "-1") return;

    try {
      final bookSearchResult = await BookSearchRepository.fetch(
        int.parse(isbn),
      );

      setState(() {
        insertBook(bookSearchResult.toBook(), context);
      });
    } catch (e) {
      _showInvalidIsbnDialog(context);
    }
  }

  _deleteBook(int isbn) async {
    setState(() {
      database.delete('books', where: 'isbn = ?', whereArgs: [isbn]);
    });
  }

  _showOptionDialog(Book book, BuildContext context) async {
    await showDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () => {
                _deleteBook(book.isbn),
                Navigator.pop(context, 1),
              },
              child: const Text(
                '削除',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  _showInvalidIsbnDialog(BuildContext context) async {
    Toaster.show("ISBN番号ではありません");
  }
}
