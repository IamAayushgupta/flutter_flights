/* ---------------------------
   Search Results Screen (receives results)
   --------------------------- */
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'FlightDetailSheet.dart';
import 'main.dart';
import 'models/flight.dart';
class SearchResultsScreen extends StatefulWidget {
  final List<Flight> results;
  final String from;
  final String to;
  final String initialSort;

  SearchResultsScreen({
    required this.results,
    required this.from,
    required this.to,
    this.initialSort = 'price_asc',
  });

  @override
  _SearchResultsScreenState createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late List<Flight> list;
  late String sortBy;

  @override
  void initState() {
    super.initState();
    list = List.from(widget.results);
    sortBy = widget.initialSort;
    _applySort();
  }

  void _applySort() {
    if (sortBy == 'price_asc') {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortBy == 'price_desc') {
      list.sort((a, b) => b.price.compareTo(a.price));
    } else if (sortBy == 'duration') {
      list.sort((a, b) =>
          a.arrive.difference(a.depart).inMinutes.compareTo(b.arrive.difference(b.depart).inMinutes));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final titleFrom = widget.from.isEmpty ? 'From' : widget.from.split(' ').first;
    final titleTo = widget.to.isEmpty ? 'To' : widget.to.split(' ').first;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: Colors.teal,
        title: Text('$titleFrom → $titleTo',style: TextStyle(color: Colors.white),),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.sort, color: Colors.white), // <-- make the action icon white
            color: Colors.white, // <-- make popup background white
            onSelected: (s) {
              sortBy = s;
              _applySort();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'price_asc',
                child: Text('Price: Low → High', style: TextStyle(color: Colors.black)), // black text
              ),
              PopupMenuItem(
                value: 'price_desc',
                child: Text('Price: High → Low', style: TextStyle(color: Colors.black)),
              ),
              PopupMenuItem(
                value: 'duration',
                child: Text('Shortest duration', style: TextStyle(color: Colors.black)),
              ),
            ],
          )
        ],

      ),
      body: list.isEmpty
          ? Center(child: Text('No results.'))
          : Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, idx) {
                final f = list[idx];
                final duration = f.arrive.difference(f.depart);
                return Card(
                  color:Color(0xFFFFFFFF),
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => FlightDetailSheet(flight: f),
                        isScrollControlled: true,
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          CircleAvatar(child: Text(f.airline[0],style: TextStyle(color: Colors.white),),backgroundColor: Colors.teal, radius: 24),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${f.airline} • ${f.flightNumber}', style: TextStyle(fontWeight: FontWeight.w600)),
                                SizedBox(height: 6),
                                Text('${DateFormat('hh:mm a').format(f.depart)} → ${DateFormat('hh:mm a').format(f.arrive)}'),
                                Text('${duration.inHours}h ${duration.inMinutes % 60}m • ${f.stops} stop(s)'),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('₹ ${f.price.toStringAsFixed(0)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(height: 6),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,   // <-- button background
                                  foregroundColor: Colors.white,    // <-- text (and icon) color
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12), // optional rounded corners
                                  ),
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Proceed to booking for ₹${f.price.toStringAsFixed(0)}')),
                                  );
                                },
                                child: Text('Select'),
                              )

                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Wrap(
        spacing: 8,
        children: [
          FilterChip(label: Text('Non-stop'), selected: false, onSelected: (v) {},backgroundColor: Colors.white,),
          FilterChip(label: Text('1 stop'), selected: false, onSelected: (v) {},backgroundColor: Colors.white,),
          FilterChip(label: Text('Morning'), selected: false, onSelected: (v) {},backgroundColor: Colors.white,),
          FilterChip(label: Text('Cheapest'), selected: sortBy == 'price_asc', onSelected: (_) {
            setState(() {
              sortBy = 'price_asc';
              _applySort();
            },);
          },backgroundColor: Colors.white,
            selectedColor: Colors.teal.shade100,   // <-- background when selected
            checkmarkColor: Colors.teal,           // <-- tick/check color
            labelStyle: TextStyle(
              color: sortBy == 'price_asc' ? Colors.teal : Colors.black, // text color changes
            ),),
        ],
      ),
    );
  }
}