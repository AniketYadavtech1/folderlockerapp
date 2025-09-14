import 'package:intl/intl.dart';

class DateFormats {
  static String formatDateTime(String dateTimeString) {
    DateTime now = DateTime.now();
    DateTime inputDate = DateTime.parse(dateTimeString);

    String formattedTime = DateFormat("hh:mm a").format(inputDate);

    if (inputDate.year == now.year && inputDate.month == now.month && inputDate.day == now.day) {
      return "Today at $formattedTime";
    } else {
      return DateFormat("dd MMM yyyy 'at' hh:mm a").format(inputDate);
    }
  }

  static String formatDateYYYYMMDD(DateTime date) {
    return DateFormat("yyyy-MM-dd").format(date);
  }

  static String formatDateDDMMYYYY(DateTime date) {
    return DateFormat("dd/MM/yyyy").format(date);
  }
}
