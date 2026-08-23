/// Model representing structured Horoscope Notes (ஜாதக குறிப்புகள்)
class JaathagaKurippugalResult {
  // Birth Profile
  final String personName;
  final String gender;
  final String age;
  final String englishDate;
  final String tamilDate;
  final String weekday;
  final String timeOfBirth;
  final String placeOfBirth;

  // Horoscope Core
  final String lagna;
  final String lagnaDegree;
  final String rasi;
  final String nakshatra;
  final String pada;
  final String starLord;

  // Panchangam Details
  final String thithi;
  final String paksha;
  final String yoga;
  final String karanam;
  final String amirthathiYoga;
  final String mukkunaVelai;

  // Sun Timings
  final String sunrise;
  final String sunset;

  // Special Astrology Details
  final String thithiSunyam;
  final String nameLetters;
  final String avaYogi;
  final String anuYogi;
  final String gana;
  final String yoni;
  final String rajju;
  final String bird;
  final String tree;
  final String treeType;

  // Nazhigai Metrics
  final String udayathiNazhi;
  final String nakshatraNazhi;
  final String hora;

  // Akas, Nendhiram, Jeevan
  final String akas;
  final String nendhiram;
  final String jeevan;

  const JaathagaKurippugalResult({
    required this.personName,
    required this.gender,
    required this.age,
    required this.englishDate,
    required this.tamilDate,
    required this.weekday,
    required this.timeOfBirth,
    required this.placeOfBirth,
    required this.lagna,
    required this.lagnaDegree,
    required this.rasi,
    required this.nakshatra,
    required this.pada,
    required this.starLord,
    required this.thithi,
    required this.paksha,
    required this.yoga,
    required this.karanam,
    required this.amirthathiYoga,
    required this.mukkunaVelai,
    required this.sunrise,
    required this.sunset,
    required this.thithiSunyam,
    required this.nameLetters,
    required this.avaYogi,
    required this.anuYogi,
    required this.gana,
    required this.yoni,
    required this.rajju,
    required this.bird,
    required this.tree,
    required this.treeType,
    required this.udayathiNazhi,
    required this.nakshatraNazhi,
    required this.hora,
    required this.akas,
    required this.nendhiram,
    required this.jeevan,
  });
}
