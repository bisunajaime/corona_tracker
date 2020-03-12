import 'package:coronatracker/models/results.dart';
import 'package:flutter/material.dart';

class MoreInfo extends StatelessWidget {
  final MoreResults results;

  MoreInfo({this.results});

  @override
  Widget build(BuildContext context) {
    Color darkBlue = Color(0xff1C2844);
    Color lightBlue = Color(0xff375087);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkBlue,
        title: Text('More Info'),
      ),
      backgroundColor: lightBlue,
      body: ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          Row(
            children: <Widget>[
              InfoWidget(
                info: results.totalCases,
                title: 'Total Cases',
                infoColor:
                    int.parse(results.totalCases.replaceAll(',', '')) > 1000
                        ? Colors.redAccent[100]
                        : Colors.cyanAccent,
                isCentered: true,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              InfoWidget(
                info: results.totalDeaths,
                title: 'Deaths',
                infoColor:
                    int.parse(results.totalCases.replaceAll(',', '')) > 1000
                        ? Colors.yellowAccent
                        : Colors.cyanAccent,
                isCentered: true,
              ),
              InfoWidget(
                info: results.totalRecovered,
                title: 'Recovered Cases',
                infoColor: Colors.greenAccent,
                isCentered: true,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              InfoWidget(
                info: results.totalActiveCases,
                infoColor: Colors.redAccent[100],
                title: 'Active Cases',
                isCentered: true,
              ),
              InfoWidget(
                info: results.totalClosedCases,
                infoColor: Colors.greenAccent,
                title: 'Closed Cases',
                isCentered: true,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              InfoWidget(
                info: results.totalMild,
                infoColor: Colors.tealAccent,
                title: 'Mild Condition',
                isCentered: true,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              InfoWidget(
                info: results.totalSeriousCritical,
                infoColor: Colors.redAccent[100],
                title: 'Serious / Critical',
                isCentered: true,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              InfoWidget(
                info: results.totalRecovered,
                infoColor: Colors.tealAccent,
                title: 'Recovered',
                isCentered: true,
              ),
              InfoWidget(
                info: results.totalDischarged,
                infoColor: Colors.tealAccent,
                title: 'Discharged',
                isCentered: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InfoWidget extends StatelessWidget {
  final String info;
  final String title;
  final Color infoColor;
  final bool isCentered;

  InfoWidget({
    this.info,
    this.title,
    this.infoColor,
    this.isCentered,
  });

  @override
  Widget build(BuildContext context) {
    Color darkBlue = Color(0xff1C2844);
    BoxShadow defaultShadow = BoxShadow(
      blurRadius: 10.0,
      color: Colors.black45,
    );
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 10.0,
        ),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          boxShadow: [defaultShadow],
          color: darkBlue,
        ),
        child: Column(
          crossAxisAlignment: !isCentered
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          mainAxisAlignment:
              !isCentered ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            Text(
              info,
              style: TextStyle(
                color: infoColor,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
