/// UTC date helpers. The daily challenge is keyed to the UTC calendar day so
/// every player in the world gets the same puzzle at the same moment.
library;

/// Midnight (UTC) of the UTC day that contains [instant].
DateTime utcDay(DateTime instant) {
  final utc = instant.toUtc();
  return DateTime.utc(utc.year, utc.month, utc.day);
}

/// `yyyy-MM-dd` key of the UTC day that contains [instant].
String dateKey(DateTime instant) {
  final d = utcDay(instant);
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year.toString().padLeft(4, '0')}-$m-$day';
}

/// Parses a key produced by [dateKey]. Returns null when malformed.
DateTime? parseDateKey(String? key) {
  if (key == null) return null;
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(key);
  if (match == null) return null;
  return DateTime.utc(
    int.parse(match.group(1)!),
    int.parse(match.group(2)!),
    int.parse(match.group(3)!),
  );
}

/// Whole UTC days from [from] to [to] (negative when [to] is earlier).
int utcDaysBetween(DateTime from, DateTime to) =>
    utcDay(to).difference(utcDay(from)).inDays;

/// Time left until the next UTC midnight.
Duration timeUntilNextUtcDay(DateTime now) =>
    utcDay(now).add(const Duration(days: 1)).difference(now.toUtc());
