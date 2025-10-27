// lib/main.dart
import 'dart:async';
import 'dart:convert';
import 'package:flight_booking/pages/login.dart';
import 'package:flight_booking/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

// import the model
import 'AppConstants.dart';
import 'SearchResultsScreen.dart';
import 'models/MockFlightService.dart';
import 'models/flight.dart';


void main() {
  runApp(MyApp());
}

/* ---------------------------
   App Entry
   --------------------------- */
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/background.jpg'),
          fit: BoxFit.cover, // cover entire screen
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 500,
            maxHeight: MediaQuery.sizeOf(context).height,
          ),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Flights',
            theme: ThemeData(primarySwatch: Colors.teal),
            home: SplashPage(),
          ),
        ),
      ),
    );

  }
}

/* ---------------------------
   Home Screen (Search UI) - using setState
   with Discount Ads Slider added below quick suggestions
   --------------------------- */
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();

  // UI state
  final List<String> _airports = [
    'Indore (IDR)',
    'Mumbai (BOM)',
    'Delhi (DEL)',
    'Bengaluru (BLR)',
    'Chennai (MAA)',
    'Kolkata (CCU)',
    'Hyderabad (HYD)',
    'Goa (GOI)'
  ];

  String from = '';
  String to = '';
  DateTime? departDate;
  DateTime? returnDate;
  bool isRoundTrip = false;
  int adults = 1;
  int children = 0;
  int infants = 0;
  String cabin = 'Economy';

  bool loading = false;
  List<Flight> results = [];
  String sortBy = 'price_asc';

  // Ads slider state
  final PageController _adController = PageController(viewportFraction: 0.94);
  Timer? _adTimer;
  int _currentAd = 0;
  final List<DiscountAd> _ads = [
    DiscountAd(title: 'Flat ₹500 off on roundtrips', subtitle: 'Use code ROUND500', imageEmoji: '✈️'),
    DiscountAd(title: 'Student Discount 10%', subtitle: 'Student ID required', imageEmoji: '🎓'),
    DiscountAd(title: 'Weekend Sale — Save up to 30%', subtitle: 'Valid Fri–Sun', imageEmoji: '🔥'),
  ];

  @override
  void initState() {
    super.initState();
    departDate = DateTime.now().add(Duration(days: 3));
    _startAdAutoScroll();
  }

  void _startAdAutoScroll() {
    _adTimer?.cancel();
    _adTimer = Timer.periodic(Duration(seconds: 3), (t) {  // changed 4 → 1
      if (_ads.isEmpty || !mounted) return;
      _currentAd = (_currentAd + 1) % _ads.length;
      _adController.animateToPage(
        _currentAd,
        duration: Duration(milliseconds: 300), // smooth animation
        curve: Curves.easeInOut,
      );
    });
  }


  void _stopAdAutoScroll() {
    _adTimer?.cancel();
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    _adController.dispose();
    _fromCtrl.dispose();
    _toCtrl.dispose();
    super.dispose();
  }

  Future<void> searchFlights() async {
    print('$from $to $departDate');

    if (from.isEmpty || to.isEmpty || departDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill From, To, and Depart date.')),
      );
      return;
    }

    // Start loading state
    setState(() {
      loading = true;
      results = [];
    });

    try {
      // ✅ Format date correctly
      final formattedDate = DateFormat("yyyy-MM-dd'T'HH").format(departDate!);

      final url = Uri.parse(
        "$baseUrl/flights/search?from=$from&to=$to&date=$formattedDate",
      );

      print('🔍 Searching flights: $url');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['flights'] != null) {
          final flights = (data['flights'] as List)
              .map((e) => Flight.fromJson(e))
              .toList();

          if (flights.isEmpty) {
            throw Exception("No flights found for given criteria");
          }

          // ✅ Update state first
          setState(() {
            results = flights;
            loading = false;
            sortBy = 'price_asc';
          });

          // ✅ Navigate safely after build completes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SearchResultsScreen(
                  results: results,
                  from: from,
                  to: to,
                  initialSort: sortBy,
                ),
              ),
            );
          });
          return;
        } else {
          throw Exception(data['message'] ?? 'No flights found');
        }
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      print('❌ Error in searchFlights: $e');

      // Fallback to mock data after delay
      await Future.delayed(const Duration(milliseconds: 500));
      final mockList = MockFlightService.search(
        from: from,
        to: to,
        departDate: departDate!,
        cabin: cabin,
        adults: adults,
        children: children,
        infants: infants,
      );

      mockList.sort((a, b) => a.price.compareTo(b.price));

      setState(() {
        results = mockList;
        loading = false;
        sortBy = 'price_asc';
      });

      // ✅ Safe navigation here too
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SearchResultsScreen(
              results: results,
              from: from,
              to: to,
              initialSort: sortBy,
            ),
          ),
        );
      });
    }
  }



  Future<void> _pickDate(BuildContext context, {required bool isReturn}) async {
    final now = DateTime.now();
    final initial = isReturn ? (returnDate ?? departDate ?? now.add(Duration(days: 3))) : (departDate ?? now.add(Duration(days: 3)));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        if (isReturn) returnDate = picked;
        else departDate = picked;
      });
    }
  }

  Future<void> _showPassengersDialog(BuildContext context) async {
    int localAdults = adults;
    int localChildren = children;
    int localInfants = infants;
    String localCabin = cabin;

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Travelers & Cabin'),
          content: StatefulBuilder(builder: (context, setStateDialog) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _counterRow('Adults', localAdults, (v) => setStateDialog(() => localAdults = v), min: 1),
                _counterRow('Children', localChildren, (v) => setStateDialog(() => localChildren = v)),
                _counterRow('Infants', localInfants, (v) => setStateDialog(() => localInfants = v)),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: localCabin,
                  items: ['Economy', 'Premium Economy', 'Business'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setStateDialog(() => localCabin = v ?? localCabin),
                  decoration: InputDecoration(labelText: 'Cabin'),
                )
              ],
            );
          }),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    adults = localAdults;
                    children = localChildren;
                    infants = localInfants;
                    cabin = localCabin;
                  });
                  Navigator.of(context).pop();
                },
                child: Text('Save'))
          ],
        );
      },
    );
  }

  Widget _counterRow(String label, int value, void Function(int) onChanged, {int min = 0}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Row(children: [
          IconButton(icon: Icon(Icons.remove_circle_outline), onPressed: value > min ? () => onChanged(value - 1) : null),
          Text('$value'),
          IconButton(icon: Icon(Icons.add_circle_outline), onPressed: () => onChanged(value + 1)),
        ])
      ],
    );
  }

  Widget _buildAutoCompleteField({
    required TextEditingController controller,
    required String label,
    required void Function(String) setter,
  }) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
        return _airports.where((a) => a.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (selection) {
        controller.text = selection;
        setter(selection);
      },
      fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            isDense: true,
            suffixIcon: label == 'From'
                ? const Icon(Icons.flight_takeoff)
                : const Icon(Icons.flight_land),
          ),
          onChanged: setter,
        );
      },
    );
  }


  Widget _buildQuickSuggestions() {
    final suggestions = ['Mumbai (BOM)', 'Delhi (DEL)', 'Bengaluru (BLR)'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick searches', style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: suggestions.map((s) {
            return ActionChip(
              label: Text(
                s,
                style: TextStyle(color: Colors.black), // text stays visible
              ),
              backgroundColor: Colors.white, // <-- white background
              shape: StadiumBorder(
                side: BorderSide(color: Colors.grey.shade300), // optional border
              ),
              onPressed: () {
                setState(() {
                  _fromCtrl.text = 'Indore (IDR)';
                  _toCtrl.text = s;
                  from = _fromCtrl.text;
                  to = _toCtrl.text;
                });
              },
            );
          }).toList(),
        )
      ],
    );
  }


  // NEW: Ads slider widget
  Widget _buildAdsSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 18),
        Text('Offers for you', style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: 10),
        SizedBox(
          height: 140,
          child: GestureDetector(
            onTapDown: (_) => _stopAdAutoScroll(),
            onTapUp: (_) => _startAdAutoScroll(),
            child: PageView.builder(
              controller: _adController,
              itemCount: _ads.length,
              onPageChanged: (idx) => setState(() => _currentAd = idx),
              itemBuilder: (context, index) {
                final ad = _ads[index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Applied: ${ad.title} — ${ad.subtitle}')),
                      );
                    },
                    child: Card(
                      color: Colors.teal, // <-- custom background color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white, // white avatar bg
                              child: Text(ad.imageEmoji, style: TextStyle(fontSize: 22)),
                              radius: 28,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    ad.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white, // title text color
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    ad.subtitle,
                                    style: TextStyle(color: Colors.white70), // subtitle text
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,   // white button
                                foregroundColor: Colors.black, // text/icon color
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Use code shown at checkout')),
                                );
                              },
                              child: Text('Use'),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: 8),
        // indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_ads.length, (i) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 4),
              width: _currentAd == i ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentAd == i ? Color(0xFF9FB0FF) : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
        ),
        SizedBox(height: 12),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, dd MMM');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.teal,
        title: Text('Search flights',style: TextStyle(color: Colors.white),),
        actions: [
          IconButton(
            icon: Icon(Icons.history,color: Colors.white,),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Recent searches')));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(14),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // From / To row
              Row(
                children: [
                  Expanded(child: _buildAutoCompleteField(controller: _fromCtrl, label: 'From', setter: (v) => from = v)),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.swap_horiz)),
                  Expanded(child: _buildAutoCompleteField(controller: _toCtrl, label: 'To', setter: (v) => to = v)),
                ],
              ),
              SizedBox(height: 12),

              // Date pickers
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Depart'),
                      subtitle: Text(departDate != null ? dateFormat.format(departDate!) : 'Select date'),
                      onTap: () => _pickDate(context, isReturn: false),
                    ),
                  ),
                  if (isRoundTrip)
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('Return'),
                        subtitle: Text(returnDate != null ? dateFormat.format(returnDate!) : 'Select date'),
                        onTap: () => _pickDate(context, isReturn: true),
                      ),
                    )
                ],
              ),

              // Round-trip toggle
              Row(
                children: [
                  Expanded(
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Round trip'),
                      value: isRoundTrip,
                      onChanged: (v) {
                        setState(() {
                          isRoundTrip = v;
                          if (!v) returnDate = null;
                        });
                      },
                    ),
                  ),
                ],
              ),

              ListTile(
                title: Text('Travelers & Cabin'),
                subtitle: Text('$adults A • $children C • $infants I • $cabin'),
                trailing: Icon(Icons.edit),
                onTap: () => _showPassengersDialog(context),
              ),

              SizedBox(height: 18),

              ElevatedButton.icon(
                icon: Icon(Icons.search, color: Colors.white), // icon color
                label: Padding(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                  child: Text(
                    'Search Flights',
                    style: TextStyle(fontSize: 16, color: Colors.white), // text color
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(48),
                  backgroundColor: Colors.teal,   // <-- background color
                  foregroundColor: Colors.white,    // <-- text & icon color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // optional rounded corners
                  ),
                ),
                onPressed: loading
                    ? null
                    : () async {
                  if (_fromCtrl.text.trim().isEmpty || _toCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter From and To')),
                    );
                    return;
                  }
                  setState(() {
                    from = _fromCtrl.text.trim();
                    to = _toCtrl.text.trim();
                  });

                  try {
                    await searchFlights();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                    setState(() => loading = false);
                  }
                },
              ),


              if (loading) Padding(padding: EdgeInsets.only(top: 12), child: LinearProgressIndicator()),

              SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                  child: _buildQuickSuggestions()),

              // NEW: Ads slider inserted here
              _buildAdsSlider(),
            ],
          ),
        ),
      ),
    );
  }
}

/* ---------------------------
   Discount Ad model (local)
   --------------------------- */
class DiscountAd {
  final String title;
  final String subtitle;
  final String imageEmoji; // simple visual

  DiscountAd({required this.title, required this.subtitle, required this.imageEmoji});
}




