import 'package:coronatracker/constants/constants.dart';
import 'package:flutter/material.dart';

class TotalRecovered extends StatelessWidget {
  final String data;
  final String type;
  final double dataSize;
  final double textSize;

  TotalRecovered({this.data, this.type, this.dataSize, this.textSize});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 5.0,
        ),
        padding: EdgeInsets.symmetric(
          vertical: 15.0,
        ),
        decoration: BoxDecoration(
          color: eerieBlack,
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
                fontFamily: 'Lato-Black',
                fontSize: dataSize,
                color: data == 'NONE' || data == 'NO'
                    ? Colors.blueAccent
                    : int.parse(data.replaceAll(',', '').toString()) >= 10
                        ? Colors.greenAccent[100]
                        : Colors.redAccent[100],
              ),
            ),
            SizedBox(
              width: 10.0,
            ),
            Text(
              '$type',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Lato-Regular',
                fontSize: textSize,
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
