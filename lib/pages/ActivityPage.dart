import 'package:flutter/material.dart';
import 'package:my_pfe/database/db.dart';

class ActivityPage extends StatefulWidget {
  final String userId;

  const ActivityPage({super.key, required this.userId});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final SqlDb _sqlDb = SqlDb();
  List<Map> _speedingEvents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSpeedingEvents();
  }

  Future<void> _loadSpeedingEvents() async {
    try {
      final events = await _sqlDb.readData("SELECT * FROM speeding_event ");
      setState(() {
        _speedingEvents = events;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _speedingEvents.isEmpty
              ? const Center(child: Text('No speeding events found.'))
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Position')),
                        DataColumn(label: Text('Speed (km/h)')),
                        DataColumn(label: Text('Limit (km/h)')),
                        DataColumn(label: Text('Duration (s)')),
                      ],
                      rows: _speedingEvents.map((event) {
                        return DataRow(cells: [
                          DataCell(Text(event['eventDateTime'].toString())),
                          DataCell(Text(event['position'])),
                          DataCell(
                              Text(event['driverSpeed'].toStringAsFixed(1))),
                          DataCell(
                              Text(event['roadSpeedLimit'].toStringAsFixed(1))),
                          DataCell(Text(event['duration'].toString())),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
    );
  }
}
