class Book {
  final int isbn;
  final String title;
  final String author;
  final String subTitle;
  final String itemCaption;
  final String publisherName;
  final String reviewAverage;
  final int itemPrice;
  final String salesDate;
  final String largeImageUrl;
  final String itemUrl;

  Book({
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
  });

  Map<String, dynamic> toMap() {
    return {
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
  }

  @override
  String toString() {
    return 'Book{'
        'isbn: $isbn, '
        'title: $title, '
        'author: $author, '
        'subTitle: $subTitle, '
        'itemCaption: $itemCaption, '
        'publisherName: $publisherName, '
        'reviewAverage: $reviewAverage, '
        'itemPrice: $itemPrice, '
        'salesDate: $salesDate, '
        'largeImageUrl: $largeImageUrl, '
        'itemUrl: $itemUrl'
        '}';
  }
}
