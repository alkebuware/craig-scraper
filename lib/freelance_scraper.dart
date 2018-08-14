import 'dart:async';

import 'package:craig_scraper/src/gig.dart';
import 'package:craig_scraper/src/scrapable.dart';

export 'src/craigslist.dart';
export 'src/gig.dart';

class ScrapeResults {
  List<Gig> gigs;
  int duplicatesRemoved;
}

Future<ScrapeResults> ScrapeSite(ScrapableSite site) async {
  List<Future<Gig>> futureScrapedGigs = new List<Future<Gig>>();

  for (SiteUrl siteUrl in site.siteUrls) {
    String currentPage = siteUrl.url;
    bool first = true;
    do {
      if (first) {
        first = false;
      } else {
        currentPage = await site.siteNextUrl(currentPage);
      }
      List<Uri> gigUris = await site.getGigUris(currentPage);
      for (Uri gigUri in gigUris) {
        futureScrapedGigs.add(site.extractGig(gigUri));
      }
    } while (await site.siteHasNextUrl(currentPage));
  }

  int removeCount = 0;
  Set<String> gigIds = new Set<String>();
  List<Gig> scrapedGigs = List.from(await Future.wait(futureScrapedGigs));
  scrapedGigs.removeWhere((Gig gig) {
    if (gigIds.contains(gig.id)) {
      removeCount++;
      return true;
    } else {
      gigIds.add(gig.id);
      return false;
    }
  });

  return new ScrapeResults()
    ..gigs = scrapedGigs
    ..duplicatesRemoved = removeCount;
}
