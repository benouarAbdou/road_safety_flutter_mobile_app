import 'package:flutter/material.dart';
import 'package:my_pfe/database/db.dart';
import 'dart:math';
import 'dart:developer' as dev;

class ActivityPage extends StatefulWidget {
  final String userId;

  const ActivityPage({super.key, required this.userId});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final SqlDb _sqlDb = SqlDb();
  List<Map<String, dynamic>> _speedingEvents = [];
  bool _isLoading = true;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _loadSpeedingEvents();
  }

  Future<void> _loadSpeedingEvents() async {
    try {
      final events = await _sqlDb.readData("SELECT * FROM speeding_event");
      dev.log('Speeding Events: $events');
      setState(() {
        // Create a new mutable list from the events
        _speedingEvents = List<Map<String, dynamic>>.from(
            events.map((e) => Map<String, dynamic>.from(e)));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading speeding events: $e')),
      );
    }
  }

  String _formatPosition(String position) {
    try {
      final parts = position.split(',');
      final lat = double.parse(parts[0]).toStringAsFixed(2);
      final lon = double.parse(parts[1]).toStringAsFixed(2);
      return '$lat,$lon';
    } catch (e) {
      return position;
    }
  }

  Future<void> _deleteSpeedingEvent(int eventId) async {
    try {
      final db = await _sqlDb.db;
      final result = await db!.delete(
        'speeding_event',
        where: 'eventId = ?',
        whereArgs: [eventId],
      );

      if (result > 0) {
        setState(() {
          _speedingEvents.removeWhere((event) => event['eventId'] == eventId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speeding event deleted')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event not found')),
        );
      }
    } catch (e, stackTrace) {
      dev.log('Error deleting event', error: e, stackTrace: stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting event: ${e.toString()}')),
      );
    }
  }

  Future<void> _addRandomSpeedingEvent() async {
    try {
      // Generate random values
      final now = DateTime.now();
      final randomLat = 34.0 + _random.nextDouble() * 6.0;
      final randomLon = -6.0 + _random.nextDouble() * 6.0;
      final position = '$randomLat,$randomLon';
      final driverSpeed = 60 + _random.nextInt(40);
      final roadSpeedLimit = 50 + _random.nextInt(20);
      final duration = 5 + _random.nextInt(55);

      // Insert into database
      final db = await _sqlDb.db;
      final eventId = await db!.insert('speeding_event', {
        'eventDateTime': now.toString(),
        'position': position,
        'driverSpeed': driverSpeed,
        'roadSpeedLimit': roadSpeedLimit,
        'duration': duration,
        'driverId': widget.userId,
      });

      // Update UI - create a new map to ensure it's mutable
      final newEvent = {
        'eventId': eventId,
        'eventDateTime': now.toString(),
        'position': position,
        'driverSpeed': driverSpeed.toDouble(),
        'roadSpeedLimit': roadSpeedLimit.toDouble(),
        'duration': duration,
        'driverId': widget.userId,
      };

      setState(() {
        _speedingEvents = [..._speedingEvents, newEvent];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Random speeding event added')),
      );
    } catch (e) {
      dev.log('Error adding random event', error: e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding random event: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speeding Events'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _speedingEvents.isEmpty
              ? const Center(child: Text('No speeding events found.'))
              : SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DataTable(
                        columnSpacing: 2.0,
                        dataRowHeight: 48.0,
                        columns: const [
                          DataColumn(
                            label: SizedBox(
                              width: 120,
                              child: Text('Date', softWrap: true),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 80,
                              child: Text('Position', softWrap: true),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 60,
                              child: Text('Speed', softWrap: true),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 60,
                              child: Text('Limit', softWrap: true),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 70,
                              child: Text('Duration', softWrap: true),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 60,
                              child: Text('Action', softWrap: true),
                            ),
                          ),
                        ],
                        rows: _speedingEvents.map((event) {
                          return DataRow(cells: [
                            DataCell(
                              SizedBox(
                                width: 110,
                                child: Text(
                                  event['eventDateTime'].toString(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 80,
                                child: Text(
                                  _formatPosition(event['position']),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 60,
                                child: Text(
                                  event['driverSpeed'].toStringAsFixed(1),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 60,
                                child: Text(
                                  event['roadSpeedLimit'].toStringAsFixed(1),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 60,
                                child: Text(
                                  "${event['duration']} s",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 60,
                                child: IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  onPressed: () =>
                                      _deleteSpeedingEvent(event['eventId']),
                                ),
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRandomSpeedingEvent,
        tooltip: 'Add Random Event',
        child: const Icon(Icons.add),
      ),
    );
  }
}
