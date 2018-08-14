import 'dart:io';

import 'package:craig_scraper/freelance_scraper.dart';
import 'package:craig_scraper/src/indeed.dart';

main(List<String> arguments) async {
//  List<Gig> gigs = await ScrapeSite(new CraigsList(postedToday: true));
  ScrapeResults indeedResults = await ScrapeSite(new Indeed());

  String gigString = "";
  indeedResults.gigs.forEach((Gig gig) => gigString = "${gigString}\n${gig}");
  print(gigString);
  String fileName = "${nowString}.txt";
  print("${indeedResults.duplicatesRemoved} Duplicates Removed");
  print("Writing ${indeedResults.gigs.length} Gigs to ${fileName}");
  File(fileName).writeAsString(gigString);
}

String get nowString =>
    "${DateTime.now().toString().replaceAll(" ", "-").replaceAll(":", "-")}";

