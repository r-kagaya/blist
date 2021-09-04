import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            color: Colors.blueAccent,
            size: 80,
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
          ),
          Text(
            "No book list yet",
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }
}
