/* ---------------------------
   Flight Detail Sheet (Styled)
   --------------------------- */
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/flight.dart';

class FlightDetailSheet extends StatelessWidget {
  final Flight flight;
  FlightDetailSheet({required this.flight});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('EEE, dd MMM • hh:mm a');
    final duration = flight.arrive.difference(flight.depart);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // background white
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Wrap(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.teal, // brand color
                      child: Text(
                        flight.airline[0],
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          flight.airline,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C2C2C),
                          ),
                        ),
                        Text(
                          '${flight.flightNumber} • ${flight.cabin}',
                          style: TextStyle(color: Colors.grey.shade700),
                        )
                      ],
                    ),
                    Spacer(),
                    Text(
                      '₹ ${flight.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),

                Divider(height: 24, thickness: 1),

                // Route
                Text(
                  'Route',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(flight.from, style: TextStyle(color: Colors.black)),
                          Text(fmt.format(flight.depart), style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    Icon(Icons.flight_takeoff, color: Colors.teal),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(flight.to, style: TextStyle(color: Colors.black)),
                          Text(fmt.format(flight.arrive), style: TextStyle(color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 14),

                // Duration
                Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.teal),
                    SizedBox(width: 8),
                    Text(
                      '${duration.inHours}h ${duration.inMinutes % 60}m • ${flight.stops} stop(s)',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Fare Rules
                Text(
                  'Baggage & Fare rules',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                SizedBox(height: 6),
                Text(
                  'Standard fare rules apply. Check baggage allowances with the airline before travel.',
                  style: TextStyle(color: Colors.grey.shade700),
                ),

                SizedBox(height: 20),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal, // brand color
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Booking flow not implemented in mock.')),
                          );
                        },
                        child: Text('Book Now'),
                      ),
                    ),
                    SizedBox(width: 8),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Colors.teal),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Close'),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
