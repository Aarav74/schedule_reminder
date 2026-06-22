class DateTimeUtils {
  static String formatTime12h(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final ampm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final displayMinute = minute < 10 ? '0$minute' : '$minute';
    return '$displayHour:$displayMinute $ampm';
  }

  static String formatTime24h(DateTime dateTime) {
    final hour = dateTime.hour < 10 ? '0${dateTime.hour}' : '${dateTime.hour}';
    final minute = dateTime.minute < 10 ? '0${dateTime.minute}' : '${dateTime.minute}';
    return '$hour:$minute';
  }

  static DateTime parse24hTime(String timeStr, DateTime date) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  static bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}
