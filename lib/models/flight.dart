class Flight {
  final int id;
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
    required this.id,
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

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      id: json['id'],
      airline: json['airline'],
      flightNumber: json['flight_number'],
      from: json['from'],
      to: json['to'],
      depart: DateTime.parse(json['departure_time']),
      arrive: DateTime.parse(json['arrival_time']),
      stops: json['stops'],
      price: (json['price'] as num).toDouble(),
      cabin: json['cabin'],
    );
  }
}
