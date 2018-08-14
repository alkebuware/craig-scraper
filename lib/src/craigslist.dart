import 'dart:async';

import 'package:craig_scraper/src/gig.dart';
import 'package:craig_scraper/src/scrapable.dart';
import 'package:html/dom.dart';
import 'package:http/http.dart' as http;

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

class CraigsList extends ScrapableSite {
  CraigsList({bool postedToday = false})
      : super(cityUrls
            .map((String cityUrl) => new SiteUrl(
                "${cityUrl}search/ggg?query=developer&is_paid=all${(postedToday) ? "&postedToday=1" : ""}"))
            .toList());

  @override
  Future<Gig> extractGig(Uri gigUri) async {
    http.Response response = await http.get(gigUri);
    Document gigPage = new Document.html(response.body);
    gigPage
        .querySelector("div.print-information.print-qrcode-container")
        .remove();

    String id = gigUri.pathSegments.last.split(".")[0];
    String city = capitalize(
        gigUri.toString().substring(8, gigUri.toString().indexOf(".")));
    String link = gigUri.toString();
    String posted = gigPage.querySelector("time.date.timeago").innerHtml.trim();
    String title = gigPage.querySelector("span#titletextonly").innerHtml;
    String description =
        extractText(gigPage.querySelector("section#postingbody").innerHtml);

    return new Gig(
        id: id,
        title: title,
        url: link,
        city: city,
        description: description,
        posted: posted);
  }

  @override
  Future<List<Uri>> getGigUris(String gigListingsUrl) async {
    http.Response response = await http.get(gigListingsUrl);
    Document searchPage = new Document.html(response.body);
    List<Element> anchorElements =
        searchPage.querySelectorAll("a.result-title");

    dynamic list = anchorElements
        .map((Element anchorElement) =>
            Uri.parse(anchorElement.attributes["href"]))
        .toList();
    return list;
  }

  @override
  Future<bool> siteHasNextUrl(String siteUrl) async {
    http.Response response = await http.get(siteUrl);
    Document gigListingsPage = new Document.html(response.body);

    Element nextAnchor = gigListingsPage.querySelector("a.button.next");
    Map<dynamic, String> attributes = nextAnchor?.attributes;

    if (attributes == null) {
      return false;
    } else {
      return attributes["href"] != null;
    }
  }

  @override
  Future<String> siteNextUrl(String siteUrl) async {
    http.Response response = await http.get(siteUrl);
    Document gigListingsPage = new Document.html(response.body);

    Element nextAnchor = gigListingsPage.querySelector("a.button.next");

    return Uri.parse(siteUrl)
        .replace(path: nextAnchor.attributes["href"])
        .toString();
  }
}
