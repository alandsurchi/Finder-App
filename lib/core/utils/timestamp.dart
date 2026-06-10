class Timestamp implements Comparable<Timestamp> {
  final int _seconds;
  final int _nanoseconds;

  const Timestamp(this._seconds, this._nanoseconds);

  factory Timestamp.now() {
    final now = DateTime.now();
    return Timestamp.fromDateTime(now);
  }

  factory Timestamp.fromMillisecondsSinceEpoch(int milliseconds) {
    final seconds = milliseconds ~/ 1000;
    final nanoseconds = (milliseconds % 1000) * 1000000;
    return Timestamp(seconds, nanoseconds);
  }

  factory Timestamp.fromDateTime(DateTime dateTime) {
    final seconds = dateTime.millisecondsSinceEpoch ~/ 1000;
    final nanoseconds = (dateTime.microsecondsSinceEpoch % 1000000) * 1000;
    return Timestamp(seconds, nanoseconds);
  }

  int get seconds => _seconds;
  int get nanoseconds => _nanoseconds;

  int get millisecondsSinceEpoch => _seconds * 1000 + _nanoseconds ~/ 1000000;

  int get microsecondsSinceEpoch => _seconds * 1000000 + _nanoseconds ~/ 1000;

  DateTime toDate() {
    return DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
  }

  @override
  int compareTo(Timestamp other) {
    if (_seconds != other._seconds) {
      return _seconds.compareTo(other._seconds);
    }
    return _nanoseconds.compareTo(other._nanoseconds);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Timestamp &&
          _seconds == other._seconds &&
          _nanoseconds == other._nanoseconds;

  @override
  int get hashCode => _seconds.hashCode ^ _nanoseconds.hashCode;

  @override
  String toString() => 'Timestamp(seconds=$seconds, nanoseconds=$nanoseconds)';
}
