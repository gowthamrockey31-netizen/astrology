import 'package:flutter/material.dart';
import '../models/tamil_calendar_models.dart';
import '../services/panchanga_provider.dart';

/// Controller for Tamil Monthly Calendar starting strictly from Tamil Month Day 1
class TamilCalendarController extends ChangeNotifier {
  final PanchangaProvider _provider;
  PanchangaLocation _location;

  int _focusedTamilYear;
  int _focusedTamilMonthIndex; // 0..11 (0=Chithirai, ..., 3=Aadi, 4=Aavani, ..., 11=Panguni)
  DateTime _selectedDate;
  late TamilMonthData _currentMonthData;

  // In-memory cache for ultra-fast day retrieval (key: YYYY-MM-DD_lat_lon_tz)
  final Map<String, CalendarDay> _cache = {};

  TamilCalendarController({
    PanchangaProvider? provider,
    PanchangaLocation? initialLocation,
    DateTime? initialDate,
  })  : _provider = provider ?? const AstronomicalPanchangaProvider(),
        _location = initialLocation ?? PanchangaLocation.chennai,
        _selectedDate = initialDate ?? DateTime.now(),
        _focusedTamilYear = (initialDate ?? DateTime.now()).year,
        _focusedTamilMonthIndex = 0 {
    final initDt = initialDate ?? DateTime.now();
    final tamilDt = _provider.getTamilDate(initDt, location: _location);
    _focusedTamilYear = tamilDt.tamilYear;
    _focusedTamilMonthIndex = tamilDt.tamilMonthIndex;
    _refreshMonthData();
  }

  // Getters
  PanchangaLocation get location => _location;
  int get focusedTamilYear => _focusedTamilYear;
  int get focusedTamilMonthIndex => _focusedTamilMonthIndex;
  String get focusedTamilMonthName => _currentMonthData.tamilMonth;
  String get focusedTamilYearName => _currentMonthData.tamilYearName;
  TamilMonthData get currentMonthData => _currentMonthData;
  DateTime get focusedMonth => _currentMonthData.startDate;
  DateTime get selectedDate => _selectedDate;
  CalendarDay get selectedCalendarDay => getDayData(_selectedDate);

  void _refreshMonthData() {
    _currentMonthData = _provider.getTamilMonthData(
      tamilYear: _focusedTamilYear,
      tamilMonthIndex: _focusedTamilMonthIndex,
      location: _location,
    );
  }

  /// Change user location and clear location-dependent cache entries
  void updateLocation(PanchangaLocation newLocation) {
    if (_location.latitude != newLocation.latitude ||
        _location.longitude != newLocation.longitude ||
        _location.timezone != newLocation.timezone) {
      _location = newLocation;
      _cache.clear();
      _refreshMonthData();
      notifyListeners();
    }
  }

  /// Select a particular Gregorian date and switch Tamil month if needed
  void selectDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    final selTamil = _provider.getTamilDate(_selectedDate, location: _location);
    if (_focusedTamilYear != selTamil.tamilYear || _focusedTamilMonthIndex != selTamil.tamilMonthIndex) {
      _focusedTamilYear = selTamil.tamilYear;
      _focusedTamilMonthIndex = selTamil.tamilMonthIndex;
      _refreshMonthData();
    }
    notifyListeners();
  }

  /// Move to previous Tamil month (e.g. ஆவணி -> ஆடி)
  void previousMonth() {
    if (_focusedTamilMonthIndex > 0) {
      _focusedTamilMonthIndex--;
    } else {
      _focusedTamilMonthIndex = 11;
      _focusedTamilYear--;
    }
    _refreshMonthData();
    notifyListeners();
  }

  /// Move to next Tamil month (e.g. ஆடி -> ஆவணி)
  void nextMonth() {
    if (_focusedTamilMonthIndex < 11) {
      _focusedTamilMonthIndex++;
    } else {
      _focusedTamilMonthIndex = 0;
      _focusedTamilYear++;
    }
    _refreshMonthData();
    notifyListeners();
  }

  /// Jump back to Today's Tamil Month & Day
  void goToToday() {
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    final todayTamil = _provider.getTamilDate(_selectedDate, location: _location);
    _focusedTamilYear = todayTamil.tamilYear;
    _focusedTamilMonthIndex = todayTamil.tamilMonthIndex;
    _refreshMonthData();
    notifyListeners();
  }

  /// Move selected day by offset
  void changeDay(int daysOffset) {
    selectDate(_selectedDate.add(Duration(days: daysOffset)));
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

  /// Get list of all CalendarDays to build the monthly grid starting at Tamil Month Day 1
  /// with leading null slots to align Day 1 under its actual weekday column (ஞா..ச)
  List<CalendarDay?> getMonthGridDays() {
    final daysInMonth = _currentMonthData.days;
    if (daysInMonth.isEmpty) return [];

    final firstDay = daysInMonth.first;
    // Sunday = 7 in DateTime.weekday. For Sunday-first header (ஞா=0, தி=1, ..., ச=6):
    final firstWeekday = firstDay.date.weekday;
    final leadingPadding = (firstWeekday == 7) ? 0 : firstWeekday;

    final List<CalendarDay?> gridDays = [];

    // 1. Leading empty cells before Tamil Day 1 to preserve exact weekday alignment
    for (int i = 0; i < leadingPadding; i++) {
      gridDays.add(null);
    }

    // 2. All consecutive Tamil Month days (Day 1..N)
    for (final day in daysInMonth) {
      gridDays.add(day);
    }

    // 3. Trailing empty cells to complete the 7-column grid
    final totalCells = gridDays.length;
    final targetCells = totalCells <= 35 ? 35 : (totalCells <= 42 ? 42 : ((totalCells + 6) ~/ 7) * 7);
    final trailingCount = targetCells - totalCells;

    for (int i = 0; i < trailingCount; i++) {
      gridDays.add(null);
    }

    return gridDays;
  }

  /// Helper to get prominent Tamil month name for focused month
  String getFocusedTamilMonthName() {
    return _currentMonthData.tamilMonth;
  }

  static String _cacheKey(DateTime dt, PanchangaLocation loc) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}_${loc.latitude.toStringAsFixed(3)}_${loc.longitude.toStringAsFixed(3)}_${loc.timezone}';
  }
}
