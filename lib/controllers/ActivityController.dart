import 'package:get/get.dart';
import 'package:my_pfe/database/db.dart';
import 'dart:developer' as dev;
import 'dart:math';

class ActivityController extends GetxController {
  final SqlDb _sqlDb = SqlDb();
  final RxList<Map<String, dynamic>> speedingEvents =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;

  DateTime? startDate;
  DateTime? endDate;
  final Random _random = Random();

  @override
  void onInit() {
    super.onInit();
    loadSpeedingEvents();
  }

  Future<void> loadSpeedingEvents() async {
    try {
      String query = "SELECT * FROM speeding_event";
      if (startDate != null || endDate != null) {
        query += " WHERE";
        if (startDate != null) {
          query += " eventDateTime >= '${startDate!.toIso8601String()}'";
        }
        if (startDate != null && endDate != null) {
          query += " AND";
        }
        if (endDate != null) {
          query += " eventDateTime <= '${endDate!.toIso8601String()}'";
        }
      }

      final events = await _sqlDb.readData(query);
      dev.log('Filtered Events: $events');

      speedingEvents.value = List<Map<String, dynamic>>.from(
        events.map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (e) {
      dev.log("Error loading events", error: e);
    } finally {
      isLoading.value = false;
    }
  }

  void clearFilters() {
    startDate = null;
    endDate = null;
    loadSpeedingEvents();
  }

  Future<void> setStartDate(DateTime? date) async {
    startDate = date;
    await loadSpeedingEvents();
  }

  Future<void> setEndDate(DateTime? date) async {
    endDate = date;
    await loadSpeedingEvents();
  }

  Future<void> deleteSpeedingEvent(int eventId) async {
    try {
      final db = await _sqlDb.db;
      final result = await db!.delete(
        'speeding_event',
        where: 'eventId = ?',
        whereArgs: [eventId],
      );

      if (result > 0) {
        speedingEvents.removeWhere((event) => event['eventId'] == eventId);
      }
    } catch (e, stackTrace) {
      dev.log('Error deleting event', error: e, stackTrace: stackTrace);
    }
  }

  Future<void> addRandomSpeedingEvent(String userId) async {
    try {
      final now = DateTime.now();
      final randomLat = 34.0 + _random.nextDouble() * 6.0;
      final randomLon = -6.0 + _random.nextDouble() * 6.0;
      final position = '$randomLat,$randomLon';
      final driverSpeed = 60 + _random.nextInt(40);
      final roadSpeedLimit = 50 + _random.nextInt(20);
      final duration = 5 + _random.nextInt(55);

      final db = await _sqlDb.db;
      final eventId = await db!.insert('speeding_event', {
        'eventDateTime': now.toIso8601String(),
        'position': position,
        'driverSpeed': driverSpeed,
        'roadSpeedLimit': roadSpeedLimit,
        'duration': duration,
        'driverId': userId,
      });

      final newEvent = {
        'eventId': eventId,
        'eventDateTime': now.toIso8601String(),
        'position': position,
        'driverSpeed': driverSpeed.toDouble(),
        'roadSpeedLimit': roadSpeedLimit.toDouble(),
        'duration': duration,
        'driverId': userId,
      };

      speedingEvents.add(newEvent);
    } catch (e) {
      dev.log('Error adding random event', error: e);
    }
  }
}
