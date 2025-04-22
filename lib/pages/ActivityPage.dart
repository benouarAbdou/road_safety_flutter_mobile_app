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
      initialDate: isStartDate
          ? controller.startDate ?? DateTime.now()
          : controller.endDate ?? DateTime.now(),
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

  void _showDeleteConfirmation(BuildContext context, int eventId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text(
              'Are you sure you want to delete this speeding event?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Cancel
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                controller.deleteSpeedingEvent(eventId); // Proceed with delete
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDateChip(
      DateTime? date, VoidCallback onTap, VoidCallback onClear, String label) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(date != null ? DateFormat('MMM d').format(date) : label),
        deleteIcon: date != null ? const Icon(Icons.close, size: 18) : null,
        onDeleted: date != null ? onClear : null,
        backgroundColor: date != null
            ? Theme.of(Get.context!).colorScheme.primary.withOpacity(0.1)
            : null,
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: date != null
                ? Theme.of(Get.context!).colorScheme.primary
                : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speeding Events'),
      ),
      body: Obx(() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Filter Section
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter by date range',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildDateChip(
                        controller.startDate,
                        () => _selectDate(context, true),
                        () => controller.setStartDate(null),
                        'Start Date',
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('to'),
                      ),
                      _buildDateChip(
                        controller.endDate,
                        () => _selectDate(context, false),
                        () => controller.setEndDate(null),
                        'End Date',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Data Table
            Expanded(
              child: controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : controller.speedingEvents.isEmpty
                      ? const Center(
                          child: Text(
                            'No speeding events found',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          physics: const BouncingScrollPhysics(),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: DataTable(
                                columnSpacing: 16.0,
                                dataRowHeight: 48.0,
                                headingTextStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                columns: const [
                                  DataColumn(label: Text('Date', maxLines: 1)),
                                  DataColumn(
                                      label: Text('Position', maxLines: 1)),
                                  DataColumn(label: Text('Speed', maxLines: 1)),
                                  DataColumn(label: Text('Limit', maxLines: 1)),
                                  DataColumn(
                                      label: Text('Duration', maxLines: 1)),
                                  DataColumn(
                                      label: Text('Action', maxLines: 1)),
                                ],
                                rows: controller.speedingEvents.map((event) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(
                                        DateFormat('MMM d, HH:mm').format(
                                            DateTime.parse(
                                                event['eventDateTime'])),
                                      )),
                                      DataCell(Text(
                                          _formatPosition(event['position']))),
                                      DataCell(Text(event['driverSpeed']
                                          .toStringAsFixed(1))),
                                      DataCell(Text(event['roadSpeedLimit']
                                          .toStringAsFixed(1))),
                                      DataCell(Text("${event['duration']} s")),
                                      DataCell(
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              size: 20, color: Colors.red),
                                          onPressed: () =>
                                              _showDeleteConfirmation(
                                                  context, event['eventId']),
                                        ),
                                      ),
                                    ],
                                  );
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
