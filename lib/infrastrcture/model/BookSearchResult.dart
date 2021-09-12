import 'package:blist/model/book.dart';

class BookSearchResult {
  final String title;
  final String author;
  final String subTitle;
  final String itemCaption;
  final String publisherName;
  final String reviewAverage;
  final int itemPrice;
  final String salesDate;
  final String largeImageUrl;
  final String isbn;
  final String itemUrl;

  BookSearchResult(
    this.title,
    this.author,
    this.subTitle,
    this.itemCaption,
    this.reviewAverage,
    this.publisherName,
    this.itemPrice,
    this.salesDate,
    this.largeImageUrl,
    this.isbn,
    this.itemUrl,
  );

  BookSearchResult.fromJson(Map<String, dynamic> json)
      : title = json["Items"][0]["Item"]["title"],
        author = json["Items"][0]["Item"]["author"],
        itemCaption = json["Items"][0]["Item"]["itemCaption"],
        publisherName = json["Items"][0]["Item"]["publisherName"],
        reviewAverage = json["Items"][0]["Item"]["reviewAverage"],
        itemPrice = json["Items"][0]["Item"]["itemPrice"],
        salesDate = json["Items"][0]["Item"]["salesDate"],
        largeImageUrl = json["Items"][0]["Item"]["largeImageUrl"],
        isbn = json["Items"][0]["Item"]["isbn"],
        itemUrl = json["Items"][0]["Item"]["itemUrl"],
        subTitle = json["Items"][0]["Item"]["subTitle"];

  Map<String, dynamic> toJson() => {
        "title": title,
        "author": author,
        "subTitle": subTitle,
        "itemCaption": itemCaption,
        "publisherName": publisherName,
        "reviewAverage": reviewAverage,
        "itemPrice": itemPrice,
        "salesDate": salesDate,
        "largeImageUrl": largeImageUrl,
        "isbn": isbn,
        "itemUrl": itemUrl
      };

  Book toBook() => Book(
        title: title,
        author: author,
        subTitle: subTitle,
        itemCaption: itemCaption,
        reviewAverage: reviewAverage,
        publisherName: publisherName,
        itemPrice: itemPrice,
        salesDate: salesDate,
        largeImageUrl: largeImageUrl,
        isbn: int.parse(isbn),
        itemUrl: itemUrl,
      );
}
