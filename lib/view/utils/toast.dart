import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppUtils {
  static show(String msg) {
    Fluttertoast.showToast(msg: msg);
  }

  static Future<DateTime?> pickDate(BuildContext context) async {
    final date = await showDatePicker(context: context, firstDate: DateTime(1950), lastDate: DateTime(2080));
    if (date != null) {
      return date;
    }
    return null;
  }
}
