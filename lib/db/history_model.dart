class History {
  final int id;
  final String source;
  final String target;
  final String from;
  final String to;
  final int time;

  History({
    required this.id,
    required this.source,
    required this.target,
    required this.from,
    required this.to,
    required this.time,
  });

  // Convert a History into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, Object?> toMap() {
    return {
      'source': source,
      'target': target,
      'from': from,
      'to': to,
      'time': time
    };
  }

  @override
  String toString() {
    return 'History{id: $id, source: $source, target: $target, from: $from, to: $to, time: $time}';
  }
}
