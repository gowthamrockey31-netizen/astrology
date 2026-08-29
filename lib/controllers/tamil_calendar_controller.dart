import 'package:flutter/material.dart';
import '../models/tamil_calendar_models.dart';
import '../services/panchanga_provider.dart';

/// Controller for Tamil Panchanga Calendar with high-performance caching
class TamilCalendarController extends ChangeNotifier {
  final PanchangaProvider _provider;
  PanchangaLocation _location;
  DateTime _focusedMonth;
  DateTime _selectedDate;

  // In-memory cache for ultra-fast day retrieval (key: YYYY-MM-DD_lat_lon)
  final Map<String, CalendarDay> _cache = {};

  TamilCalendarController({
    PanchangaProvider? provider,
    PanchangaLocation? initialLocation,
    DateTime? initialDate,
  })  : _provider = provider ?? const AstronomicalPanchangaProvider(),
        _location = initialLocation ?? PanchangaLocation.chennai,
        _focusedMonth = DateTime(
          (initialDate ?? DateTime.now()).year,
          (initialDate ?? DateTime.now()).month,
          1,
        ),
        _selectedDate = initialDate ?? DateTime.now();

  // Getters
  PanchangaLocation get location => _location;
  DateTime get focusedMonth => _focusedMonth;
  DateTime get selectedDate => _selectedDate;
  CalendarDay get selectedCalendarDay => getDayData(_selectedDate);

  /// Change user location and clear location-dependent cache entries
  void updateLocation(PanchangaLocation newLocation) {
    if (_location.latitude != newLocation.latitude ||
        _location.longitude != newLocation.longitude ||
        _location.timezone != newLocation.timezone) {
      _location = newLocation;
      _cache.clear();
      notifyListeners();
    }
  }

  /// Select a particular date
  void selectDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    if (_focusedMonth.year != date.year || _focusedMonth.month != date.month) {
      _focusedMonth = DateTime(date.year, date.month, 1);
    }
    notifyListeners();
  }

  /// Move to previous month
  void previousMonth() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    notifyListeners();
  }

  /// Move to next month
  void nextMonth() {
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    notifyListeners();
  }

  /// Jump back to Today
  void goToToday() {
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _focusedMonth = DateTime(now.year, now.month, 1);
    notifyListeners();
  }

  /// Move selected day by offset
  void changeDay(int daysOffset) {
    _selectedDate = _selectedDate.add(Duration(days: daysOffset));
    if (_focusedMonth.year != _selectedDate.year || _focusedMonth.month != _selectedDate.month) {
      _focusedMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    }
    notifyListeners();
  }

  /// Get single day data with caching
  CalendarDay getDayData(DateTime date) {
    final key = _cacheKey(date, _location);
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }
    final data = _provider.calculateSync(date: date, location: _location);
    _cache[key] = data;
    return data;
  }

  /// Get list of all CalendarDays to build the monthly grid (including leading/trailing padding for Sunday..Saturday)
  List<CalendarDay> getMonthGridDays() {
    final year = _focusedMonth.year;
    final month = _focusedMonth.month;

    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // Sunday = 7 in DateTime.weekday. For Sunday-first header (ஞா=0, தி=1, ..., ச=6):
    // If weekday is 7 (Sun), leading padding is 0. If 1 (Mon), padding is 1, etc.
    final firstWeekday = firstDayOfMonth.weekday; // 1=Mon .. 7=Sun
    final leadingPadding = (firstWeekday == 7) ? 0 : firstWeekday;

    final List<CalendarDay> gridDays = [];

    // 1. Leading days from previous month
    for (int i = leadingPadding; i > 0; i--) {
      final prevDate = firstDayOfMonth.subtract(Duration(days: i));
      gridDays.add(getDayData(prevDate));
    }

    // 2. Current month days
    for (int day = 1; day <= daysInMonth; day++) {
      final curDate = DateTime(year, month, day);
      gridDays.add(getDayData(curDate));
    }

    // 3. Trailing days to complete standard 7-column grid (up to 35 or 42 cells)
    final totalCells = gridDays.length;
    final targetCells = totalCells <= 35 ? 35 : 42;
    final trailingCount = targetCells - totalCells;
    final lastDayOfMonth = DateTime(year, month, daysInMonth);

    for (int i = 1; i <= trailingCount; i++) {
      final nextDate = lastDayOfMonth.add(Duration(days: i));
      gridDays.add(getDayData(nextDate));
    }

    return gridDays;
  }

  /// Helper to get prominent Tamil month name for the focused month
  String getFocusedTamilMonthName() {
    // Check 15th of the focused month for the central Tamil month name
    final midMonthDate = DateTime(_focusedMonth.year, _focusedMonth.month, 15);
    final midData = getDayData(midMonthDate);
    return midData.tamilMonth;
  }

  static String _cacheKey(DateTime dt, PanchangaLocation loc) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}_${loc.latitude.toStringAsFixed(3)}_${loc.longitude.toStringAsFixed(3)}';
  }
}
