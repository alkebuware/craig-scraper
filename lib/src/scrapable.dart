import 'dart:async';

import 'package:craig_scraper/src/gig.dart';
import 'package:meta/meta.dart';

abstract class ScrapableSite {
  final List<SiteUrl> siteUrls;

  ScrapableSite(this.siteUrls);

  Future<String> siteNextUrl(String siteUrl);

  Future<bool> siteHasNextUrl(String siteUrl);

  Future<List<Uri>> getGigUris(String gigListingsUrl);

  Future<Gig> extractGig(Uri gigUri);

  @protected
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

  @protected
  String extractText(String innerHtml) {
    String text = innerHtml;

    text = text.trim();
    text = text.replaceAll("<br>", "");

    return text;
  }
}

class SiteUrl {
  final Uri _uri;

  String get url => _uri.toString();

  SiteUrl(String url) : _uri = Uri.parse(url);

  static List<SiteUrl> fromList(List<String> list) {
    return list.map((String url) => SiteUrl(url)).toList();
  }

  @override
  String toString() {
    return _uri.toString();
  }
}
