import 'dart:async';

import 'package:coronatracker/corona_maps.dart';
import 'package:coronatracker/widgets/active_cases.dart';
import 'package:coronatracker/widgets/new_deaths.dart';
import 'package:coronatracker/widgets/serious_critical.dart';
import 'package:coronatracker/widgets/total_cases.dart';
import 'package:coronatracker/widgets/total_deaths.dart';
import 'package:coronatracker/widgets/total_recovered.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

import 'models/results.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Corona Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> countriesList = [];
  List<String> totalCasesList = [];
  List<String> newCasesList = [];
  List<String> totalDeathsList = [];
  List<String> newDeathsList = [];
  List<String> totalRecovered = [];
  List<String> activeCasesList = [];
  List<String> seriousCriticalList = [];

  Map<String, dynamic> results = {};
  List<Map<String, dynamic>> data = [];
  List<Results> info = [];

  bool loading = true;
  bool showReloadMsg = false;

  Timer getMarkers;

  Future getCountries() async {
    setState(() {
      // clear when reload
      loading = true;
      showReloadMsg = false;
      info.clear();
      data.clear();
      countriesList.clear();
      totalCasesList.clear();
      totalDeathsList.clear();
      newDeathsList.clear();
      totalRecovered.clear();
      newCasesList.clear();
      activeCasesList.clear();
      seriousCriticalList.clear();
    });

    Timer(Duration(seconds: 5), () {
      setState(() {
        showReloadMsg = true;
      });
    });
    // fetch data
    http.Client client = http.Client();
    http.Response response =
        await client.get('https://www.worldometers.info/coronavirus/');
    var document = parse(response.body);

    // print data
    List<dom.Element> totalCases = document.getElementsByTagName('td');

    for (int x = 0; x < totalCases.length; x += 9) {
      if (totalCases[x].innerHtml.contains('<a')) {
        countriesList.add(totalCases[x].querySelector('a').innerHtml.trim());
      } else if (totalCases[x].innerHtml.contains('<span')) {
        countriesList.add(totalCases[x].querySelector('span').innerHtml.trim());
      } else {
        countriesList.add(totalCases[x].innerHtml.trim());
      }
    }

    // Total Cases
    for (int x = 1; x < totalCases.length; x += 9) {
      totalCasesList.add(totalCases[x].innerHtml.trim());
    }

    for (int x = 2; x < totalCases.length; x += 9) {
      if (totalCases[x].innerHtml.trim().length != 0) {
        newCasesList.add(totalCases[x].innerHtml.trim());
      } else {
        newCasesList.add('NO');
      }
    }

    for (int x = 3; x < totalCases.length; x += 9) {
      if (totalCases[x].innerHtml.trim().length != 0) {
        totalDeathsList.add(totalCases[x].innerHtml.trim());
      } else {
        totalDeathsList.add('NONE');
      }
    }

    for (int x = 4; x < totalCases.length; x += 9) {
      if (totalCases[x].innerHtml.trim().length != 0) {
        newDeathsList.add(totalCases[x].innerHtml.trim());
      } else {
        newDeathsList.add('NO');
      }
    }

    for (int x = 5; x < totalCases.length; x += 9) {
      if (totalCases[x].innerHtml.trim().length != 0) {
        totalRecovered.add(totalCases[x].innerHtml.trim());
      } else {
        totalRecovered.add('NONE');
      }
    }

    for (int x = 6; x < totalCases.length; x += 9) {
      if (totalCases[x].innerHtml.trim().length != 0) {
        activeCasesList.add(totalCases[x].innerHtml.trim());
      } else {
        activeCasesList.add('NONE');
      }
    }

    for (int x = 7; x < totalCases.length; x += 9) {
      if (totalCases[x].innerHtml.trim().length != 0) {
        seriousCriticalList.add(totalCases[x].innerHtml.trim());
      } else {
        seriousCriticalList.add('NONE');
      }
    }

    // remove total tr
    countriesList.removeLast();
    totalCasesList.removeLast();
    totalDeathsList.removeLast();
    newDeathsList.removeLast();
    totalRecovered.removeLast();
    newCasesList.removeLast();
    activeCasesList.removeLast();
    seriousCriticalList.removeLast();

    for (int i = 0; i < countriesList.length; i++) {
      data.add({
        'country': countriesList[i],
        'totalCases': totalCasesList[i],
        'newCases': newCasesList[i],
        'totalDeaths': totalDeathsList[i],
        'newDeaths': newDeathsList[i],
        'totalRecovered': totalRecovered[i],
        'activeCases': activeCasesList[i],
        'seriousCritical': seriousCriticalList[i],
      });
    }

    info = data.map((res) => Results.fromJson(res)).toList();

    setState(() {
      loading = false;
      showReloadMsg = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getCountries();
    super.initState();
    //initiate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: Color(0xff1C2844),
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.indigo[900],
                      Colors.indigo[800],
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Corona Tracker',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 30,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        '${info.length} \nAffected Places',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow,
                          fontSize: 20,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              MaterialButton(
                color: Color(0xff374972),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CoronaMaps(
                      resultData: info,
                    ),
                  ),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.location_on,
                    color: Colors.yellow,
                  ),
                  title: Text(
                    'Corona Maps',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Column(
          children: <Widget>[
            Text('Corona Tracker'),
            Text(
              '${info.length} Places',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.cyanAccent,
              ),
            )
          ],
        ),
        centerTitle: true,
        backgroundColor: Color(0xff1d2c4d),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              getCountries();
              //getMarkers.cancel();
            },
          )
        ],
      ),
      backgroundColor: Color(0xff375087),
      body: loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    'Loading... \n ${showReloadMsg ? '\nLooks like its taking a while...\n try reloading again!' : ''}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            )
          : ListView.builder(
              itemCount: info.length,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, i) {
                return Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 10.0,
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Color(0xff1d2c4d),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 10.0,
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            '${info[i].country}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 20.0,
                            ),
                          ),
                          Column(
                            children: <Widget>[
                              Text(
                                '${info[i].newCases}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: info[i].newCases == 'NO'
                                      ? Colors.greenAccent
                                      : int.parse(info[i]
                                                  .newCases
                                                  .replaceFirst('+', '')) >=
                                              10
                                          ? Colors.amber
                                          : Colors.orange,
                                ),
                              ),
                              Text(
                                'New Cases',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10.0,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              TotalCases(
                                data: info[i].totalCases,
                                type: 'Total \nCases',
                              ),
                              TotalDeaths(
                                data: info[i].totalDeaths,
                                type: 'Total \nDeaths',
                              ),
                              NewDeaths(
                                data: info[i].newDeaths,
                                type: 'New \n Deaths',
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            children: <Widget>[
                              TotalRecovered(
                                data: info[i].totalRecovered,
                                type: 'Total Recovered',
                              ),
                              ActiveCases(
                                data: info[i].activeCases,
                                type: 'Active Cases',
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            children: <Widget>[
                              SeriousCritical(
                                data: info[i].seriousCritical,
                                type: 'Serious, Critical',
                              )
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
