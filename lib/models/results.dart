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
