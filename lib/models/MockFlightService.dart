/* ---------------------------
   Mock Service
   --------------------------- */

import 'flight.dart';

class MockFlightService {
  static final List<String> airlines = ['IndiGo', 'Air India', 'SpiceJet', 'Vistara', 'GoAir'];

  static List<Flight> search({
    required String from,
    required String to,
    required DateTime departDate,
    required String cabin,
    required int adults,
    required int children,
    required int infants,
  }) {
    final base = DateTime(departDate.year, departDate.month, departDate.day, 6);
    List<Flight> list = List.generate(6, (i) {
      final depart = base.add(Duration(hours: i * 2, minutes: (i % 3) * 15));
      final arrive = depart.add(Duration(hours: 1 + (i % 3), minutes: (i * 10) % 60));
      final price = 2000.0 + i * 700 + (cabin == 'Business' ? 4500 : 0) + (adults - 1) * 1500;
      return Flight(
        airline: airlines[i % airlines.length],
        flightNumber: '${100 + i}',
        from: from,
        to: to,
        depart: depart,
        arrive: arrive,
        stops: i % 2,
        price: price,
        cabin: cabin,
      );
    });

    return list;
  }
}