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
  final ReadingStatus readingStatus;

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
    this.readingStatus = ReadingStatus.UNREAD,
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
      "itemUrl": itemUrl,
      "readingStatus": readingStatus.value
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
        'itemUrl: $itemUrl, '
        'readingStatus: ${readingStatus.value}'
        '}';
  }

  ReadingStatus of(int value) {
    switch (value) {
      case 0:
        return ReadingStatus.UNREAD;
        break;
      case 1:
        return ReadingStatus.READED;
        break;
    }
  }
}

enum ReadingStatus {
  UNREAD,
  READED,
}

extension ReadingStatusExt on ReadingStatus {
  int get value {
    switch (this) {
      case ReadingStatus.UNREAD:
        return 0;
        break;
      case ReadingStatus.READED:
        return 1;
        break;
    }
  }

  static ReadingStatus of(int value) {
    switch (value) {
      case 0:
        return ReadingStatus.UNREAD;
        break;
      case 1:
        return ReadingStatus.READED;
        break;
      default:
        return ReadingStatus.UNREAD;
    }
  }
}
