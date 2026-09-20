import 'package:flutter/material.dart';
import '../models/tamil_calendar_models.dart';
import '../services/panchanga_provider.dart';

/// Display mode for the monthly calendar
enum CalendarDisplayMode {
  tamilMonth('தமிழ் மாதம் (Tamil Month)'),
  gregorianMonth('ஆங்கில மாதம் (Gregorian Month)');

  final String label;
  const CalendarDisplayMode(this.label);
}

/// Controller for Tamil Monthly Calendar with dual view support:
/// 1. Tamil Month View (சித்திரை..பங்குனி)
/// 2. Gregorian Month View (ஜனவரி..டிசம்பர் - Standard Tamil Calendar Sheet)
class TamilCalendarController extends ChangeNotifier {
  final PanchangaProvider _provider;
  PanchangaLocation _location;

  CalendarDisplayMode _displayMode = CalendarDisplayMode.tamilMonth;
  int _focusedTamilYear;
  int _focusedTamilMonthIndex; // 0..11 (0=Chithirai, ..., 3=Aadi, 4=Aavani, ..., 11=Panguni)
  int _focusedGregorianYear;
  int _focusedGregorianMonth; // 1..12 (1=Jan .. 12=Dec)
  DateTime _selectedDate;
  late TamilMonthData _currentMonthData;

  // In-memory cache for ultra-fast day retrieval (key: YYYY-MM-DD_lat_lon_tz)
  final Map<String, CalendarDay> _cache = {};

  static const List<String> gregorianMonthsTa = [
    'ஜனவரி', 'பிப்ரவரி', 'மார்ச்', 'ஏப்ரல்', 'மே', 'ஜூன்',
    'ஜூலை', 'ஆகஸ்ட்', 'செப்டம்பர்', 'அக்டோபர்', 'நவம்பர்', 'டிசம்பர்'
  ];

  static const List<String> gregorianMonthsEn = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  TamilCalendarController({
    PanchangaProvider? provider,
    PanchangaLocation? initialLocation,
    DateTime? initialDate,
  })  : _provider = provider ?? const AstronomicalPanchangaProvider(),
        _location = initialLocation ?? PanchangaLocation.chennai,
        _selectedDate = initialDate ?? DateTime.now(),
        _focusedTamilYear = (initialDate ?? DateTime.now()).year,
        _focusedTamilMonthIndex = 0,
        _focusedGregorianYear = (initialDate ?? DateTime.now()).year,
        _focusedGregorianMonth = (initialDate ?? DateTime.now()).month {
    final initDt = initialDate ?? DateTime.now();
    final tamilDt = _provider.getTamilDate(initDt, location: _location);
    _focusedTamilYear = tamilDt.tamilYear;
    _focusedTamilMonthIndex = tamilDt.tamilMonthIndex;
    _focusedGregorianYear = initDt.year;
    _focusedGregorianMonth = initDt.month;
    _refreshMonthData();
  }

  // Getters
  CalendarDisplayMode get displayMode => _displayMode;
  PanchangaLocation get location => _location;
  int get focusedTamilYear => _focusedTamilYear;
  int get focusedTamilMonthIndex => _focusedTamilMonthIndex;
  String get focusedTamilMonthName => _currentMonthData.tamilMonth;
  String get focusedTamilYearName => _currentMonthData.tamilYearName;
  TamilMonthData get currentMonthData => _currentMonthData;
  DateTime get focusedMonth => _currentMonthData.startDate;
  DateTime get selectedDate => _selectedDate;
  CalendarDay get selectedCalendarDay => getDayData(_selectedDate);

  int get focusedGregorianYear => _focusedGregorianYear;
  int get focusedGregorianMonth => _focusedGregorianMonth;
  String get focusedGregorianMonthNameTa => gregorianMonthsTa[_focusedGregorianMonth - 1];
  String get focusedGregorianMonthNameEn => gregorianMonthsEn[_focusedGregorianMonth - 1];

  void setDisplayMode(CalendarDisplayMode mode) {
    if (_displayMode != mode) {
      _displayMode = mode;
      notifyListeners();
    }
  }

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

  /// Select a particular Gregorian date and switch month if needed
  void selectDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    _focusedGregorianYear = _selectedDate.year;
    _focusedGregorianMonth = _selectedDate.month;

    final selTamil = _provider.getTamilDate(_selectedDate, location: _location);
    if (_focusedTamilYear != selTamil.tamilYear || _focusedTamilMonthIndex != selTamil.tamilMonthIndex) {
      _focusedTamilYear = selTamil.tamilYear;
      _focusedTamilMonthIndex = selTamil.tamilMonthIndex;
      _refreshMonthData();
    }
    notifyListeners();
  }

  /// Move to previous month (Tamil or Gregorian based on mode)
  void previousMonth() {
    if (_displayMode == CalendarDisplayMode.tamilMonth) {
      if (_focusedTamilMonthIndex > 0) {
        _focusedTamilMonthIndex--;
      } else {
        _focusedTamilMonthIndex = 11;
        _focusedTamilYear--;
      }
      _refreshMonthData();
    } else {
      if (_focusedGregorianMonth > 1) {
        _focusedGregorianMonth--;
      } else {
        _focusedGregorianMonth = 12;
        _focusedGregorianYear--;
      }
    }
    notifyListeners();
  }

  /// Move to next month (Tamil or Gregorian based on mode)
  void nextMonth() {
    if (_displayMode == CalendarDisplayMode.tamilMonth) {
      if (_focusedTamilMonthIndex < 11) {
        _focusedTamilMonthIndex++;
      } else {
        _focusedTamilMonthIndex = 0;
        _focusedTamilYear++;
      }
      _refreshMonthData();
    } else {
      if (_focusedGregorianMonth < 12) {
        _focusedGregorianMonth++;
      } else {
        _focusedGregorianMonth = 1;
        _focusedGregorianYear++;
      }
    }
    notifyListeners();
  }

  /// Jump back to Today's Month & Day
  void goToToday() {
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _focusedGregorianYear = now.year;
    _focusedGregorianMonth = now.month;

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

  /// Get list of all CalendarDays to build the monthly grid with exact weekday alignment (ஞா..ச)
  List<CalendarDay?> getMonthGridDays() {
    if (_displayMode == CalendarDisplayMode.tamilMonth) {
      return _getTamilMonthGridDays();
    } else {
      return _getGregorianMonthGridDays();
    }
  }

  List<CalendarDay?> _getTamilMonthGridDays() {
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

    // 3. Trailing empty cells to complete the 7-column grid (35 or 42 cells)
    final totalCells = gridDays.length;
    final targetCells = totalCells <= 35 ? 35 : (totalCells <= 42 ? 42 : ((totalCells + 6) ~/ 7) * 7);
    final trailingCount = targetCells - totalCells;

    for (int i = 0; i < trailingCount; i++) {
      gridDays.add(null);
    }

    return gridDays;
  }

  List<CalendarDay?> _getGregorianMonthGridDays() {
    final firstDate = DateTime(_focusedGregorianYear, _focusedGregorianMonth, 1);
    final lastDay = DateTime(_focusedGregorianYear, _focusedGregorianMonth + 1, 0).day;

    final firstWeekday = firstDate.weekday;
    final leadingPadding = (firstWeekday == 7) ? 0 : firstWeekday;

    final List<CalendarDay?> gridDays = [];

    // 1. Leading empty cells
    for (int i = 0; i < leadingPadding; i++) {
      gridDays.add(null);
    }

    // 2. All consecutive days of the Gregorian month
    for (int day = 1; day <= lastDay; day++) {
      final curDate = DateTime(_focusedGregorianYear, _focusedGregorianMonth, day);
      gridDays.add(getDayData(curDate));
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
