import 'dart:async';
import 'dart:io';

import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

List<String> cityUrls = <String>[
  "https://atlanta.craigslist.org/",
  "https://austin.craigslist.org/",
  "https://boston.craigslist.org/",
  "https://chicago.craigslist.org/",
  "https://dallas.craigslist.org/",
  "https://denver.craigslist.org/",
  "https://detroit.craigslist.org/",
  "https://houston.craigslist.org/",
  "https://lasvegas.craigslist.org/",
  "https://losangeles.craigslist.org/",
  "https://miami.craigslist.org/",
  "https://minneapolis.craigslist.org/",
  "https://newyork.craigslist.org/",
  "https://orangecounty.craigslist.org/",
  "https://philadelphia.craigslist.org/",
  "https://phoenix.craigslist.org/",
  "https://portland.craigslist.org/",
  "https://raleigh.craigslist.org/",
  "https://sacramento.craigslist.org/",
  "https://sandiego.craigslist.org/",
  "https://seattle.craigslist.org/",
  "https://sfbay.craigslist.org/",
  "https://washingtondc.craigslist.org/",
];

class Gig {
  final String title;
  final String description;
  final String url;
  final String city;
  final String posted;
  final String id;

  Gig(
      {@required id,
      @required this.title,
      @required this.description,
      @required this.url,
      @required this.city,
      @required this.posted});

  @override
  String toString() {
    return """Title: ${title}
Posted: ${posted}
Description: ${description}
City: ${city}
Link: ${url}
-----------------------------""";
  }
}

main(List<String> arguments) async {
  bool printOut = true;

  List<Gig> gigs = new List<Gig>();
  for (String cityUrl in cityUrls) {
    gigs.addAll(await getGigs(
        "${cityUrl}search/ggg?query=developer&is_paid=all",
        printToStdOut: printOut));
  }

  String gigString = "";
  gigs.forEach((Gig gig) => gigString = "${gigString}\n${gig}");
  String fileName = "${nowString}.txt";
  print("Writing ${gigs.length} Gigs to ${fileName}");
  File(fileName).writeAsString(gigString);
}

String get nowString =>
    "${DateTime.now().toString().replaceAll(" ", "-").replaceAll(":", "-")}";

Future<List<Gig>> getGigs(String citySearchUrl,
    {bool printToStdOut: false}) async {
  http.Response response = await http.get(citySearchUrl);
  Document searchPage = new Document.html(response.body);
  List<Element> anchorElements = searchPage.querySelectorAll("a.result-title");
  List<Future<Gig>> futureGigs = new List<Future<Gig>>();

  for (Element anchorElement in anchorElements) {
    String gigUrl = anchorElement.attributes["href"];
    futureGigs.add(getGig(gigUrl, printToStdOut: printToStdOut));
  }

  Set<String> gigIds = new Set<String>();
  List<Gig> gigs = new List<Gig>.from(await Future.wait(futureGigs));
  gigs.removeWhere((Gig gig) {
    if (gigIds.contains(gig.id)) {
      return true;
    } else {
      gigIds.add(gig.id);
      return false;
    }
  });

  return gigs;
}

Future<Gig> getGig(String gigUrl, {bool printToStdOut: false}) async {
  http.Response response = await http.get(gigUrl);
  Document gigPage = new Document.html(response.body);
  gigPage
      .querySelector("div.print-information.print-qrcode-container")
      .remove();

  String id = Uri.parse(gigUrl).pathSegments.last.split(".")[0];
  String city = capitalize(gigUrl.substring(8, gigUrl.indexOf(".")));
  String link = gigUrl;
  String posted = gigPage.querySelector("time.date.timeago").innerHtml.trim();
  String title = gigPage.querySelector("span#titletextonly").innerHtml;
  String description =
      extractText(gigPage.querySelector("section#postingbody").innerHtml);

  Gig gig = new Gig(
      id: id,
      title: title,
      url: link,
      city: city,
      description: description,
      posted: posted);
  if (printToStdOut) print("${gig}\n");
  return gig;
}

String capitalize(String input) {
  String value = input;

  if (input != null && input.length > 0) {
    if (input.length > 1) {
      value = "${input[0].toUpperCase()}${input.substring(1)}";
    } else {
      value = "${input[0]}";
    }
  }

  return value;
}

String extractText(String innerHtml) {
  String text = innerHtml;

  text = text.trim();
  text = text.replaceAll("<br>", "");

  return text;
}
