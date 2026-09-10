import 'package:intl/intl.dart';

String formatMoney(double value) =>
    'UGX ${NumberFormat.decimalPattern('en').format(value.floor())}';

String formatTime(DateTime t) => DateFormat('h:mm a').format(t.toLocal());

String formatDateTime(DateTime t) =>
    DateFormat('MMM d, yyyy · h:mm a').format(t.toLocal());