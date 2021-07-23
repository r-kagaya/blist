class Isbn13 {
  Isbn13({this.isbn});

  final String isbn;

  String convertToIsbn10() {
    final _isbn9 = isbn.toString().substring(3, isbn.length - 1);

    var degitCount = 10;
    var _isbn13AllSum = 0;
    _isbn9.runes.forEach((element) {
      final character = new String.fromCharCode(element);
      final code = int.parse(character) * degitCount;
      _isbn13AllSum += code;
      degitCount -= 1;
    });
    final checkDegit = 11 - (_isbn13AllSum % 11);
    return _isbn9 + checkDegit.toString();
  }
}
