import 'package:flutter_test/flutter_test.dart';
import 'package:astrocall/services/geocoding_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Geocoding Location Suggestions & Matching Tests', () {
    test('Offline search matches exact and multi-word queries with state abbreviations', () {
      final mumbaiResults = GeocodingService.searchOffline('Mumbai, MH');
      expect(mumbaiResults.isNotEmpty, isTrue);
      expect(mumbaiResults.first.cityName, 'Mumbai');
      expect(mumbaiResults.first.state, 'Maharashtra');

      final chennaiResults = GeocodingService.searchOffline('Chennai, TN');
      expect(chennaiResults.isNotEmpty, isTrue);
      expect(chennaiResults.first.cityName, 'Chennai');

      final chinnalapattiResults = GeocodingService.searchOffline('Chinnalapatti');
      expect(chinnalapattiResults.isNotEmpty, isTrue);
      expect(chinnalapattiResults.first.cityName, 'Chinnalapatti');
    });

    test('Offline search returns popular suggestions for empty query', () {
      final emptyResults = GeocodingService.searchOffline('');
      expect(emptyResults.length, greaterThanOrEqualTo(5));
    });

    test('Resolve place correctly resolves known cities', () {
      final loc = GeocodingService.resolvePlace('Madurai');
      expect(loc, isNotNull);
      expect(loc!.latitude, closeTo(9.9252, 0.01));
      expect(loc.longitude, closeTo(78.1198, 0.01));
    });

    test('SearchStates returns all 28 states and UTs and filters correctly', () {
      final allStates = GeocodingService.searchStates('');
      expect(allStates.length, greaterThanOrEqualTo(36));

      final tn = GeocodingService.searchStates('Tamil Nadu');
      expect(tn.isNotEmpty, isTrue);
      expect(tn.first.name, 'Tamil Nadu');
      expect(tn.first.capital, 'Chennai');

      final mh = GeocodingService.searchStates('மகாராஷ்டிரா');
      expect(mh.isNotEmpty, isTrue);
      expect(mh.first.name, 'Maharashtra');

      final up = GeocodingService.searchStates('UP');
      expect(up.isNotEmpty, isTrue);
      expect(up.first.name, 'Uttar Pradesh');
    });

    test('SearchCities filters all India cities with state filter support', () {
      final puneCities = GeocodingService.searchCities('Pune');
      expect(puneCities.isNotEmpty, isTrue);
      expect(puneCities.first.cityName, 'Pune');
      expect(puneCities.first.state, 'Maharashtra');

      final tnCities = GeocodingService.searchCities('', stateFilter: 'Tamil Nadu');
      expect(tnCities.isNotEmpty, isTrue);
      expect(tnCities.every((c) => c.state == 'Tamil Nadu'), isTrue);
    });
  });
}
