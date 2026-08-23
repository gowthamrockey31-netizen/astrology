class TaraResult {
  final int birthNakshatraIndex; // 0..26
  final int currentNakshatraIndex; // 0..26
  final String birthNakshatraName;
  final String currentNakshatraName;
  final int count; // 1..27
  final int taraNumber; // 1..9
  final String taraName; // e.g. ஜன்ம தாரா
  final String nature; // e.g. சாதாரணம்
  final String result; // e.g. மனநிலை மற்றும் உடல்நிலையில் கவனம் தேவை.

  const TaraResult({
    required this.birthNakshatraIndex,
    required this.currentNakshatraIndex,
    required this.birthNakshatraName,
    required this.currentNakshatraName,
    required this.count,
    required this.taraNumber,
    required this.taraName,
    required this.nature,
    required this.result,
  });
}
