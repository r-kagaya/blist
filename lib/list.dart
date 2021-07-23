import 'package:blist/component/EmptyView.dart';
import 'package:blist/infrastrcture/BookSearchRepository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:localstorage/localstorage.dart';

import 'book_detail.dart';

class ListPage extends StatefulWidget {
  ListPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final listItems = [];
  final LocalStorage storage = new LocalStorage('book_list');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
          future: storage.ready,
          builder: (BuildContext context, snapshot) {
            if (snapshot.data == true) {
              Map<String, dynamic> bookList = storage.getItem('book_list');
              print(bookList);

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
                                  _showOptionDialog(index);
                                },
                              ),
                              subtitle: Text(listItems[index].author),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        BookDetail(book: listItems[index]),
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
            } else {
              return Center(child: EmptyView());
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _scanQrCode(),
        tooltip: "Add",
        child: Icon(Icons.add),
      ),
    );
  }

  Future _scanQrCode() async {
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
        listItems.add(
          bookSearchResult.toBook(),
        );
      });
    } catch (e) {
      print(e.toString());
      _showInvalidIsbnDialog();
    }
  }

  _deleteBook(int index) async {
    setState(() {
      listItems.removeAt(index);
    });
  }

  _showOptionDialog(int index) async {
    await showDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
//          title: Text('オプション'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () => {
                _deleteBook(index),
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

  _showInvalidIsbnDialog() async {
    await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("エラー"),
          content: Text("ISBN番号ではありません"),
          actions: [
            FlatButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(1),
            ),
          ],
        );
      },
    );
  }
}
