import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_pfe/controllers/ActivityController.dart';
import 'package:intl/intl.dart';

class ActivityPage extends StatelessWidget {
  final String userId;

  ActivityPage({super.key, required this.userId});

  final ActivityController controller = Get.put(ActivityController());

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

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      if (isStartDate) {
        await controller.setStartDate(picked);
      } else {
        await controller.setEndDate(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Speeding Events')),
      body: Obx(() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Button Wrap
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8.0, // Horizontal spacing between buttons
                runSpacing: 8.0, // Vertical spacing between lines
                children: [
                  ElevatedButton(
                    onPressed: () => _selectDate(context, true),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    child: Text(controller.startDate != null
                        ? DateFormat('yyyy-MM-dd').format(controller.startDate!)
                        : 'Start Date'),
                  ),
                  ElevatedButton(
                    onPressed: () => _selectDate(context, false),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    child: Text(controller.endDate != null
                        ? DateFormat('yyyy-MM-dd').format(controller.endDate!)
                        : 'End Date'),
                  ),
                  TextButton(
                    onPressed: () => controller.clearFilters(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    child: const Text('Clear Filters'),
                  ),
                  /*ElevatedButton(
                    onPressed: () => controller.addRandomSpeedingEvent(userId),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    child: const Text('Add Random Event'),
                  ),*/
                ],
              ),
            ),
            // Display Selected Dates

            // Data Table
            Expanded(
              child: controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : controller.speedingEvents.isEmpty
                      ? const Center(child: Text('No speeding events found.'))
                      : SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          physics: const BouncingScrollPhysics(),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DataTable(
                                columnSpacing: 2.0,
                                dataRowHeight: 48.0,
                                columns: const [
                                  DataColumn(
                                      label: SizedBox(
                                          width: 120, child: Text('Date'))),
                                  DataColumn(
                                      label: SizedBox(
                                          width: 80, child: Text('Position'))),
                                  DataColumn(
                                      label: SizedBox(
                                          width: 60, child: Text('Speed'))),
                                  DataColumn(
                                      label: SizedBox(
                                          width: 60, child: Text('Limit'))),
                                  DataColumn(
                                      label: SizedBox(
                                          width: 70, child: Text('Duration'))),
                                  DataColumn(
                                      label: SizedBox(
                                          width: 60, child: Text('Action'))),
                                ],
                                rows: controller.speedingEvents.map((event) {
                                  return DataRow(cells: [
                                    DataCell(SizedBox(
                                        width: 110,
                                        child: Text(event['eventDateTime']
                                            .toString()))),
                                    DataCell(SizedBox(
                                        width: 80,
                                        child: Text(_formatPosition(
                                            event['position'])))),
                                    DataCell(SizedBox(
                                        width: 60,
                                        child: Text(event['driverSpeed']
                                            .toStringAsFixed(1)))),
                                    DataCell(SizedBox(
                                        width: 60,
                                        child: Text(event['roadSpeedLimit']
                                            .toStringAsFixed(1)))),
                                    DataCell(SizedBox(
                                        width: 60,
                                        child: Text("${event['duration']} s"))),
                                    DataCell(SizedBox(
                                      width: 60,
                                      child: IconButton(
                                        icon:
                                            const Icon(Icons.delete, size: 20),
                                        onPressed: () =>
                                            controller.deleteSpeedingEvent(
                                                event['eventId']),
                                      ),
                                    )),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        );
      }),
    );
  }
}
