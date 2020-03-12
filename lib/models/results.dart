class Results {
  final String country;
  final String totalCases;
  final String newCases;
  final String totalDeaths;
  final String newDeaths;
  final String totalRecovered;
  final String activeCases;
  final String seriousCritical;

  Results({
    this.country,
    this.totalCases,
    this.newCases,
    this.totalDeaths,
    this.newDeaths,
    this.totalRecovered,
    this.activeCases,
    this.seriousCritical,
  });

  factory Results.fromJson(Map<String, dynamic> json) {
    return Results(
      country: json['country'],
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
