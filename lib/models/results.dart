//class Results {
//  final String country;
//  final String totalCases;
//  final String newCases;
//  final String totalDeaths;
//  final String newDeaths;
//  final String totalRecovered;
//  final String activeCases;
//  final String seriousCritical;
//
//  Results({
//    this.country,
//    this.totalCases,
//    this.newCases,
//    this.totalDeaths,
//    this.newDeaths,
//    this.totalRecovered,
//    this.activeCases,
//    this.seriousCritical,
//  });
//
//  factory Results.fromJson(Map<String, dynamic> json) {
//    return Results(
//      country: json['country'],
//      totalCases: json['totalCases'],
//      newCases: json['newCases'],
//      totalDeaths: json['totalDeaths'],
//      newDeaths: json['newDeaths'],
//      totalRecovered: json['totalRecovered'],
//      activeCases: json['activeCases'],
//      seriousCritical: json['seriousCritical'],
//    );
//  }
//}

class Country {
  final String countryName;
  final CountryInfo info;

  Country({this.countryName, this.info});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      countryName: json['countryName'],
      info: CountryInfo.fromJson(json['info']),
    );
  }
}

class CountryInfo {
  final String totalCases;
  final String newCases;
  final String totalDeaths;
  final String newDeaths;
  final String totalRecovered;
  final String activeCases;
  final String seriousCritical;

  CountryInfo({
    this.totalCases,
    this.newCases,
    this.totalDeaths,
    this.newDeaths,
    this.totalRecovered,
    this.activeCases,
    this.seriousCritical,
  });

  factory CountryInfo.fromJson(Map<String, dynamic> json) {
    return CountryInfo(
      totalCases: json['totalCases'],
      newCases: json['newCases'],
      totalDeaths: json['totalDeaths'],
      newDeaths: json['newDeaths'],
      totalRecovered: json['totalRecovered'],
      activeCases: json['activeCases'],
      seriousCritical: json['seriousCritical'],
    );
  }
}

class MoreResults {
  final String totalCases;
  final String totalDeaths;
  final String totalRecovered;
  final String totalActiveCases;
  final String totalClosedCases;
  final String totalMild;
  final String totalSeriousCritical;
  final String totalDischarged;

  MoreResults({
    this.totalCases,
    this.totalDeaths,
    this.totalRecovered,
    this.totalActiveCases,
    this.totalClosedCases,
    this.totalMild,
    this.totalSeriousCritical,
    this.totalDischarged,
  });

  factory MoreResults.fromJson(Map<String, dynamic> json) {
    return MoreResults(
      totalCases: json['totalCases'],
      totalDeaths: json[''],
      totalRecovered: json['totalRecovered'],
      totalActiveCases: json['totalActiveCases'],
      totalClosedCases: json['totalClosedCases'],
      totalMild: json['totalMild'],
      totalSeriousCritical: json['totalSeriousCritical'],
      totalDischarged: json['totalDischarged'],
    );
  }
}

class LocationData {
  final String country;
  final String lat;
  final String long;

  LocationData({this.country, this.lat, this.long});

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      country: json['country'],
      lat: json['lat'],
      long: json['long'],
    );
  }
}
