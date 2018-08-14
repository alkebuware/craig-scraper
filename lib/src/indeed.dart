import 'dart:async';

import 'package:craig_scraper/src/gig.dart';
import 'package:craig_scraper/src/scrapable.dart';
import 'package:html/dom.dart';
import 'package:http/http.dart' as http;

List<String> searchUrls = <String>[
  "https://www.indeed.com/jobs?as_and=freelance+developer&as_phr=&as_any=&as_not=&as_ttl=&as_cmp=&jt=parttime&st=&salary=&radius=25&l=&fromage=1&limit=50&sort=date&psf=advsrch"
];

class Indeed extends ScrapableSite {
  Indeed({bool postedToday = false})
      : super(
            searchUrls.map((String cityUrl) => new SiteUrl(cityUrl)).toList());

  @override
  Future<Gig> extractGig(Uri gigUri) async {
    http.Response response = await http.get(gigUri);
    Document gigPage = new Document.html(response.body);

    String id = extractGigId(gigUri);
    String city = extractGigCity(gigPage);
    String link = gigUri.toString();
    String posted = extractGigPostedTime(gigPage);
    String title = extractGigTitle(gigPage);
    String description = extractGigDescription(gigPage);

    if (title == null) throw "Can't find Title in:\n${gigPage.outerHtml}";
    if (id == null) throw "Can't find ID in:\n${gigUri}\n${gigPage.outerHtml}";
    if (posted == null)
      throw "Can't find Posted in:\n${gigUri}\n${gigPage.outerHtml}";
    if (city == null)
      throw "Can't find city in:\n${gigUri}\n${gigPage.outerHtml}";
    if (description == null)
      throw "Can't find description in:\n${gigUri}\n${gigPage.outerHtml}";

    return new Gig(
        id: id,
        title: title,
        url: link,
        city: city,
        description: description,
        posted: posted);
  }

  String extractGigId(Uri gigUri) {
    return gigUri.pathSegments.last.split("-").last;
  }

  String extractGigTitle(Document gigPage) {
    String title = gigPage.querySelector(".icl-JobResult-jobLink")?.innerHtml;
    if (title != null) return title;

    title = gigPage.querySelector(".jobsearch-JobInfoHeader-title")?.innerHtml;
    if (title != null) return title;

    title = gigPage.querySelector(".jobtitle").querySelector("font").innerHtml;
    if (title != null) return title;

    return null;
  }

  @override
  Future<List<Uri>> getGigUris(String gigListingsUrl) async {
    Uri gigListingsUri = Uri.parse(gigListingsUrl);
    http.Response response = await http.get(gigListingsUrl);
    Document searchPage = new Document.html(response.body);
    List<Element> anchorElements =
        searchPage.querySelectorAll("h2 > a.turnstileLink");

    dynamic list = anchorElements
        .map((Element anchorElement) =>
            Uri.parse(anchorElement.attributes["href"]).replace(
                scheme: gigListingsUri.scheme, host: gigListingsUri.host))
        .toList();
    return list;
  }

  @override
  Future<bool> siteHasNextUrl(String siteUrl) async {
    http.Response response = await http.get(siteUrl);
    Document gigListingsPage = new Document.html(response.body);

    Element nextDiv = gigListingsPage.querySelector(".pagination");

    return nextDiv?.innerHtml?.contains("Next") == true;
  }

  @override
  Future<String> siteNextUrl(String siteUrl) async {
    Uri siteUri = Uri.parse(siteUrl);
    http.Response response = await http.get(siteUrl);
    Document gigListingsPage = new Document.html(response.body);

    Element nextAnchor =
        gigListingsPage.querySelectorAll("div.pagination > a").last;

    String nextUri = Uri.parse(nextAnchor.attributes["href"])
        .replace(scheme: siteUri.scheme, host: siteUri.host)
        .toString();
    return nextUri;
  }

  String extractGigDescription(Document gigPage) {
    String description = gigPage.querySelector(".summary")?.innerHtml;

    description = description ??
        gigPage.querySelector(".jobsearch-JobComponent-description")?.innerHtml;

    if (description != null) {
      description = description
          .replaceAll("<ul>", "")
          .replaceAll("</ul>", "")
          .replaceAll("<li>", "")
          .replaceAll("</li>", "\n")
          .replaceAll("<p>", "")
          .replaceAll("</p>", "\n")
          .replaceAll("<br>", "\n")
          .replaceAll("<b>", "")
          .replaceAll("</b>", "")
          .replaceAll("<div>", "")
          .replaceAll("</div>", "");
    }

    return description;
  }

  String extractGigPostedTime(Document gigPage) {
    String posted = gigPage.querySelector("span.date")?.innerHtml;
    if (posted != null) return posted;

    String innerHtml =
        gigPage.querySelector(".jobsearch-JobMetadataFooter")?.innerHtml;

    if (innerHtml != null) {
      posted = innerHtml.substring(0, innerHtml.indexOf("<"));
    }

    return posted;
  }

  String extractGigCity(Document gigPage) {
//    jobsearch-InlineCompanyRating
    String city = gigPage.querySelector("icl-JobResult-jobLocation")?.innerHtml;
    if (city != null) return city;

    city = gigPage
        .querySelector(".jobsearch-InlineCompanyRating")
        ?.querySelectorAll("div")
        ?.last
        ?.innerHtml;
    if (city != null) return city;

    city = gigPage.querySelector(".location")?.innerHtml;
    if (city != null) return city;

    city = gigPage
        .querySelector(".jobsearch-JobInfoHeader-companyLocation > span")
        .innerHtml;
    if (city != null) return city;

    return city;
  }
}
