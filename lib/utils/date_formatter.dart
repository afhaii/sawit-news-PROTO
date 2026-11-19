import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatDate(String value) {
    if (value.trim().isEmpty) return 'Tanggal tidak tersedia';

    final date = DateTime.tryParse(value);
    if (date == null) return 'Tanggal tidak tersedia';

    return DateFormat('dd MMMM yyyy • HH:mm', 'id_ID').format(date.toLocal());
  }
}
