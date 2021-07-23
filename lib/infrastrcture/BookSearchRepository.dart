import 'dart:convert';

import 'package:blist/infrastrcture/model/BookSearchResult.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class BookSearchRepository {
  static Future<BookSearchResult> fetch(int isbn) async {
    final applicationId = dotenv.env["RAKUTEN_APPLICATION_ID"];
    print(applicationId);
    final result = await http
        .get(
          Uri.parse(
              "https://app.rakuten.co.jp/services/api/BooksBook/Search/20170404?format=json&isbn=$isbn&applicationId=$applicationId"),
//        headers: {}
        )
        .then(
          (value) => {
            BookSearchResult.fromJson(
              json.decode(value.body),
            )
          },
        )
        .catchError(
      (err) {
        print(err);
        throw Exception();
      },
    );
    return result.single;
  }
}
