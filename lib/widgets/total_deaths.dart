import 'package:flutter/material.dart';
import 'package:coronatracker/constants/constants.dart';

class TotalDeaths extends StatelessWidget {
  final String data;
  final String type;
  final double dataSize;
  final double textSize;
  final bool isMaps;

  TotalDeaths({
    this.data,
    this.type,
    this.dataSize,
    this.textSize,
    this.isMaps,
  });

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
                fontSize: dataSize,
                fontFamily: 'Lato-Black',
                color: data == 'NONE' || data == 'NO'
                    ? Colors.greenAccent
                    : int.parse(data.replaceAll(',', '').toString()) >= 50
                        ? Colors.redAccent[100]
                        : Colors.purpleAccent[100],
              ),
            ),
            SizedBox(
              width: isMaps ? 0.0 : 10.0,
              height: isMaps ? 0.0 : 5.0,
            ),
            Text(
              '$type',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: textSize,
                fontFamily: 'Lato-Regular',
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
