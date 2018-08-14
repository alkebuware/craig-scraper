import 'package:meta/meta.dart';

class Gig {
  final String title;
  final String description;
  final String url;
  final String city;
  final String posted;
  final String id;

  Gig(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.url,
      @required this.city,
      @required this.posted});

  @override
  String toString() {
    return """Title: ${title}
Posted: ${posted}
City: ${city}
Link: ${url}
Description: ${description}
-----------------------------""";
  }
}
