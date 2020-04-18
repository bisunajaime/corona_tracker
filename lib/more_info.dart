import 'package:coronatracker/models/results.dart';
import 'package:flutter/material.dart';
import 'package:coronatracker/constants/constants.dart';

class MoreInfo extends StatefulWidget {
  final MoreResults results;

  MoreInfo({this.results});

  @override
  _MoreInfoState createState() => _MoreInfoState();
}

class _MoreInfoState extends State<MoreInfo> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color darkBlue = yankeesBlue;
    Color lightBlue = eerieBlack;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkBlue,
        title: Text(
          'More Info',
          style: TextStyle(
            fontFamily: 'Lato-Black',
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: lightBlue,
      body: ListView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          Row(
            children: <Widget>[
              InfoWidget(
                info: widget.results.totalCases,
                title: 'Total Cases',
                infoColor:
                    int.parse(widget.results.totalCases.replaceAll(',', '')) >
                            1000
                        ? Colors.redAccent[100]
                        : Colors.cyanAccent,
                isCentered: true,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              InfoWidget(
                info: widget.results.totalDeaths,
                title: 'Deaths',
                infoColor:
                    int.parse(widget.results.totalCases.replaceAll(',', '')) >
                            1000
                        ? Colors.yellowAccent
                        : Colors.cyanAccent,
                isCentered: true,
              ),
              InfoWidget(
                info: widget.results.totalRecovered,
                title: 'Recovered Cases',
                infoColor: Colors.greenAccent,
                isCentered: true,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              InfoWidget(
                info: widget.results.totalActiveCases,
                infoColor: Colors.redAccent[100],
                title: 'Active Cases',
                isCentered: true,
              ),
              InfoWidget(
                info: widget.results.totalClosedCases,
                infoColor: Colors.greenAccent,
                title: 'Closed Cases',
                isCentered: true,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              InfoWidget(
                info: widget.results.totalMild,
                infoColor: Colors.tealAccent,
                title: 'Mild Condition',
                isCentered: true,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              InfoWidget(
                info: widget.results.totalSeriousCritical,
                infoColor: Colors.redAccent[100],
                title: 'Serious / Critical',
                isCentered: true,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              InfoWidget(
                info: widget.results.totalRecovered,
                infoColor: Colors.tealAccent,
                title: 'Recovered',
                isCentered: true,
              ),
              InfoWidget(
                info: widget.results.totalDischarged,
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
          color: yankeesBlue,
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
                fontFamily: 'Lato-Regular',
                fontSize: 15,
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            Text(
              info,
              style: TextStyle(
                fontFamily: 'Lato-Black',
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
