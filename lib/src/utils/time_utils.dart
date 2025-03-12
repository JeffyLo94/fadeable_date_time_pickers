extension FDateTimeExtensions on DateTime {
  DateTime roundNearestMinute(Duration interval, [bool roundUp = false]) {
    assert(interval >= Duration.zero);
    if (interval == Duration.zero) return this;

    //print('Time Now -  ${this}');
    //print(
    // 'interval in Minutes: ${interval.inMinutes} and in Seconds: ${interval.inSeconds}');
    int minuteModValue;
    if (interval.inMinutes == 0) {
      minuteModValue = 0;
    } else {
      minuteModValue = (minute) % interval.inMinutes;
    }
    DateTime newDt;

    if (roundUp && minuteModValue > (interval.inMinutes / 2)) {
      //round up
      //print('round up');
      newDt = _alignDateTime(this, interval, true);
    } else {
      //round down
      //print('round down');
      newDt = _alignDateTime(this, interval);
    }
    //print('rounded time: $newDt');
    return newDt;
  }

  DateTime _alignDateTime(DateTime dt, Duration alignment,
      [bool roundUp = false]) {
    assert(alignment >= Duration.zero);
    if (alignment == Duration.zero) return dt;
    //print('alignment duration: $alignment');
    //print(
    // 'correction seconds alignment ${alignment.inMinutes > 0 ? alignment.inSeconds - 60 < 60 ? dt.second : alignment.inSeconds > 0 ? dt.second % alignment.inSeconds : 0 : alignment.inSeconds > 0 ? dt.second % alignment.inSeconds : 0}');
    final correction = Duration(
        days: 0,
        hours: alignment.inDays > 0
            ? dt.hour
            : alignment.inHours > 0
                ? dt.hour % alignment.inHours
                : 0,
        minutes: alignment.inHours > 0
            ? dt.minute
            : alignment.inMinutes > 0
                ? dt.minute % alignment.inMinutes
                : 0,
        seconds: alignment.inMinutes > 0
            ? alignment.inSeconds - 60 > 60
                ? dt.second
                : alignment.inSeconds - 60 > 0
                    ? dt.second % (alignment.inSeconds - 60)
                    : 0
            : alignment.inSeconds > 0
                ? dt.second % alignment.inSeconds
                : 0,
        milliseconds: alignment.inSeconds > 0
            ? dt.millisecond
            : alignment.inMilliseconds > 0
                ? dt.millisecond % alignment.inMilliseconds
                : 0,
        microseconds: alignment.inMilliseconds > 0 ? dt.microsecond : 0);
    //print('correction duration: ${correction}');
    if (correction == Duration.zero) return dt;
    final corrected = dt.subtract(correction);
    final result = roundUp ? corrected.add(alignment) : corrected;
    return result;
  }

  int daysBetween(DateTime other) {
    final from = DateTime(year, month, day);
    final to = DateTime(other.year, other.month, other.day);
    return (to.difference(from).inHours / 24).round();
  }

  DateTime addDate({int years = 0, int months = 0, int days = 0}) {
    if (years == 0 && months == 0 && days == 0) return this;

    return isUtc
        ? DateTime.utc(year + years, month + months, day + days, hour, minute,
            second, millisecond, microsecond)
        : DateTime(year + years, month + months, day + days, hour, minute,
            second, millisecond, microsecond);
  }
}
