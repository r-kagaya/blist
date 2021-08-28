import 'package:blist/book_detail.dart';
import 'package:blist/domain/book.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BookListTile extends StatelessWidget {
  BookListTile({@required this.items, @required this.trailingIconButton});

  final Book items;
  final IconButton trailingIconButton;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: ListTile(
        leading: Icon(Icons.book),
        minLeadingWidth: 20.0,
        title: Text(items.title),
        trailing: this.trailingIconButton,
        subtitle: Text(items.author),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetail(
                book: items,
              ),
            ),
          );
        },
        isThreeLine: true,
      ),
    );
  }
}
