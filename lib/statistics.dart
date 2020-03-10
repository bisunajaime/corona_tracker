import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;

class Statistics extends StatefulWidget {
  @override
  _StatisticsState createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  bool loading = true;
  String cases;
  String deaths;
  String recovered;

  Future getStats() async {
    setState(() {
      loading = true;
    });

    // fetch data
    http.Client client = http.Client();
    http.Response response =
        await client.get('https://www.worldometers.info/coronavirus/');
    var document = parse(response.body);

    dom.Element deathCount = document.querySelector('body');
    print(deathCount.innerHtml);

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: getStats,
        child: Icon(Icons.refresh),
      ),
      appBar: AppBar(
        title: Text('Statistics'),
      ),
    );
  }
}
