import 'dart:convert';
import 'package:http/http.dart' as http;

/// Location result representing resolved coordinates and timezone
class GeocodingLocation {
  final String cityName;
  final String displayName;
  final String state;
  final String country;
  final double latitude;
  final double longitude;
  final double timezone;

  const GeocodingLocation({
    required this.cityName,
    required this.displayName,
    required this.state,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  @override
  String toString() => '$displayName ($latitude, $longitude)';
}

/// Robust Geocoding & Place Resolution Service for AstroDashaCare
class GeocodingService {
  /// Extensive built-in offline repository of Tamil Nadu, Indian, and Global cities
  static const List<GeocodingLocation> _offlineLocations = [
    // Tamil Nadu Major Cities & Towns
    GeocodingLocation(cityName: 'Chennai', displayName: 'Chennai, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 13.0827, longitude: 80.2707, timezone: 5.5),
    GeocodingLocation(cityName: 'Coimbatore', displayName: 'Coimbatore, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 11.0168, longitude: 76.9558, timezone: 5.5),
    GeocodingLocation(cityName: 'Madurai', displayName: 'Madurai, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 9.9252, longitude: 78.1198, timezone: 5.5),
    GeocodingLocation(cityName: 'Tiruchirappalli', displayName: 'Tiruchirappalli (Trichy), Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 10.7905, longitude: 78.7047, timezone: 5.5),
    GeocodingLocation(cityName: 'Salem', displayName: 'Salem, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 11.6643, longitude: 78.1460, timezone: 5.5),
    GeocodingLocation(cityName: 'Tirunelveli', displayName: 'Tirunelveli, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 8.7139, longitude: 77.7567, timezone: 5.5),
    GeocodingLocation(cityName: 'Tiruppur', displayName: 'Tiruppur, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 11.1085, longitude: 77.3411, timezone: 5.5),
    GeocodingLocation(cityName: 'Erode', displayName: 'Erode, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 11.3410, longitude: 77.7172, timezone: 5.5),
    GeocodingLocation(cityName: 'Vellore', displayName: 'Vellore, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 12.9165, longitude: 79.1325, timezone: 5.5),
    GeocodingLocation(cityName: 'Thoothukudi', displayName: 'Thoothukudi (Tuticorin), Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 8.7642, longitude: 78.1348, timezone: 5.5),
    GeocodingLocation(cityName: 'Dindigul', displayName: 'Dindigul, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 10.3673, longitude: 77.9803, timezone: 5.5),
    GeocodingLocation(cityName: 'Thanjavur', displayName: 'Thanjavur (Tanjore), Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 10.7870, longitude: 79.1378, timezone: 5.5),
    GeocodingLocation(cityName: 'Ranipet', displayName: 'Ranipet, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 12.9272, longitude: 79.3323, timezone: 5.5),
    GeocodingLocation(cityName: 'Sivakasi', displayName: 'Sivakasi, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 9.4533, longitude: 77.7979, timezone: 5.5),
    GeocodingLocation(cityName: 'Karur', displayName: 'Karur, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 10.9601, longitude: 78.0766, timezone: 5.5),
    GeocodingLocation(cityName: 'Udhagamandalam', displayName: 'Ooty (Udhagamandalam), Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 11.4102, longitude: 76.6950, timezone: 5.5),
    GeocodingLocation(cityName: 'Hosur', displayName: 'Hosur, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 12.7409, longitude: 77.8253, timezone: 5.5),
    GeocodingLocation(cityName: 'Nagercoil', displayName: 'Nagercoil, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 8.1833, longitude: 77.4119, timezone: 5.5),
    GeocodingLocation(cityName: 'Kanchipuram', displayName: 'Kanchipuram, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 12.8342, longitude: 79.7036, timezone: 5.5),
    GeocodingLocation(cityName: 'Kumarapalayam', displayName: 'Kumarapalayam, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 11.4426, longitude: 77.7121, timezone: 5.5),
    GeocodingLocation(cityName: 'Karaikkudi', displayName: 'Karaikudi, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 10.0735, longitude: 78.7732, timezone: 5.5),
    GeocodingLocation(cityName: 'Neyveli', displayName: 'Neyveli, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 11.6105, longitude: 79.4862, timezone: 5.5),
    GeocodingLocation(cityName: 'Cuddalore', displayName: 'Cuddalore, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 11.7480, longitude: 79.7714, timezone: 5.5),
    GeocodingLocation(cityName: 'Kumbakonam', displayName: 'Kumbakonam, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 10.9602, longitude: 79.3845, timezone: 5.5),
    GeocodingLocation(cityName: 'Tiruvannamalai', displayName: 'Tiruvannamalai, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 12.2253, longitude: 79.0747, timezone: 5.5),
    GeocodingLocation(cityName: 'Pollachi', displayName: 'Pollachi, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 10.6580, longitude: 77.0084, timezone: 5.5),
    GeocodingLocation(cityName: 'Rajapalayam', displayName: 'Rajapalayam, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 9.4533, longitude: 77.5533, timezone: 5.5),
    GeocodingLocation(cityName: 'Gudiyatham', displayName: 'Gudiyatham, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 12.9461, longitude: 78.8687, timezone: 5.5),
    GeocodingLocation(cityName: 'Pudukkottai', displayName: 'Pudukkottai, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 10.3797, longitude: 78.8208, timezone: 5.5),
    GeocodingLocation(cityName: 'Vaniyambadi', displayName: 'Vaniyambadi, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 12.6825, longitude: 78.6202, timezone: 5.5),
    GeocodingLocation(cityName: 'Ambur', displayName: 'Ambur, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 12.7904, longitude: 78.7166, timezone: 5.5),
    GeocodingLocation(cityName: 'Nagapattinam', displayName: 'Nagapattinam, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 10.7672, longitude: 79.8449, timezone: 5.5),
    GeocodingLocation(cityName: 'Villupuram', displayName: 'Villupuram, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 11.9401, longitude: 79.4861, timezone: 5.5),
    GeocodingLocation(cityName: 'Pondicherry', displayName: 'Puducherry (Pondicherry), India', state: 'Puducherry', country: 'India', latitude: 11.9416, longitude: 79.8083, timezone: 5.5),
    GeocodingLocation(cityName: 'Rameswaram', displayName: 'Rameswaram, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 9.2876, longitude: 79.3129, timezone: 5.5),
    GeocodingLocation(cityName: 'Kanyakumari', displayName: 'Kanyakumari, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 8.0883, longitude: 77.5385, timezone: 5.5),
    GeocodingLocation(cityName: 'Chidambaram', displayName: 'Chidambaram, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 11.3992, longitude: 79.6936, timezone: 5.5),
    GeocodingLocation(cityName: 'Palani', displayName: 'Palani, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 10.4503, longitude: 77.5204, timezone: 5.5),
    GeocodingLocation(cityName: 'Mayiladuthurai', displayName: 'Mayiladuthurai, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 11.1018, longitude: 79.6522, timezone: 5.5),
    GeocodingLocation(cityName: 'Theni', displayName: 'Theni, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 10.0104, longitude: 77.4768, timezone: 5.5),
    GeocodingLocation(cityName: 'Dharmapuri', displayName: 'Dharmapuri, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 12.1211, longitude: 78.1582, timezone: 5.5),
    GeocodingLocation(cityName: 'Krishnagiri', displayName: 'Krishnagiri, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 12.5186, longitude: 78.2138, timezone: 5.5),
    GeocodingLocation(cityName: 'Namakkal', displayName: 'Namakkal, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 11.2189, longitude: 78.1674, timezone: 5.5),
    GeocodingLocation(cityName: 'Perambalur', displayName: 'Perambalur, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 11.2342, longitude: 78.8816, timezone: 5.5),
    GeocodingLocation(cityName: 'Ariyalur', displayName: 'Ariyalur, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 11.1401, longitude: 79.0786, timezone: 5.5),
    GeocodingLocation(cityName: 'Tiruvallur', displayName: 'Tiruvallur, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 13.1231, longitude: 79.9120, timezone: 5.5),
    GeocodingLocation(cityName: 'Chengalpattu', displayName: 'Chengalpattu, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 12.6841, longitude: 79.9836, timezone: 5.5),
    GeocodingLocation(cityName: 'Kallakurichi', displayName: 'Kallakurichi, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 11.7383, longitude: 78.9639, timezone: 5.5),
    GeocodingLocation(cityName: 'Tenkasi', displayName: 'Tenkasi, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 8.9594, longitude: 77.3152, timezone: 5.5),

    // Major Indian Metropolitan Cities
    GeocodingLocation(cityName: 'Bengaluru', displayName: 'Bengaluru (Bangalore), Karnataka, India', state: 'Karnataka', country: 'India', latitude: 12.9716, longitude: 77.5946, timezone: 5.5),
    GeocodingLocation(cityName: 'Hyderabad', displayName: 'Hyderabad, Telangana, India', state: 'Telangana', country: 'India', latitude: 17.3850, longitude: 78.4867, timezone: 5.5),
    GeocodingLocation(cityName: 'Mumbai', displayName: 'Mumbai (Bombay), Maharashtra, India', state: 'Maharashtra', country: 'India', latitude: 19.0760, longitude: 72.8777, timezone: 5.5),
    GeocodingLocation(cityName: 'New Delhi', displayName: 'New Delhi (Delhi), India', state: 'Delhi', country: 'India', latitude: 28.6139, longitude: 77.2090, timezone: 5.5),
    GeocodingLocation(cityName: 'Kolkata', displayName: 'Kolkata (Calcutta), West Bengal, India', state: 'West Bengal', country: 'India', latitude: 22.5726, longitude: 88.3639, timezone: 5.5),
    GeocodingLocation(cityName: 'Pune', displayName: 'Pune, Maharashtra, India', state: 'Maharashtra', country: 'India', latitude: 18.5204, longitude: 73.8567, timezone: 5.5),
    GeocodingLocation(cityName: 'Ahmedabad', displayName: 'Ahmedabad, Gujarat, India', state: 'Gujarat', country: 'India', latitude: 23.0225, longitude: 72.5714, timezone: 5.5),
    GeocodingLocation(cityName: 'Jaipur', displayName: 'Jaipur, Rajasthan, India', state: 'Rajasthan', country: 'India', latitude: 26.9124, longitude: 75.7873, timezone: 5.5),
    GeocodingLocation(cityName: 'Kochi', displayName: 'Kochi (Cochin), Kerala, India', state: 'Kerala', country: 'India', latitude: 9.9312, longitude: 76.2673, timezone: 5.5),
    GeocodingLocation(cityName: 'Thiruvananthapuram', displayName: 'Thiruvananthapuram (Trivandrum), Kerala, India', state: 'Kerala', country: 'India', latitude: 8.5241, longitude: 76.9366, timezone: 5.5),
    GeocodingLocation(cityName: 'Kozhikode', displayName: 'Kozhikode (Calicut), Kerala, India', state: 'Kerala', country: 'India', latitude: 11.2588, longitude: 75.7804, timezone: 5.5),
    GeocodingLocation(cityName: 'Visakhapatnam', displayName: 'Visakhapatnam (Vizag), Andhra Pradesh, India', state: 'Andhra Pradesh', country: 'India', latitude: 17.6868, longitude: 83.2185, timezone: 5.5),
    GeocodingLocation(cityName: 'Vijayawada', displayName: 'Vijayawada, Andhra Pradesh, India', state: 'Andhra Pradesh', country: 'India', latitude: 16.5062, longitude: 80.6480, timezone: 5.5),
    GeocodingLocation(cityName: 'Tirupati', displayName: 'Tirupati, Andhra Pradesh, India', state: 'Andhra Pradesh', country: 'India', latitude: 13.6288, longitude: 79.4192, timezone: 5.5),
    GeocodingLocation(cityName: 'Mysuru', displayName: 'Mysuru (Mysore), Karnataka, India', state: 'Karnataka', country: 'India', latitude: 12.2958, longitude: 76.6394, timezone: 5.5),

    // Major International Cities (Tamil Diaspora & Global)
    GeocodingLocation(cityName: 'Singapore', displayName: 'Singapore, Republic of Singapore', state: 'Singapore', country: 'Singapore', latitude: 1.3521, longitude: 103.8198, timezone: 8.0),
    GeocodingLocation(cityName: 'Kuala Lumpur', displayName: 'Kuala Lumpur, Malaysia', state: 'Kuala Lumpur', country: 'Malaysia', latitude: 3.1390, longitude: 101.6869, timezone: 8.0),
    GeocodingLocation(cityName: 'Colombo', displayName: 'Colombo, Sri Lanka', state: 'Western Province', country: 'Sri Lanka', latitude: 6.9271, longitude: 79.8612, timezone: 5.5),
    GeocodingLocation(cityName: 'Jaffna', displayName: 'Jaffna, Sri Lanka', state: 'Northern Province', country: 'Sri Lanka', latitude: 9.6615, longitude: 80.0255, timezone: 5.5),
    GeocodingLocation(cityName: 'Dubai', displayName: 'Dubai, United Arab Emirates', state: 'Dubai', country: 'United Arab Emirates', latitude: 25.2048, longitude: 55.2708, timezone: 4.0),
    GeocodingLocation(cityName: 'Abu Dhabi', displayName: 'Abu Dhabi, United Arab Emirates', state: 'Abu Dhabi', country: 'United Arab Emirates', latitude: 24.4539, longitude: 54.3773, timezone: 4.0),
    GeocodingLocation(cityName: 'London', displayName: 'London, Greater London, United Kingdom', state: 'England', country: 'United Kingdom', latitude: 51.5074, longitude: -0.1278, timezone: 0.0),
    GeocodingLocation(cityName: 'New York', displayName: 'New York City, NY, USA', state: 'New York', country: 'United States', latitude: 40.7128, longitude: -74.0060, timezone: -5.0),
    GeocodingLocation(cityName: 'San Francisco', displayName: 'San Francisco, CA, USA', state: 'California', country: 'United States', latitude: 37.7749, longitude: -122.4194, timezone: -8.0),
    GeocodingLocation(cityName: 'Toronto', displayName: 'Toronto, Ontario, Canada', state: 'Ontario', country: 'Canada', latitude: 43.6532, longitude: -79.3832, timezone: -5.0),
    GeocodingLocation(cityName: 'Sydney', displayName: 'Sydney, NSW, Australia', state: 'New South Wales', country: 'Australia', latitude: -33.8688, longitude: 151.2093, timezone: 10.0),
    GeocodingLocation(cityName: 'Melbourne', displayName: 'Melbourne, Victoria, Australia', state: 'Victoria', country: 'Australia', latitude: -37.8136, longitude: 144.9631, timezone: 10.0),
    GeocodingLocation(cityName: 'Paris', displayName: 'Paris, France', state: 'Île-de-France', country: 'France', latitude: 48.8566, longitude: 2.3522, timezone: 1.0),
    GeocodingLocation(cityName: 'Tokyo', displayName: 'Tokyo, Japan', state: 'Tokyo', country: 'Japan', latitude: 35.6762, longitude: 139.6503, timezone: 9.0),
  ];

  /// Fast offline matching suggestions based on user query
  static List<GeocodingLocation> searchOffline(String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return _offlineLocations.take(10).toList();

    return _offlineLocations.where((loc) {
      return loc.cityName.toLowerCase().contains(clean) ||
          loc.displayName.toLowerCase().contains(clean) ||
          loc.state.toLowerCase().contains(clean) ||
          loc.country.toLowerCase().contains(clean);
    }).take(10).toList();
  }

  /// Resolve location with fast offline fallback and optional online Nominatim lookup
  static Future<List<GeocodingLocation>> searchPlaces(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return _offlineLocations.take(10).toList();

    // 1. First search internal offline dictionary
    final offlineResults = searchOffline(clean);
    if (offlineResults.isNotEmpty && offlineResults.length >= 3) {
      return offlineResults;
    }

    // 2. If online and query has >= 3 chars, attempt live lookup
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(clean)}&format=json&addressdetails=1&limit=5',
      );
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'AstroDashaCare-Astrology-App/2.0'},
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<GeocodingLocation> onlineResults = [];

        for (final item in data) {
          final lat = double.tryParse(item['lat']?.toString() ?? '');
          final lon = double.tryParse(item['lon']?.toString() ?? '');
          if (lat != null && lon != null) {
            final name = item['name'] as String? ?? clean;
            final displayName = item['display_name'] as String? ?? name;
            final address = item['address'] as Map<String, dynamic>? ?? {};
            final state = address['state'] as String? ?? '';
            final country = address['country'] as String? ?? '';

            // Approximate timezone from longitude (7.5 degrees per 30 mins)
            final approxTz = (lon / 15.0).roundToDouble();

            onlineResults.add(GeocodingLocation(
              cityName: name,
              displayName: displayName,
              state: state,
              country: country,
              latitude: lat,
              longitude: lon,
              timezone: country.toLowerCase().contains('india') ? 5.5 : approxTz,
            ));
          }
        }

        if (onlineResults.isNotEmpty) {
          final Set<String> existingNames = offlineResults.map((e) => e.cityName.toLowerCase()).toSet();
          final combined = [...offlineResults];
          for (final onLoc in onlineResults) {
            if (!existingNames.contains(onLoc.cityName.toLowerCase())) {
              combined.add(onLoc);
            }
          }
          return combined;
        }
      }
    } catch (_) {
      // Offline / network timeout fallback
    }

    return offlineResults;
  }

  /// Resolve place name to a single exact or best matching location
  static GeocodingLocation? resolvePlace(String placeName) {
    final clean = placeName.trim().toLowerCase();
    for (final loc in _offlineLocations) {
      if (loc.cityName.toLowerCase() == clean || loc.displayName.toLowerCase().startsWith(clean)) {
        return loc;
      }
    }
    return null;
  }
}
