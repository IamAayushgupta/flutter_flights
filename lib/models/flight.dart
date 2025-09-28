// lib/models/flight.dart
class Flight {
  final String airline;
  final String flightNumber;
  final String from;
  final String to;
  final DateTime depart;
  final DateTime arrive;
  final int stops;
  final double price;
  final String cabin;

  Flight({
    required this.airline,
    required this.flightNumber,
    required this.from,
    required this.to,
    required this.depart,
    required this.arrive,
    required this.stops,
    required this.price,
    required this.cabin,
  });

  // Optional: helper to compute duration
  Duration get duration => arrive.difference(depart);

  // Optional: fromJson/toJson if you later integrate with REST
  factory Flight.fromJson(Map<String, dynamic> j) => Flight(
    airline: j['airline'] as String,
    flightNumber: j['flightNumber'] as String,
    from: j['from'] as String,
    to: j['to'] as String,
    depart: DateTime.parse(j['depart'] as String),
    arrive: DateTime.parse(j['arrive'] as String),
    stops: j['stops'] as int,
    price: (j['price'] as num).toDouble(),
    cabin: j['cabin'] as String,
  );

  Map<String, dynamic> toJson() => {
    'airline': airline,
    'flightNumber': flightNumber,
    'from': from,
    'to': to,
    'depart': depart.toIso8601String(),
    'arrive': arrive.toIso8601String(),
    'stops': stops,
    'price': price,
    'cabin': cabin,
  };
}
