import 'package:flutter/material.dart';

class SeriousCritical extends StatelessWidget {
  final String data;
  final String type;

  SeriousCritical({this.data, this.type});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 5.0,
        ),
        padding: EdgeInsets.symmetric(
          vertical: 10.0,
        ),
        decoration: BoxDecoration(
          color: Color(0xff131C2F),
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
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
                fontSize: 25,
                color: data == 'NONE' || data == 'NO'
                    ? Colors.greenAccent
                    : int.parse(data.replaceAll(',', '').toString()) >= 10
                        ? Colors.redAccent[100]
                        : Colors.greenAccent[100],
              ),
            ),
            SizedBox(
              width: 10.0,
            ),
            Text(
              '$type',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.0,
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
