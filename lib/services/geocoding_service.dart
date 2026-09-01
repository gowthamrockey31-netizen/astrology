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

/// Model representing an Indian State or Union Territory
class IndianState {
  final String name;
  final String nameTamil;
  final String capital;
  final String code;
  final double latitude;
  final double longitude;
  final bool isUnionTerritory;

  const IndianState({
    required this.name,
    required this.nameTamil,
    required this.capital,
    required this.code,
    required this.latitude,
    required this.longitude,
    this.isUnionTerritory = false,
  });

  String get displayName => '$name ($nameTamil)';
}

/// Robust Geocoding & Place Resolution Service for AstroDashaCare
class GeocodingService {
  /// All 28 Indian States & 8 Union Territories
  static const List<IndianState> indianStates = [
    // 28 Indian States
    IndianState(name: 'Tamil Nadu', nameTamil: 'தமிழ்நாடு', capital: 'Chennai', code: 'TN', latitude: 13.0827, longitude: 80.2707),
    IndianState(name: 'Maharashtra', nameTamil: 'மகாராஷ்டிரா', capital: 'Mumbai', code: 'MH', latitude: 19.0760, longitude: 72.8777),
    IndianState(name: 'Karnataka', nameTamil: 'கர்நாடகா', capital: 'Bengaluru', code: 'KA', latitude: 12.9716, longitude: 77.5946),
    IndianState(name: 'Kerala', nameTamil: 'கேரளா', capital: 'Thiruvananthapuram', code: 'KL', latitude: 8.5241, longitude: 76.9366),
    IndianState(name: 'Andhra Pradesh', nameTamil: 'ஆந்திர பிரதேசம்', capital: 'Amaravati', code: 'AP', latitude: 16.5417, longitude: 80.5158),
    IndianState(name: 'Telangana', nameTamil: 'தெலுங்கானா', capital: 'Hyderabad', code: 'TS', latitude: 17.3850, longitude: 78.4867),
    IndianState(name: 'Gujarat', nameTamil: 'குஜராத்', capital: 'Gandhinagar', code: 'GJ', latitude: 23.2156, longitude: 72.6369),
    IndianState(name: 'Rajasthan', nameTamil: 'ராஜஸ்தான்', capital: 'Jaipur', code: 'RJ', latitude: 26.9124, longitude: 75.7873),
    IndianState(name: 'Uttar Pradesh', nameTamil: 'உத்தரப் பிரதேசம்', capital: 'Lucknow', code: 'UP', latitude: 26.8467, longitude: 80.9462),
    IndianState(name: 'West Bengal', nameTamil: 'மேற்கு வங்கம்', capital: 'Kolkata', code: 'WB', latitude: 22.5726, longitude: 88.3639),
    IndianState(name: 'Madhya Pradesh', nameTamil: 'மத்திய பிரதேசம்', capital: 'Bhopal', code: 'MP', latitude: 23.2599, longitude: 77.4126),
    IndianState(name: 'Bihar', nameTamil: 'பீகார்', capital: 'Patna', code: 'BR', latitude: 25.5941, longitude: 85.1376),
    IndianState(name: 'Punjab', nameTamil: 'பஞ்சாப்', capital: 'Chandigarh', code: 'PB', latitude: 30.7333, longitude: 76.7794),
    IndianState(name: 'Haryana', nameTamil: 'ஹரியானா', capital: 'Chandigarh', code: 'HR', latitude: 30.7333, longitude: 76.7794),
    IndianState(name: 'Odisha', nameTamil: 'ஒடிசா', capital: 'Bhubaneswar', code: 'OD', latitude: 20.2961, longitude: 85.8245),
    IndianState(name: 'Assam', nameTamil: 'அசாம்', capital: 'Dispur / Guwahati', code: 'AS', latitude: 26.1445, longitude: 91.7362),
    IndianState(name: 'Jharkhand', nameTamil: 'ஜார்க்கண்ட்', capital: 'Ranchi', code: 'JH', latitude: 23.3441, longitude: 85.3096),
    IndianState(name: 'Chhattisgarh', nameTamil: 'சத்தீஸ்கர்', capital: 'Raipur', code: 'CG', latitude: 21.2514, longitude: 81.6296),
    IndianState(name: 'Uttarakhand', nameTamil: 'உத்தரகாண்ட்', capital: 'Dehradun', code: 'UK', latitude: 30.3165, longitude: 78.0322),
    IndianState(name: 'Himachal Pradesh', nameTamil: 'இமாச்சல பிரதேசம்', capital: 'Shimla', code: 'HP', latitude: 31.1048, longitude: 77.1734),
    IndianState(name: 'Goa', nameTamil: 'கோவா', capital: 'Panaji', code: 'GA', latitude: 15.4909, longitude: 73.8278),
    IndianState(name: 'Tripura', nameTamil: 'திரிபுரா', capital: 'Agartala', code: 'TR', latitude: 23.8315, longitude: 91.2868),
    IndianState(name: 'Manipur', nameTamil: 'மணிப்பூர்', capital: 'Imphal', code: 'MN', latitude: 24.8170, longitude: 93.9368),
    IndianState(name: 'Meghalaya', nameTamil: 'மேகாலயா', capital: 'Shillong', code: 'ML', latitude: 25.5788, longitude: 91.8933),
    IndianState(name: 'Nagaland', nameTamil: 'நாகாலாந்து', capital: 'Kohima', code: 'NL', latitude: 25.6751, longitude: 94.1086),
    IndianState(name: 'Mizoram', nameTamil: 'மிசோரம்', capital: 'Aizawl', code: 'MZ', latitude: 23.7271, longitude: 92.7176),
    IndianState(name: 'Arunachal Pradesh', nameTamil: 'அருணாச்சல பிரதேசம்', capital: 'Itanagar', code: 'AR', latitude: 27.0844, longitude: 93.6053),
    IndianState(name: 'Sikkim', nameTamil: 'சிக்கிம்', capital: 'Gangtok', code: 'SK', latitude: 27.3389, longitude: 88.6065),

    // 8 Union Territories
    IndianState(name: 'Delhi', nameTamil: 'தில்லி / புது தில்லி', capital: 'New Delhi', code: 'DL', latitude: 28.6139, longitude: 77.2090, isUnionTerritory: true),
    IndianState(name: 'Puducherry', nameTamil: 'புதுச்சேரி', capital: 'Puducherry', code: 'PY', latitude: 11.9416, longitude: 79.8083, isUnionTerritory: true),
    IndianState(name: 'Jammu and Kashmir', nameTamil: 'ஜம்மு காஷ்மீர்', capital: 'Srinagar / Jammu', code: 'JK', latitude: 34.0837, longitude: 74.7973, isUnionTerritory: true),
    IndianState(name: 'Ladakh', nameTamil: 'லடாக்', capital: 'Leh', code: 'LA', latitude: 34.1526, longitude: 77.5771, isUnionTerritory: true),
    IndianState(name: 'Chandigarh', nameTamil: 'சண்டிகர்', capital: 'Chandigarh', code: 'CH', latitude: 30.7333, longitude: 76.7794, isUnionTerritory: true),
    IndianState(name: 'Andaman and Nicobar Islands', nameTamil: 'அந்தமான் நிகோபார்', capital: 'Port Blair', code: 'AN', latitude: 11.6234, longitude: 92.7265, isUnionTerritory: true),
    IndianState(name: 'Dadra and Nagar Haveli and Daman and Diu', nameTamil: 'தாமன் மற்றும் தியூ', capital: 'Daman', code: 'DD', latitude: 20.4283, longitude: 72.8397, isUnionTerritory: true),
    IndianState(name: 'Lakshadweep', nameTamil: 'லட்சத்தீவு', capital: 'Kavaratti', code: 'LD', latitude: 10.5667, longitude: 72.6417, isUnionTerritory: true),
  ];

  /// Comprehensive built-in offline repository of all major Indian Cities and Towns across 28 States & 8 UTs + Global
  static const List<GeocodingLocation> _offlineLocations = [
    // Tamil Nadu (38 Districts & Towns)
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
    GeocodingLocation(cityName: 'Chinnalapatti', displayName: 'Chinnalapatti, Dindigul, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 10.2785, longitude: 77.9244, timezone: 5.5),
    GeocodingLocation(cityName: 'Kovilpatti', displayName: 'Kovilpatti, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 9.1728, longitude: 77.8683, timezone: 5.5),
    GeocodingLocation(cityName: 'Aruppukkottai', displayName: 'Aruppukkottai, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 9.5098, longitude: 78.0984, timezone: 5.5),
    GeocodingLocation(cityName: 'Batlagundu', displayName: 'Batlagundu (Vathalagundu), Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 10.1583, longitude: 77.7600, timezone: 5.5),
    GeocodingLocation(cityName: 'Paramakudi', displayName: 'Paramakudi, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 9.5447, longitude: 78.5886, timezone: 5.5),
    GeocodingLocation(cityName: 'Bodinayakanur', displayName: 'Bodinayakanur (Bodi), Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 10.0104, longitude: 77.3486, timezone: 5.5),
    GeocodingLocation(cityName: 'Ramanathapuram', displayName: 'Ramanathapuram, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 9.3639, longitude: 78.8395, timezone: 5.5),
    GeocodingLocation(cityName: 'Virudhunagar', displayName: 'Virudhunagar, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 9.5872, longitude: 77.9579, timezone: 5.5),
    GeocodingLocation(cityName: 'Sivaganga', displayName: 'Sivaganga, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 9.8433, longitude: 78.4809, timezone: 5.5),
    GeocodingLocation(cityName: 'Tirupathur', displayName: 'Tirupathur, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 12.4925, longitude: 78.5678, timezone: 5.5),
    GeocodingLocation(cityName: 'Kodaikanal', displayName: 'Kodaikanal, Tamil Nadu, India', state: 'Tamil Nadu', country: 'India', latitude: 10.2381, longitude: 77.4892, timezone: 5.5),

    // Maharashtra
    GeocodingLocation(cityName: 'Mumbai', displayName: 'Mumbai (Bombay), Maharashtra, India', state: 'Maharashtra', country: 'India', latitude: 19.0760, longitude: 72.8777, timezone: 5.5),
    GeocodingLocation(cityName: 'Pune', displayName: 'Pune, Maharashtra, India', state: 'Maharashtra', country: 'India', latitude: 18.5204, longitude: 73.8567, timezone: 5.5),
    GeocodingLocation(cityName: 'Nagpur', displayName: 'Nagpur, Maharashtra, India', state: 'Maharashtra', country: 'India', latitude: 21.1458, longitude: 79.0882, timezone: 5.5),
    GeocodingLocation(cityName: 'Thane', displayName: 'Thane, Maharashtra, India', state: 'Maharashtra', country: 'India', latitude: 19.2183, longitude: 72.9781, timezone: 5.5),
    GeocodingLocation(cityName: 'Nashik', displayName: 'Nashik, Maharashtra, India', state: 'Maharashtra', country: 'India', latitude: 19.9975, longitude: 73.7898, timezone: 5.5),
    GeocodingLocation(cityName: 'Aurangabad', displayName: 'Aurangabad (Chhatrapati Sambhajinagar), Maharashtra, India', state: 'Maharashtra', country: 'India', latitude: 19.8762, longitude: 75.3433, timezone: 5.5),
    GeocodingLocation(cityName: 'Navi Mumbai', displayName: 'Navi Mumbai, Maharashtra, India', state: 'Maharashtra', country: 'India', latitude: 19.0330, longitude: 73.0297, timezone: 5.5),
    GeocodingLocation(cityName: 'Solapur', displayName: 'Solapur, Maharashtra, India', state: 'Maharashtra', country: 'India', latitude: 17.6599, longitude: 75.9064, timezone: 5.5),
    GeocodingLocation(cityName: 'Kolhapur', displayName: 'Kolhapur, Maharashtra, India', state: 'Maharashtra', country: 'India', latitude: 16.7050, longitude: 74.2433, timezone: 5.5),
    GeocodingLocation(cityName: 'Amravati', displayName: 'Amravati, Maharashtra, India', state: 'Maharashtra', country: 'India', latitude: 20.9320, longitude: 77.7523, timezone: 5.5),
    GeocodingLocation(cityName: 'Nanded', displayName: 'Nanded, Maharashtra, India', state: 'Maharashtra', country: 'India', latitude: 19.1383, longitude: 77.3210, timezone: 5.5),
    GeocodingLocation(cityName: 'Sangli', displayName: 'Sangli, Maharashtra, India', state: 'Maharashtra', country: 'India', latitude: 16.8524, longitude: 74.5815, timezone: 5.5),
    GeocodingLocation(cityName: 'Jalgaon', displayName: 'Jalgaon, Maharashtra, India', state: 'Maharashtra', country: 'India', latitude: 21.0077, longitude: 75.5626, timezone: 5.5),
    GeocodingLocation(cityName: 'Akola', displayName: 'Akola, Maharashtra, India', state: 'Maharashtra', country: 'India', latitude: 20.7002, longitude: 77.0082, timezone: 5.5),
    GeocodingLocation(cityName: 'Latur', displayName: 'Latur, Maharashtra, India', state: 'Maharashtra', country: 'India', latitude: 18.4088, longitude: 76.5604, timezone: 5.5),
    GeocodingLocation(cityName: 'Ahmednagar', displayName: 'Ahmednagar, Maharashtra, India', state: 'Maharashtra', country: 'India', latitude: 19.0948, longitude: 74.7480, timezone: 5.5),
    GeocodingLocation(cityName: 'Chandrapur', displayName: 'Chandrapur, Maharashtra, India', state: 'Maharashtra', country: 'India', latitude: 19.9615, longitude: 79.2961, timezone: 5.5),
    GeocodingLocation(cityName: 'Satara', displayName: 'Satara, Maharashtra, India', state: 'Maharashtra', country: 'India', latitude: 17.6805, longitude: 73.9936, timezone: 5.5),
    GeocodingLocation(cityName: 'Shirdi', displayName: 'Shirdi, Maharashtra, India', state: 'Maharashtra', country: 'India', latitude: 19.7645, longitude: 74.4762, timezone: 5.5),

    // Karnataka
    GeocodingLocation(cityName: 'Bengaluru', displayName: 'Bengaluru (Bangalore), Karnataka, India', state: 'Karnataka', country: 'India', latitude: 12.9716, longitude: 77.5946, timezone: 5.5),
    GeocodingLocation(cityName: 'Mysuru', displayName: 'Mysuru (Mysore), Karnataka, India', state: 'Karnataka', country: 'India', latitude: 12.2958, longitude: 76.6394, timezone: 5.5),
    GeocodingLocation(cityName: 'Hubballi', displayName: 'Hubballi-Dharwad, Karnataka, India', state: 'Karnataka', country: 'India', latitude: 15.3647, longitude: 75.1240, timezone: 5.5),
    GeocodingLocation(cityName: 'Mangaluru', displayName: 'Mangaluru (Mangalore), Karnataka, India', state: 'Karnataka', country: 'India', latitude: 12.9141, longitude: 74.8560, timezone: 5.5),
    GeocodingLocation(cityName: 'Belagavi', displayName: 'Belagavi (Belgaum), Karnataka, India', state: 'Karnataka', country: 'India', latitude: 15.8497, longitude: 74.4977, timezone: 5.5),
    GeocodingLocation(cityName: 'Kalaburagi', displayName: 'Kalaburagi (Gulbarga), Karnataka, India', state: 'Karnataka', country: 'India', latitude: 17.3297, longitude: 76.8343, timezone: 5.5),
    GeocodingLocation(cityName: 'Davanagere', displayName: 'Davanagere, Karnataka, India', state: 'Karnataka', country: 'India', latitude: 14.4644, longitude: 75.9218, timezone: 5.5),
    GeocodingLocation(cityName: 'Ballari', displayName: 'Ballari (Bellary), Karnataka, India', state: 'Karnataka', country: 'India', latitude: 15.1394, longitude: 76.9214, timezone: 5.5),
    GeocodingLocation(cityName: 'Vijayapura', displayName: 'Vijayapura (Bijapur), Karnataka, India', state: 'Karnataka', country: 'India', latitude: 16.8302, longitude: 75.7100, timezone: 5.5),
    GeocodingLocation(cityName: 'Shivamogga', displayName: 'Shivamogga (Shimoga), Karnataka, India', state: 'Karnataka', country: 'India', latitude: 13.9299, longitude: 75.5681, timezone: 5.5),
    GeocodingLocation(cityName: 'Tumakuru', displayName: 'Tumakuru (Tumkur), Karnataka, India', state: 'Karnataka', country: 'India', latitude: 13.3392, longitude: 77.1017, timezone: 5.5),
    GeocodingLocation(cityName: 'Udupi', displayName: 'Udupi, Karnataka, India', state: 'Karnataka', country: 'India', latitude: 13.3409, longitude: 74.7421, timezone: 5.5),
    GeocodingLocation(cityName: 'Hassan', displayName: 'Hassan, Karnataka, India', state: 'Karnataka', country: 'India', latitude: 13.0072, longitude: 76.1032, timezone: 5.5),
    GeocodingLocation(cityName: 'Chikkamagaluru', displayName: 'Chikkamagaluru, Karnataka, India', state: 'Karnataka', country: 'India', latitude: 13.3161, longitude: 75.7720, timezone: 5.5),

    // Kerala
    GeocodingLocation(cityName: 'Thiruvananthapuram', displayName: 'Thiruvananthapuram (Trivandrum), Kerala, India', state: 'Kerala', country: 'India', latitude: 8.5241, longitude: 76.9366, timezone: 5.5),
    GeocodingLocation(cityName: 'Kochi', displayName: 'Kochi (Cochin), Kerala, India', state: 'Kerala', country: 'India', latitude: 9.9312, longitude: 76.2673, timezone: 5.5),
    GeocodingLocation(cityName: 'Kozhikode', displayName: 'Kozhikode (Calicut), Kerala, India', state: 'Kerala', country: 'India', latitude: 11.2588, longitude: 75.7804, timezone: 5.5),
    GeocodingLocation(cityName: 'Thrissur', displayName: 'Thrissur, Kerala, India', state: 'Kerala', country: 'India', latitude: 10.5276, longitude: 76.2144, timezone: 5.5),
    GeocodingLocation(cityName: 'Kollam', displayName: 'Kollam (Quilon), Kerala, India', state: 'Kerala', country: 'India', latitude: 8.8932, longitude: 76.6141, timezone: 5.5),
    GeocodingLocation(cityName: 'Kannur', displayName: 'Kannur, Kerala, India', state: 'Kerala', country: 'India', latitude: 11.8745, longitude: 75.3704, timezone: 5.5),
    GeocodingLocation(cityName: 'Alappuzha', displayName: 'Alappuzha (Alleppey), Kerala, India', state: 'Kerala', country: 'India', latitude: 9.4981, longitude: 76.3388, timezone: 5.5),
    GeocodingLocation(cityName: 'Kottayam', displayName: 'Kottayam, Kerala, India', state: 'Kerala', country: 'India', latitude: 9.5916, longitude: 76.5222, timezone: 5.5),
    GeocodingLocation(cityName: 'Palakkad', displayName: 'Palakkad (Palghat), Kerala, India', state: 'Kerala', country: 'India', latitude: 10.7867, longitude: 76.6548, timezone: 5.5),
    GeocodingLocation(cityName: 'Malappuram', displayName: 'Malappuram, Kerala, India', state: 'Kerala', country: 'India', latitude: 11.0510, longitude: 76.0711, timezone: 5.5),
    GeocodingLocation(cityName: 'Guruvayur', displayName: 'Guruvayur, Kerala, India', state: 'Kerala', country: 'India', latitude: 10.5946, longitude: 76.0409, timezone: 5.5),
    GeocodingLocation(cityName: 'Kasaragod', displayName: 'Kasaragod, Kerala, India', state: 'Kerala', country: 'India', latitude: 12.4996, longitude: 74.9869, timezone: 5.5),

    // Andhra Pradesh
    GeocodingLocation(cityName: 'Visakhapatnam', displayName: 'Visakhapatnam (Vizag), Andhra Pradesh, India', state: 'Andhra Pradesh', country: 'India', latitude: 17.6868, longitude: 83.2185, timezone: 5.5),
    GeocodingLocation(cityName: 'Vijayawada', displayName: 'Vijayawada, Andhra Pradesh, India', state: 'Andhra Pradesh', country: 'India', latitude: 16.5062, longitude: 80.6480, timezone: 5.5),
    GeocodingLocation(cityName: 'Guntur', displayName: 'Guntur, Andhra Pradesh, India', state: 'Andhra Pradesh', country: 'India', latitude: 16.3067, longitude: 80.4365, timezone: 5.5),
    GeocodingLocation(cityName: 'Nellore', displayName: 'Nellore, Andhra Pradesh, India', state: 'Andhra Pradesh', country: 'India', latitude: 14.4426, longitude: 79.9865, timezone: 5.5),
    GeocodingLocation(cityName: 'Kurnool', displayName: 'Kurnool, Andhra Pradesh, India', state: 'Andhra Pradesh', country: 'India', latitude: 15.8281, longitude: 78.0373, timezone: 5.5),
    GeocodingLocation(cityName: 'Rajahmundry', displayName: 'Rajahmundry, Andhra Pradesh, India', state: 'Andhra Pradesh', country: 'India', latitude: 17.0005, longitude: 81.8040, timezone: 5.5),
    GeocodingLocation(cityName: 'Tirupati', displayName: 'Tirupati, Andhra Pradesh, India', state: 'Andhra Pradesh', country: 'India', latitude: 13.6288, longitude: 79.4192, timezone: 5.5),
    GeocodingLocation(cityName: 'Kakinada', displayName: 'Kakinada, Andhra Pradesh, India', state: 'Andhra Pradesh', country: 'India', latitude: 16.9891, longitude: 82.2475, timezone: 5.5),
    GeocodingLocation(cityName: 'Kadapa', displayName: 'Kadapa (Cuddapah), Andhra Pradesh, India', state: 'Andhra Pradesh', country: 'India', latitude: 14.4673, longitude: 78.8242, timezone: 5.5),
    GeocodingLocation(cityName: 'Anantapur', displayName: 'Anantapur, Andhra Pradesh, India', state: 'Andhra Pradesh', country: 'India', latitude: 14.6819, longitude: 77.6006, timezone: 5.5),
    GeocodingLocation(cityName: 'Amaravati', displayName: 'Amaravati, Andhra Pradesh, India', state: 'Andhra Pradesh', country: 'India', latitude: 16.5417, longitude: 80.5158, timezone: 5.5),

    // Telangana
    GeocodingLocation(cityName: 'Hyderabad', displayName: 'Hyderabad, Telangana, India', state: 'Telangana', country: 'India', latitude: 17.3850, longitude: 78.4867, timezone: 5.5),
    GeocodingLocation(cityName: 'Warangal', displayName: 'Warangal, Telangana, India', state: 'Telangana', country: 'India', latitude: 17.9689, longitude: 79.5941, timezone: 5.5),
    GeocodingLocation(cityName: 'Nizamabad', displayName: 'Nizamabad, Telangana, India', state: 'Telangana', country: 'India', latitude: 18.6725, longitude: 78.0941, timezone: 5.5),
    GeocodingLocation(cityName: 'Karimnagar', displayName: 'Karimnagar, Telangana, India', state: 'Telangana', country: 'India', latitude: 18.4386, longitude: 79.1288, timezone: 5.5),
    GeocodingLocation(cityName: 'Khammam', displayName: 'Khammam, Telangana, India', state: 'Telangana', country: 'India', latitude: 17.2473, longitude: 80.1514, timezone: 5.5),
    GeocodingLocation(cityName: 'Ramagundam', displayName: 'Ramagundam, Telangana, India', state: 'Telangana', country: 'India', latitude: 18.7638, longitude: 79.4750, timezone: 5.5),

    // Delhi / NCR
    GeocodingLocation(cityName: 'New Delhi', displayName: 'New Delhi (Delhi), India', state: 'Delhi', country: 'India', latitude: 28.6139, longitude: 77.2090, timezone: 5.5),
    GeocodingLocation(cityName: 'Delhi', displayName: 'Delhi, India', state: 'Delhi', country: 'India', latitude: 28.7041, longitude: 77.1025, timezone: 5.5),
    GeocodingLocation(cityName: 'Noida', displayName: 'Noida, Uttar Pradesh, India', state: 'Uttar Pradesh', country: 'India', latitude: 28.5355, longitude: 77.3910, timezone: 5.5),
    GeocodingLocation(cityName: 'Greater Noida', displayName: 'Greater Noida, Uttar Pradesh, India', state: 'Uttar Pradesh', country: 'India', latitude: 28.4744, longitude: 77.5040, timezone: 5.5),
    GeocodingLocation(cityName: 'Ghaziabad', displayName: 'Ghaziabad, Uttar Pradesh, India', state: 'Uttar Pradesh', country: 'India', latitude: 28.6692, longitude: 77.4538, timezone: 5.5),
    GeocodingLocation(cityName: 'Gurugram', displayName: 'Gurugram (Gurgaon), Haryana, India', state: 'Haryana', country: 'India', latitude: 28.4595, longitude: 77.0266, timezone: 5.5),
    GeocodingLocation(cityName: 'Faridabad', displayName: 'Faridabad, Haryana, India', state: 'Haryana', country: 'India', latitude: 28.4089, longitude: 77.3178, timezone: 5.5),

    // Gujarat
    GeocodingLocation(cityName: 'Ahmedabad', displayName: 'Ahmedabad, Gujarat, India', state: 'Gujarat', country: 'India', latitude: 23.0225, longitude: 72.5714, timezone: 5.5),
    GeocodingLocation(cityName: 'Surat', displayName: 'Surat, Gujarat, India', state: 'Gujarat', country: 'India', latitude: 21.1702, longitude: 72.8311, timezone: 5.5),
    GeocodingLocation(cityName: 'Vadodara', displayName: 'Vadodara (Baroda), Gujarat, India', state: 'Gujarat', country: 'India', latitude: 22.3072, longitude: 73.1812, timezone: 5.5),
    GeocodingLocation(cityName: 'Rajkot', displayName: 'Rajkot, Gujarat, India', state: 'Gujarat', country: 'India', latitude: 22.3039, longitude: 70.8022, timezone: 5.5),
    GeocodingLocation(cityName: 'Bhavnagar', displayName: 'Bhavnagar, Gujarat, India', state: 'Gujarat', country: 'India', latitude: 21.7645, longitude: 72.1519, timezone: 5.5),
    GeocodingLocation(cityName: 'Jamnagar', displayName: 'Jamnagar, Gujarat, India', state: 'Gujarat', country: 'India', latitude: 22.4707, longitude: 70.0577, timezone: 5.5),
    GeocodingLocation(cityName: 'Gandhinagar', displayName: 'Gandhinagar, Gujarat, India', state: 'Gujarat', country: 'India', latitude: 23.2156, longitude: 72.6369, timezone: 5.5),
    GeocodingLocation(cityName: 'Junagadh', displayName: 'Junagadh, Gujarat, India', state: 'Gujarat', country: 'India', latitude: 21.5222, longitude: 70.4579, timezone: 5.5),
    GeocodingLocation(cityName: 'Bhuj', displayName: 'Bhuj, Gujarat, India', state: 'Gujarat', country: 'India', latitude: 23.2420, longitude: 69.6669, timezone: 5.5),
    GeocodingLocation(cityName: 'Vapi', displayName: 'Vapi, Gujarat, India', state: 'Gujarat', country: 'India', latitude: 20.3893, longitude: 72.9106, timezone: 5.5),

    // Rajasthan
    GeocodingLocation(cityName: 'Jaipur', displayName: 'Jaipur, Rajasthan, India', state: 'Rajasthan', country: 'India', latitude: 26.9124, longitude: 75.7873, timezone: 5.5),
    GeocodingLocation(cityName: 'Jodhpur', displayName: 'Jodhpur, Rajasthan, India', state: 'Rajasthan', country: 'India', latitude: 26.2389, longitude: 73.0243, timezone: 5.5),
    GeocodingLocation(cityName: 'Kota', displayName: 'Kota, Rajasthan, India', state: 'Rajasthan', country: 'India', latitude: 25.2138, longitude: 75.8648, timezone: 5.5),
    GeocodingLocation(cityName: 'Bikaner', displayName: 'Bikaner, Rajasthan, India', state: 'Rajasthan', country: 'India', latitude: 28.0229, longitude: 73.3119, timezone: 5.5),
    GeocodingLocation(cityName: 'Ajmer', displayName: 'Ajmer, Rajasthan, India', state: 'Rajasthan', country: 'India', latitude: 26.4499, longitude: 74.6399, timezone: 5.5),
    GeocodingLocation(cityName: 'Udaipur', displayName: 'Udaipur, Rajasthan, India', state: 'Rajasthan', country: 'India', latitude: 24.5854, longitude: 73.7125, timezone: 5.5),
    GeocodingLocation(cityName: 'Bhilwara', displayName: 'Bhilwara, Rajasthan, India', state: 'Rajasthan', country: 'India', latitude: 25.3216, longitude: 74.6413, timezone: 5.5),
    GeocodingLocation(cityName: 'Alwar', displayName: 'Alwar, Rajasthan, India', state: 'Rajasthan', country: 'India', latitude: 27.5530, longitude: 76.6346, timezone: 5.5),
    GeocodingLocation(cityName: 'Jaisalmer', displayName: 'Jaisalmer, Rajasthan, India', state: 'Rajasthan', country: 'India', latitude: 26.9157, longitude: 70.9083, timezone: 5.5),

    // Uttar Pradesh
    GeocodingLocation(cityName: 'Lucknow', displayName: 'Lucknow, Uttar Pradesh, India', state: 'Uttar Pradesh', country: 'India', latitude: 26.8467, longitude: 80.9462, timezone: 5.5),
    GeocodingLocation(cityName: 'Kanpur', displayName: 'Kanpur, Uttar Pradesh, India', state: 'Uttar Pradesh', country: 'India', latitude: 26.4499, longitude: 80.3319, timezone: 5.5),
    GeocodingLocation(cityName: 'Varanasi', displayName: 'Varanasi (Banaras / Kashi), Uttar Pradesh, India', state: 'Uttar Pradesh', country: 'India', latitude: 25.3176, longitude: 82.9739, timezone: 5.5),
    GeocodingLocation(cityName: 'Agra', displayName: 'Agra, Uttar Pradesh, India', state: 'Uttar Pradesh', country: 'India', latitude: 27.1767, longitude: 78.0081, timezone: 5.5),
    GeocodingLocation(cityName: 'Prayagraj', displayName: 'Prayagraj (Allahabad), Uttar Pradesh, India', state: 'Uttar Pradesh', country: 'India', latitude: 25.4358, longitude: 81.8463, timezone: 5.5),
    GeocodingLocation(cityName: 'Meerut', displayName: 'Meerut, Uttar Pradesh, India', state: 'Uttar Pradesh', country: 'India', latitude: 28.9845, longitude: 77.7064, timezone: 5.5),
    GeocodingLocation(cityName: 'Bareilly', displayName: 'Bareilly, Uttar Pradesh, India', state: 'Uttar Pradesh', country: 'India', latitude: 28.3670, longitude: 79.4304, timezone: 5.5),
    GeocodingLocation(cityName: 'Aligarh', displayName: 'Aligarh, Uttar Pradesh, India', state: 'Uttar Pradesh', country: 'India', latitude: 27.8974, longitude: 78.0880, timezone: 5.5),
    GeocodingLocation(cityName: 'Moradabad', displayName: 'Moradabad, Uttar Pradesh, India', state: 'Uttar Pradesh', country: 'India', latitude: 28.8386, longitude: 78.7733, timezone: 5.5),
    GeocodingLocation(cityName: 'Gorakhpur', displayName: 'Gorakhpur, Uttar Pradesh, India', state: 'Uttar Pradesh', country: 'India', latitude: 26.7606, longitude: 83.3732, timezone: 5.5),
    GeocodingLocation(cityName: 'Ayodhya', displayName: 'Ayodhya (Faizabad), Uttar Pradesh, India', state: 'Uttar Pradesh', country: 'India', latitude: 26.7922, longitude: 82.1998, timezone: 5.5),
    GeocodingLocation(cityName: 'Mathura', displayName: 'Mathura, Uttar Pradesh, India', state: 'Uttar Pradesh', country: 'India', latitude: 27.4924, longitude: 77.6737, timezone: 5.5),
    GeocodingLocation(cityName: 'Jhansi', displayName: 'Jhansi, Uttar Pradesh, India', state: 'Uttar Pradesh', country: 'India', latitude: 25.4484, longitude: 78.5685, timezone: 5.5),

    // West Bengal
    GeocodingLocation(cityName: 'Kolkata', displayName: 'Kolkata (Calcutta), West Bengal, India', state: 'West Bengal', country: 'India', latitude: 22.5726, longitude: 88.3639, timezone: 5.5),
    GeocodingLocation(cityName: 'Howrah', displayName: 'Howrah, West Bengal, India', state: 'West Bengal', country: 'India', latitude: 22.5958, longitude: 88.2636, timezone: 5.5),
    GeocodingLocation(cityName: 'Siliguri', displayName: 'Siliguri, West Bengal, India', state: 'West Bengal', country: 'India', latitude: 26.7271, longitude: 88.3953, timezone: 5.5),
    GeocodingLocation(cityName: 'Durgapur', displayName: 'Durgapur, West Bengal, India', state: 'West Bengal', country: 'India', latitude: 23.5204, longitude: 87.3119, timezone: 5.5),
    GeocodingLocation(cityName: 'Asansol', displayName: 'Asansol, West Bengal, India', state: 'West Bengal', country: 'India', latitude: 23.6739, longitude: 86.9524, timezone: 5.5),
    GeocodingLocation(cityName: 'Darjeeling', displayName: 'Darjeeling, West Bengal, India', state: 'West Bengal', country: 'India', latitude: 27.0410, longitude: 88.2663, timezone: 5.5),
    GeocodingLocation(cityName: 'Kharagpur', displayName: 'Kharagpur, West Bengal, India', state: 'West Bengal', country: 'India', latitude: 22.3460, longitude: 87.2320, timezone: 5.5),

    // Madhya Pradesh
    GeocodingLocation(cityName: 'Indore', displayName: 'Indore, Madhya Pradesh, India', state: 'Madhya Pradesh', country: 'India', latitude: 22.7196, longitude: 75.8577, timezone: 5.5),
    GeocodingLocation(cityName: 'Bhopal', displayName: 'Bhopal, Madhya Pradesh, India', state: 'Madhya Pradesh', country: 'India', latitude: 23.2599, longitude: 77.4126, timezone: 5.5),
    GeocodingLocation(cityName: 'Jabalpur', displayName: 'Jabalpur, Madhya Pradesh, India', state: 'Madhya Pradesh', country: 'India', latitude: 23.1815, longitude: 79.9864, timezone: 5.5),
    GeocodingLocation(cityName: 'Gwalior', displayName: 'Gwalior, Madhya Pradesh, India', state: 'Madhya Pradesh', country: 'India', latitude: 26.2183, longitude: 78.1828, timezone: 5.5),
    GeocodingLocation(cityName: 'Ujjain', displayName: 'Ujjain, Madhya Pradesh, India', state: 'Madhya Pradesh', country: 'India', latitude: 23.1765, longitude: 75.7885, timezone: 5.5),
    GeocodingLocation(cityName: 'Sagar', displayName: 'Sagar, Madhya Pradesh, India', state: 'Madhya Pradesh', country: 'India', latitude: 23.8388, longitude: 78.7378, timezone: 5.5),

    // Bihar
    GeocodingLocation(cityName: 'Patna', displayName: 'Patna, Bihar, India', state: 'Bihar', country: 'India', latitude: 25.5941, longitude: 85.1376, timezone: 5.5),
    GeocodingLocation(cityName: 'Gaya', displayName: 'Gaya (Bodh Gaya), Bihar, India', state: 'Bihar', country: 'India', latitude: 24.7914, longitude: 85.0002, timezone: 5.5),
    GeocodingLocation(cityName: 'Bhagalpur', displayName: 'Bhagalpur, Bihar, India', state: 'Bihar', country: 'India', latitude: 25.2425, longitude: 86.9842, timezone: 5.5),
    GeocodingLocation(cityName: 'Muzaffarpur', displayName: 'Muzaffarpur, Bihar, India', state: 'Bihar', country: 'India', latitude: 26.1209, longitude: 85.3647, timezone: 5.5),
    GeocodingLocation(cityName: 'Darbhanga', displayName: 'Darbhanga, Bihar, India', state: 'Bihar', country: 'India', latitude: 26.1542, longitude: 85.8918, timezone: 5.5),

    // Punjab
    GeocodingLocation(cityName: 'Ludhiana', displayName: 'Ludhiana, Punjab, India', state: 'Punjab', country: 'India', latitude: 30.9010, longitude: 75.8573, timezone: 5.5),
    GeocodingLocation(cityName: 'Amritsar', displayName: 'Amritsar, Punjab, India', state: 'Punjab', country: 'India', latitude: 31.6340, longitude: 74.8723, timezone: 5.5),
    GeocodingLocation(cityName: 'Jalandhar', displayName: 'Jalandhar, Punjab, India', state: 'Punjab', country: 'India', latitude: 31.3260, longitude: 75.5762, timezone: 5.5),
    GeocodingLocation(cityName: 'Patiala', displayName: 'Patiala, Punjab, India', state: 'Punjab', country: 'India', latitude: 30.3398, longitude: 76.3869, timezone: 5.5),
    GeocodingLocation(cityName: 'Bathinda', displayName: 'Bathinda, Punjab, India', state: 'Punjab', country: 'India', latitude: 30.2110, longitude: 74.9455, timezone: 5.5),
    GeocodingLocation(cityName: 'Mohali', displayName: 'Mohali (SAS Nagar), Punjab, India', state: 'Punjab', country: 'India', latitude: 30.7046, longitude: 76.7179, timezone: 5.5),

    // Haryana
    GeocodingLocation(cityName: 'Panipat', displayName: 'Panipat, Haryana, India', state: 'Haryana', country: 'India', latitude: 29.3909, longitude: 76.9635, timezone: 5.5),
    GeocodingLocation(cityName: 'Ambala', displayName: 'Ambala, Haryana, India', state: 'Haryana', country: 'India', latitude: 30.3782, longitude: 76.7767, timezone: 5.5),
    GeocodingLocation(cityName: 'Karnal', displayName: 'Karnal, Haryana, India', state: 'Haryana', country: 'India', latitude: 29.6857, longitude: 76.9905, timezone: 5.5),
    GeocodingLocation(cityName: 'Hisar', displayName: 'Hisar, Haryana, India', state: 'Haryana', country: 'India', latitude: 29.1492, longitude: 75.7217, timezone: 5.5),
    GeocodingLocation(cityName: 'Rohtak', displayName: 'Rohtak, Haryana, India', state: 'Haryana', country: 'India', latitude: 28.8955, longitude: 76.6066, timezone: 5.5),

    // Odisha
    GeocodingLocation(cityName: 'Bhubaneswar', displayName: 'Bhubaneswar, Odisha, India', state: 'Odisha', country: 'India', latitude: 20.2961, longitude: 85.8245, timezone: 5.5),
    GeocodingLocation(cityName: 'Cuttack', displayName: 'Cuttack, Odisha, India', state: 'Odisha', country: 'India', latitude: 20.4625, longitude: 85.8828, timezone: 5.5),
    GeocodingLocation(cityName: 'Rourkela', displayName: 'Rourkela, Odisha, India', state: 'Odisha', country: 'India', latitude: 22.2604, longitude: 84.8536, timezone: 5.5),
    GeocodingLocation(cityName: 'Puri', displayName: 'Puri, Odisha, India', state: 'Odisha', country: 'India', latitude: 19.8135, longitude: 85.8312, timezone: 5.5),
    GeocodingLocation(cityName: 'Berhampur', displayName: 'Berhampur, Odisha, India', state: 'Odisha', country: 'India', latitude: 19.3150, longitude: 84.7941, timezone: 5.5),
    GeocodingLocation(cityName: 'Sambalpur', displayName: 'Sambalpur, Odisha, India', state: 'Odisha', country: 'India', latitude: 21.4669, longitude: 83.9812, timezone: 5.5),

    // Assam & North East
    GeocodingLocation(cityName: 'Guwahati', displayName: 'Guwahati, Assam, India', state: 'Assam', country: 'India', latitude: 26.1445, longitude: 91.7362, timezone: 5.5),
    GeocodingLocation(cityName: 'Silchar', displayName: 'Silchar, Assam, India', state: 'Assam', country: 'India', latitude: 24.8333, longitude: 92.7789, timezone: 5.5),
    GeocodingLocation(cityName: 'Dibrugarh', displayName: 'Dibrugarh, Assam, India', state: 'Assam', country: 'India', latitude: 27.4728, longitude: 94.9120, timezone: 5.5),
    GeocodingLocation(cityName: 'Jorhat', displayName: 'Jorhat, Assam, India', state: 'Assam', country: 'India', latitude: 26.7509, longitude: 94.2037, timezone: 5.5),
    GeocodingLocation(cityName: 'Tezpur', displayName: 'Tezpur, Assam, India', state: 'Assam', country: 'India', latitude: 26.6528, longitude: 92.7926, timezone: 5.5),
    GeocodingLocation(cityName: 'Shillong', displayName: 'Shillong, Meghalaya, India', state: 'Meghalaya', country: 'India', latitude: 25.5788, longitude: 91.8933, timezone: 5.5),
    GeocodingLocation(cityName: 'Agartala', displayName: 'Agartala, Tripura, India', state: 'Tripura', country: 'India', latitude: 23.8315, longitude: 91.2868, timezone: 5.5),
    GeocodingLocation(cityName: 'Imphal', displayName: 'Imphal, Manipur, India', state: 'Manipur', country: 'India', latitude: 24.8170, longitude: 93.9368, timezone: 5.5),
    GeocodingLocation(cityName: 'Aizawl', displayName: 'Aizawl, Mizoram, India', state: 'Mizoram', country: 'India', latitude: 23.7271, longitude: 92.7176, timezone: 5.5),
    GeocodingLocation(cityName: 'Kohima', displayName: 'Kohima, Nagaland, India', state: 'Nagaland', country: 'India', latitude: 25.6751, longitude: 94.1086, timezone: 5.5),
    GeocodingLocation(cityName: 'Dimapur', displayName: 'Dimapur, Nagaland, India', state: 'Nagaland', country: 'India', latitude: 25.9094, longitude: 93.7266, timezone: 5.5),
    GeocodingLocation(cityName: 'Itanagar', displayName: 'Itanagar, Arunachal Pradesh, India', state: 'Arunachal Pradesh', country: 'India', latitude: 27.0844, longitude: 93.6053, timezone: 5.5),
    GeocodingLocation(cityName: 'Gangtok', displayName: 'Gangtok, Sikkim, India', state: 'Sikkim', country: 'India', latitude: 27.3389, longitude: 88.6065, timezone: 5.5),

    // Jharkhand & Chhattisgarh
    GeocodingLocation(cityName: 'Ranchi', displayName: 'Ranchi, Jharkhand, India', state: 'Jharkhand', country: 'India', latitude: 23.3441, longitude: 85.3096, timezone: 5.5),
    GeocodingLocation(cityName: 'Jamshedpur', displayName: 'Jamshedpur (Tatanagar), Jharkhand, India', state: 'Jharkhand', country: 'India', latitude: 22.8046, longitude: 86.2029, timezone: 5.5),
    GeocodingLocation(cityName: 'Dhanbad', displayName: 'Dhanbad, Jharkhand, India', state: 'Jharkhand', country: 'India', latitude: 23.7957, longitude: 86.4304, timezone: 5.5),
    GeocodingLocation(cityName: 'Bokaro', displayName: 'Bokaro Steel City, Jharkhand, India', state: 'Jharkhand', country: 'India', latitude: 23.6693, longitude: 86.1511, timezone: 5.5),
    GeocodingLocation(cityName: 'Deoghar', displayName: 'Deoghar, Jharkhand, India', state: 'Jharkhand', country: 'India', latitude: 24.4826, longitude: 86.6974, timezone: 5.5),
    GeocodingLocation(cityName: 'Raipur', displayName: 'Raipur, Chhattisgarh, India', state: 'Chhattisgarh', country: 'India', latitude: 21.2514, longitude: 81.6296, timezone: 5.5),
    GeocodingLocation(cityName: 'Bhilai', displayName: 'Bhilai (Durg), Chhattisgarh, India', state: 'Chhattisgarh', country: 'India', latitude: 21.2121, longitude: 81.3733, timezone: 5.5),
    GeocodingLocation(cityName: 'Bilaspur', displayName: 'Bilaspur, Chhattisgarh, India', state: 'Chhattisgarh', country: 'India', latitude: 22.0797, longitude: 82.1409, timezone: 5.5),
    GeocodingLocation(cityName: 'Korba', displayName: 'Korba, Chhattisgarh, India', state: 'Chhattisgarh', country: 'India', latitude: 22.3595, longitude: 82.7501, timezone: 5.5),

    // Uttarakhand & Himachal Pradesh
    GeocodingLocation(cityName: 'Dehradun', displayName: 'Dehradun, Uttarakhand, India', state: 'Uttarakhand', country: 'India', latitude: 30.3165, longitude: 78.0322, timezone: 5.5),
    GeocodingLocation(cityName: 'Haridwar', displayName: 'Haridwar, Uttarakhand, India', state: 'Uttarakhand', country: 'India', latitude: 29.9457, longitude: 78.1642, timezone: 5.5),
    GeocodingLocation(cityName: 'Rishikesh', displayName: 'Rishikesh, Uttarakhand, India', state: 'Uttarakhand', country: 'India', latitude: 30.0869, longitude: 78.2676, timezone: 5.5),
    GeocodingLocation(cityName: 'Nainital', displayName: 'Nainital, Uttarakhand, India', state: 'Uttarakhand', country: 'India', latitude: 29.3919, longitude: 79.4542, timezone: 5.5),
    GeocodingLocation(cityName: 'Roorkee', displayName: 'Roorkee, Uttarakhand, India', state: 'Uttarakhand', country: 'India', latitude: 29.8543, longitude: 77.8880, timezone: 5.5),
    GeocodingLocation(cityName: 'Shimla', displayName: 'Shimla, Himachal Pradesh, India', state: 'Himachal Pradesh', country: 'India', latitude: 31.1048, longitude: 77.1734, timezone: 5.5),
    GeocodingLocation(cityName: 'Dharamshala', displayName: 'Dharamshala, Himachal Pradesh, India', state: 'Himachal Pradesh', country: 'India', latitude: 32.2190, longitude: 76.3234, timezone: 5.5),
    GeocodingLocation(cityName: 'Manali', displayName: 'Manali, Himachal Pradesh, India', state: 'Himachal Pradesh', country: 'India', latitude: 32.2432, longitude: 77.1892, timezone: 5.5),
    GeocodingLocation(cityName: 'Solan', displayName: 'Solan, Himachal Pradesh, India', state: 'Himachal Pradesh', country: 'India', latitude: 30.9045, longitude: 77.0967, timezone: 5.5),

    // Goa & Union Territories
    GeocodingLocation(cityName: 'Panaji', displayName: 'Panaji (Panjim), Goa, India', state: 'Goa', country: 'India', latitude: 15.4909, longitude: 73.8278, timezone: 5.5),
    GeocodingLocation(cityName: 'Margao', displayName: 'Margao (Madgaon), Goa, India', state: 'Goa', country: 'India', latitude: 15.2832, longitude: 73.9862, timezone: 5.5),
    GeocodingLocation(cityName: 'Puducherry', displayName: 'Puducherry (Pondicherry), India', state: 'Puducherry', country: 'India', latitude: 11.9416, longitude: 79.8083, timezone: 5.5),
    GeocodingLocation(cityName: 'Srinagar', displayName: 'Srinagar, Jammu and Kashmir, India', state: 'Jammu and Kashmir', country: 'India', latitude: 34.0837, longitude: 74.7973, timezone: 5.5),
    GeocodingLocation(cityName: 'Jammu', displayName: 'Jammu, Jammu and Kashmir, India', state: 'Jammu and Kashmir', country: 'India', latitude: 32.7266, longitude: 74.8570, timezone: 5.5),
    GeocodingLocation(cityName: 'Leh', displayName: 'Leh, Ladakh, India', state: 'Ladakh', country: 'India', latitude: 34.1526, longitude: 77.5771, timezone: 5.5),
    GeocodingLocation(cityName: 'Chandigarh', displayName: 'Chandigarh, India', state: 'Chandigarh', country: 'India', latitude: 30.7333, longitude: 76.7794, timezone: 5.5),
    GeocodingLocation(cityName: 'Port Blair', displayName: 'Port Blair, Andaman and Nicobar Islands, India', state: 'Andaman and Nicobar Islands', country: 'India', latitude: 11.6234, longitude: 92.7265, timezone: 5.5),
    GeocodingLocation(cityName: 'Daman', displayName: 'Daman, Dadra and Nagar Haveli and Daman and Diu, India', state: 'Dadra and Nagar Haveli and Daman and Diu', country: 'India', latitude: 20.4283, longitude: 72.8397, timezone: 5.5),
    GeocodingLocation(cityName: 'Kavaratti', displayName: 'Kavaratti, Lakshadweep, India', state: 'Lakshadweep', country: 'India', latitude: 10.5667, longitude: 72.6417, timezone: 5.5),

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

  static const Map<String, String> _stateAbbreviations = {
    'mh': 'maharashtra',
    'tn': 'tamil nadu',
    'ka': 'karnataka',
    'kl': 'kerala',
    'ap': 'andhra pradesh',
    'ts': 'telangana',
    'dl': 'delhi',
    'wb': 'west bengal',
    'rj': 'rajasthan',
    'gj': 'gujarat',
    'up': 'uttar pradesh',
    'mp': 'madhya pradesh',
    'pb': 'punjab',
    'hr': 'haryana',
    'or': 'odisha',
    'od': 'odisha',
    'ct': 'chhattisgarh',
    'cg': 'chhattisgarh',
    'jh': 'jharkhand',
    'as': 'assam',
    'br': 'bihar',
    'ga': 'goa',
    'uk': 'uttarakhand',
    'ut': 'uttarakhand',
    'hp': 'himachal pradesh',
    'tr': 'tripura',
    'mn': 'manipur',
    'ml': 'meghalaya',
    'nl': 'nagaland',
    'mz': 'mizoram',
    'ar': 'arunachal pradesh',
    'sk': 'sikkim',
    'jk': 'jammu and kashmir',
    'la': 'ladakh',
    'ch': 'chandigarh',
    'an': 'andaman and nicobar islands',
    'dd': 'daman and diu',
    'ld': 'lakshadweep',
    'py': 'puducherry',
    'ny': 'new york',
    'ca': 'california',
    'on': 'ontario',
    'nsw': 'new south wales',
    'vic': 'victoria',
  };

  /// Recommend Indian States (28 States & 8 UTs) based on search query
  static List<IndianState> searchStates(String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) {
      return indianStates;
    }

    return indianStates.where((st) {
      return st.name.toLowerCase().contains(clean) ||
          st.nameTamil.toLowerCase().contains(clean) ||
          st.code.toLowerCase() == clean ||
          st.capital.toLowerCase().contains(clean);
    }).toList();
  }

  /// Recommend Indian and global cities, optionally filtered by state
  static List<GeocodingLocation> searchCities(String query, {String? stateFilter}) {
    final clean = query.trim().toLowerCase();
    var list = _offlineLocations;

    if (stateFilter != null && stateFilter.trim().isNotEmpty) {
      final sClean = stateFilter.trim().toLowerCase();
      final filtered = list.where((loc) => loc.state.toLowerCase().contains(sClean)).toList();
      if (filtered.isNotEmpty) {
        list = filtered;
      }
    }

    if (clean.isEmpty) {
      return list.take(15).toList();
    }

    final directMatches = list.where((loc) {
      return loc.cityName.toLowerCase().contains(clean) ||
          loc.displayName.toLowerCase().contains(clean) ||
          loc.state.toLowerCase().contains(clean);
    }).toList();

    return directMatches.take(15).toList();
  }

  /// Fast offline matching suggestions based on user query
  static List<GeocodingLocation> searchOffline(String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return _offlineLocations.take(12).toList();

    // 1. Direct contains check
    final directMatches = _offlineLocations.where((loc) {
      return loc.cityName.toLowerCase().contains(clean) ||
          loc.displayName.toLowerCase().contains(clean) ||
          loc.state.toLowerCase().contains(clean) ||
          loc.country.toLowerCase().contains(clean);
    }).toList();

    if (directMatches.length >= 3) {
      return directMatches.take(12).toList();
    }

    // 2. Tokenized match with abbreviation support (e.g. "Mumbai, MH", "Chennai, TN")
    final rawTokens = clean.split(RegExp(r'[\s,]+')).where((t) => t.isNotEmpty).toList();
    if (rawTokens.isEmpty) return directMatches.take(12).toList();

    final expandedTokens = rawTokens.map((t) => _stateAbbreviations[t] ?? t).toList();

    final scored = <GeocodingLocation, int>{};
    for (final loc in _offlineLocations) {
      final combined = '${loc.cityName} ${loc.displayName} ${loc.state} ${loc.country}'.toLowerCase();
      int score = 0;

      for (int i = 0; i < expandedTokens.length; i++) {
        final token = expandedTokens[i];
        if (loc.cityName.toLowerCase().startsWith(token)) {
          score += 10;
        } else if (loc.cityName.toLowerCase().contains(token)) {
          score += 6;
        } else if (combined.contains(token)) {
          score += 3;
        }
      }

      if (score > 0) {
        scored[loc] = score;
      }
    }

    final sorted = scored.keys.toList()..sort((a, b) => (scored[b] ?? 0).compareTo(scored[a] ?? 0));
    if (sorted.isNotEmpty) {
      return sorted.take(12).toList();
    }

    return directMatches.take(12).toList();
  }

  /// Resolve location with fast offline fallback and optional online Nominatim lookup
  static Future<List<GeocodingLocation>> searchPlaces(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return _offlineLocations.take(12).toList();

    // 1. First search internal offline dictionary
    final offlineResults = searchOffline(clean);
    if (offlineResults.isNotEmpty && offlineResults.length >= 3) {
      return offlineResults;
    }

    // 2. If query matches an Indian state name, also provide state capital
    final matchedStates = searchStates(clean);
    if (matchedStates.isNotEmpty && offlineResults.isEmpty) {
      final st = matchedStates.first;
      return [
        GeocodingLocation(
          cityName: st.capital,
          displayName: '${st.capital}, ${st.name}, India',
          state: st.name,
          country: 'India',
          latitude: st.latitude,
          longitude: st.longitude,
          timezone: 5.5,
        ),
      ];
    }

    // 3. If online and query has >= 3 chars, attempt live lookup
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(clean)}&format=json&addressdetails=1&limit=6',
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
    if (clean.isEmpty) return null;

    final matches = searchOffline(clean);
    if (matches.isNotEmpty) {
      return matches.first;
    }

    // Check if it's a state name
    final stateMatches = searchStates(clean);
    if (stateMatches.isNotEmpty) {
      final st = stateMatches.first;
      return GeocodingLocation(
        cityName: st.capital,
        displayName: '${st.capital}, ${st.name}, India',
        state: st.name,
        country: 'India',
        latitude: st.latitude,
        longitude: st.longitude,
        timezone: 5.5,
      );
    }

    return null;
  }
}
