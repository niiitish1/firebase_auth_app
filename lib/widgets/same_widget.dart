import 'package:flutter/material.dart';

Widget buildMytext({
  required String text,
  required double textSize,
  TextAlign textAlign = TextAlign.center,
  FontWeight fontWeight = FontWeight.normal,
}) {
  return Text(text,
      textAlign: textAlign,
      style: TextStyle(fontSize: textSize, fontWeight: fontWeight));
}
