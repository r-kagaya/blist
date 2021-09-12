import 'package:blist/component/BookListTile.dart';
import 'package:blist/component/EmptyView.dart';
import 'package:blist/component/Toaster.dart';
import 'package:blist/infrastrcture/BookSearchRepository.dart';
import 'package:blist/model/book.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ListPage extends StatefulWidget {
  ListPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final List<Book> listItems = [];
  final List<Book> unreadItems = [];
  final List<Book> readedItems = [];

  Database database;

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
          'itemUrl TEXT, '
          'readingStatus INTEGER'
          ')',
        );
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        const scripts = {
          '2': ["ALTER TABLE books ADD COLUMN readingStatus INTEGER DEFAULT 0;"]
        };

        for (var i = oldVersion + 1; i <= newVersion; i++) {
          var queries = scripts[i.toString()];
          for (String query in queries) {
            await db.execute(query);
          }
        }
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 2,
    );
    final List<Map<String, dynamic>> maps = await database.query('books');

    listItems.clear();
    unreadItems.clear();
    readedItems.clear();

    List.generate(
      maps.length,
      (i) {
        final book = Book(
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
          itemUrl: maps[i]["itemUrl"],
          readingStatus: ReadingStatusExt.of(maps[i]["readingStatus"]),
        );

        listItems.add(book);
        if (book.readingStatus == ReadingStatus.UNREAD) unreadItems.add(book);
        if (book.readingStatus == ReadingStatus.READED) readedItems.add(book);
      },
    );
    listItems.reversed.toList();
    unreadItems.reversed.toList();
    readedItems.reversed.toList();
  }

  // Define a function that inserts dogs into the database
  Future<void> insertBook(Book book, BuildContext context) async {
    if (listItems.where((i) => i.isbn == book.isbn).isNotEmpty) {
      Toaster.show("既に存在しています");
    } else {
      await database.insert(
        'books',
        book.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget Function(int length, int index) spaceContainerBottomOfList =
        (int length, int i) {
      if (length == (i + 1)) {
        return Container(
          height: 30,
          color: Colors.transparent,
        );
      }
      return Container();
    };

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
          ),
        ),
        body: Column(
          children: [
            Container(
              height: 50,
              color: Colors.white,
//              decoration: BoxDecoration(
//                gradient: LinearGradient(
//                  colors: [
//                    Colors.white,
//                    Colors.white,
//                    Theme.of(context).primaryColor,
//                    Theme.of(context).primaryColor,
//                    Colors.purpleAccent,
//                    Colors.purple
//                  ],
//                ),
//              ),
              child: TabBar(
                labelStyle: TextStyle(
                  color: Colors.black,
                ),
                labelColor: Colors.blue,
                tabs: <Widget>[
                  Tab(
                    child: Text(
                      "All",
                      style: TextStyle(color: Colors.black, fontSize: 14.0),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "Unread",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "Readed",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            FutureBuilder(
              future: fetchBookList(),
              builder: (BuildContext context, snapshot) {
                return Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: TabBarView(
                          children: [
                            Center(
                              child: listItems.isNotEmpty
                                  ? ListView.builder(
                                      padding: EdgeInsets.only(
                                        top: 5,
                                        bottom: 5,
                                      ),
                                      itemCount: listItems.length,
                                      itemBuilder: (context, index) {
                                        final bookListTileWidget = BookListTile(
                                          items: listItems[index],
                                          trailingIconButton: IconButton(
                                            icon: Icon(Icons.more_vert),
                                            onPressed: () async {
                                              _showOptionDialog(
                                                listItems[index],
                                                context,
                                              );
                                            },
                                          ),
                                        );

                                        return Column(
                                          children: [
                                            bookListTileWidget,
                                            spaceContainerBottomOfList(
                                                listItems.length, index)
                                          ],
                                        );
                                      },
                                    )
                                  : EmptyView(),
                            ),
                            Center(
                              child: unreadItems.isNotEmpty
                                  ? ListView.builder(
                                      padding: EdgeInsets.only(
                                        top: 5,
                                        bottom: 5,
                                      ),
                                      itemCount: unreadItems.length,
                                      itemBuilder: (context, index) {
                                        final bookListTileWidget = BookListTile(
                                          items: unreadItems[index],
                                          trailingIconButton: IconButton(
                                            icon: Icon(Icons.more_vert),
                                            onPressed: () async {
                                              _showOptionDialog(
                                                unreadItems[index],
                                                context,
                                              );
                                            },
                                          ),
                                        );

                                        return Column(
                                          children: [
                                            bookListTileWidget,
                                            spaceContainerBottomOfList(
                                                unreadItems.length, index)
                                          ],
                                        );
                                      },
                                    )
                                  : EmptyView(),
                            ),
                            Center(
                              child: readedItems.isNotEmpty
                                  ? ListView.builder(
                                      padding: EdgeInsets.only(
                                        top: 5,
                                        bottom: 5,
                                      ),
                                      itemCount: readedItems.length,
                                      itemBuilder: (context, index) {
                                        final bookListTileWidget = BookListTile(
                                          items: readedItems[index],
                                          trailingIconButton: IconButton(
                                            icon: Icon(Icons.more_vert),
                                            onPressed: () async {
                                              _showOptionDialog(
                                                readedItems[index],
                                                context,
                                              );
                                            },
                                          ),
                                        );

                                        return Column(
                                          children: [
                                            bookListTileWidget,
                                            spaceContainerBottomOfList(
                                                readedItems.length, index)
                                          ],
                                        );
                                      },
                                    )
                                  : EmptyView(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () => _scanQrCode(context),
          tooltip: "Add",
          child: Icon(Icons.add),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Theme.of(context).primaryColor,
          notchMargin: 6.0,
          shape: AutomaticNotchedShape(
            RoundedRectangleBorder(),
            StadiumBorder(
              side: BorderSide(),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: new Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  height: 60.0,
                ),
//                IconButton(
//                  icon: Icon(
//                    Icons.person_outline,
//                    color: Colors.white,
//                  ),
//                  iconSize: 36.0,
//                  onPressed: () {},
//                ),
//                IconButton(
//                  icon: Icon(
//                    Icons.person_outline,
//                    color: Colors.white,
//                  ),
//                  iconSize: 32.0,
//                  onPressed: () {},
//                ),
              ],
            ),
          ),
        ),
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
    showMaterialModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 120,
        child: Column(
          children: [
            if (book.readingStatus == ReadingStatus.READED)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: TextButton(
                    onPressed: () {
                      print("mark as unreaded");
                      var values = <String, dynamic>{
                        "readingStatus": ReadingStatus.UNREAD.value
                      };
                      database.update(
                        'books',
                        values,
                        where: "isbn = ?",
                        whereArgs: [book.isbn],
                        conflictAlgorithm: ConflictAlgorithm.fail,
                      );
                      setState(() {
                        fetchBookList();
                      });
                      Navigator.pop(context, 1);
                    },
                    style: TextButton.styleFrom(
                      primary: Colors.black,
                    ),
                    child: const Text(
                      'Mark as Unread',
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ),
            if (book.readingStatus == ReadingStatus.UNREAD)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: TextButton(
                    onPressed: () {
                      print("mark as readed");
                      var values = <String, dynamic>{
                        "readingStatus": ReadingStatus.READED.value
                      };
                      database.update(
                        'books',
                        values,
                        where: "isbn = ?",
                        whereArgs: [book.isbn],
                        conflictAlgorithm: ConflictAlgorithm.fail,
                      );
                      setState(() {
                        fetchBookList();
                      });
                      Navigator.pop(context, 1);
                    },
                    style: TextButton.styleFrom(
                      primary: Colors.black,
                    ),
                    child: const Text(
                      'Mark as Readed',
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: TextButton(
                  onPressed: () {
                    _deleteBook(book.isbn);
                    Navigator.pop(context, 1);
                  },
                  style: TextButton.styleFrom(
                    primary: Colors.black,
                  ),
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _showInvalidIsbnDialog(BuildContext context) async {
    Toaster.show("ISBN番号ではありません");
  }
}
