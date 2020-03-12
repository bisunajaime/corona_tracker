import 'dart:async';

import 'package:coronatracker/corona_maps.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

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

    // remove total tr
    countriesList.removeLast();
    totalCasesList.removeLast();
    totalDeathsList.removeLast();
    newDeathsList.removeLast();
    totalRecovered.removeLast();
    newCasesList.removeLast();

    for (int i = 0; i < countriesList.length; i++) {
      data.add({
        'country': countriesList[i],
        'totalCases': totalCasesList[i],
        'newCases': newCasesList[i],
        'totalDeaths': totalDeathsList[i],
        'newDeaths': newDeathsList[i],
        'totalRecovered': totalRecovered[i],
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
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange,
                    Colors.pink,
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  'Corona \n Tracker: ${info.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 30,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            MaterialButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CoronaMaps(
                    resultData: info,
                  ),
                ),
              ),
              child: ListTile(
                leading: Icon(Icons.location_on),
                title: Text('Corona Maps'),
              ),
            )
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('Corona Tracker: ${info.length}'),
        backgroundColor: Colors.red[800],
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
                      fontSize: 12.0,
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueGrey,
                        blurRadius: 5.0,
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
                                      ? Colors.green[700]
                                      : int.parse(info[i]
                                                  .newCases
                                                  .replaceFirst('+', '')) >=
                                              20
                                          ? Colors.red
                                          : Colors.orange,
                                ),
                              ),
                              Text(
                                'New Cases',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10.0,
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
                                type: 'Total \n Recovered',
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class TotalCases extends StatelessWidget {
  final String data;
  final String type;

  TotalCases({this.data, this.type});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 5.0,
        ),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: data == 'NONE' || data == 'NO'
              ? Colors.blue
              : int.parse(data.replaceAll(',', '').toString()) >= 100
                  ? Colors.red[700]
                  : Colors.purple[700],
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 2.0,
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Text(
              '$data',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            Text(
              '$type',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }
}

class TotalDeaths extends StatelessWidget {
  final String data;
  final String type;

  TotalDeaths({this.data, this.type});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 5.0,
        ),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: data == 'NONE' || data == 'NO'
              ? Colors.blue
              : int.parse(data.replaceAll(',', '').toString()) >= 50
                  ? Colors.red[700]
                  : Colors.purple[700],
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 2.0,
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Text(
              '$data',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            Text(
              '$type',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }
}

class NewDeaths extends StatelessWidget {
  final String data;
  final String type;

  NewDeaths({this.data, this.type});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 5.0,
        ),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: data == 'NONE' || data == 'NO'
              ? Colors.blue
              : int.parse(data.replaceAll(',', '').toString()) >= 10
                  ? Colors.red[700]
                  : Colors.purple[700],
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 2.0,
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Text(
              '$data',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            Text(
              '$type',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }
}

class TotalRecovered extends StatelessWidget {
  final String data;
  final String type;

  TotalRecovered({this.data, this.type});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 5.0,
        ),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: data == 'NONE' || data == 'NO'
              ? Colors.blue
              : int.parse(data.replaceAll(',', '').toString()) >= 10
                  ? Colors.green[900]
                  : Colors.red[700],
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 2.0,
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            Text(
              '$data',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            Text(
              '$type',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }
}

class Results {
  final String country;
  final String totalCases;
  final String newCases;
  final String totalDeaths;
  final String newDeaths;
  final String totalRecovered;

  Results(
      {this.country,
      this.totalCases,
      this.newCases,
      this.totalDeaths,
      this.newDeaths,
      this.totalRecovered});

  factory Results.fromJson(Map<String, dynamic> json) {
    return Results(
      country: json['country'],
      totalCases: json['totalCases'],
      newCases: json['newCases'],
      totalDeaths: json['totalDeaths'],
      newDeaths: json['newDeaths'],
      totalRecovered: json['totalRecovered'],
    );
  }
}
