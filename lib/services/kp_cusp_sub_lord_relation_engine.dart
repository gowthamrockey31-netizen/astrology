import '../models/kp_astrology_model.dart';
import 'astrology_calculator.dart';

/// Calculation Engine for KP Cusp Sub Lord House Relations (KP பாவ உப நட்சத்திராதிபதி தொடர்பு)
/// 
/// For every KP Cusp from House 1 to House 12, calculates:
/// 1. Cusp Sub Lord occupied house & owned houses.
/// 2. Sub Lord's Star Lord occupied house & owned houses.
/// 3. Special Node rules for Rahu / Ketu (Occupied, Star Lord, Sign Lord, Conjunctions).
/// 4. Merges, deduplicates, and sorts the resulting house numbers in ascending order (1..12).
class KpCuspSubLordRelationEngine {
  /// Node identification
  static bool isNode(String planetName) {
    final clean = planetName.trim().toLowerCase();
    return clean == 'rahu' ||
        clean == 'ketu' ||
        clean == 'ராகு' ||
        clean == 'கேது' ||
        planetName == 'ராகு' ||
        planetName == 'கேது';
  }

  /// Match planet detail safely by Tamil or English name
  static KpPlanetDetail? findPlanet(List<KpPlanetDetail> planets, String name) {
    final cleanName = name.trim();
    for (final p in planets) {
      if (p.planetNameTa == cleanName ||
          p.planetNameEn.equalsIgnoreCase(cleanName) ||
          AstrologyCalculator.planetNameToTamil[p.planetNameEn] == cleanName ||
          AstrologyCalculator.planetNameToTamil[cleanName] == p.planetNameTa) {
        return p;
      }
    }
    return null;
  }

  /// Determine houses owned by a planet based on KP Cusp sign lordships
  static List<int> getOwnedHouses(List<KpCuspDetail> cusps, KpPlanetDetail planet) {
    final List<int> owned = [];
    for (final cusp in cusps) {
      if (cusp.signLordTa == planet.planetNameTa ||
          AstrologyCalculator.planetNameToTamil[cusp.signLordTa] == planet.planetNameTa ||
          AstrologyCalculator.planetNameToTamil[planet.planetNameEn] == cusp.signLordTa) {
        if (cusp.cuspNumber >= 1 && cusp.cuspNumber <= 12) {
          owned.add(cusp.cuspNumber);
        }
      }
    }
    owned.sort();
    return owned;
  }

  /// Compute the KP Cusp Sub Lord House Relation table for all 12 cusps
  static List<KpCuspHouseRelationResult> calculateRelationTable({
    required List<KpCuspDetail> cusps,
    required List<KpPlanetDetail> planets,
  }) {
    // Sort cusps 1 through 12 to ensure proper sequential ordering
    final sortedCusps = List<KpCuspDetail>.from(cusps)
      ..sort((a, b) => a.cuspNumber.compareTo(b.cuspNumber));

    final List<KpCuspHouseRelationResult> results = [];
    const double nakSpan = 360.0 / 27.0;

    for (final cusp in sortedCusps) {
      final int nakIdx = (cusp.cuspLongitude / nakSpan).floor() % 27;
      final String nakTa = AstrologyCalculator.nakshatrasTa[nakIdx];
      final String nakEn = AstrologyCalculator.nakshatrasEn[nakIdx];

      final String subLordName = cusp.subLordTa;
      final KpPlanetDetail? subLordPlanet = findPlanet(planets, subLordName);

      final Set<int> relatedHousesSet = {};
      final List<int> subLordOccupied = [];
      final List<int> subLordOwned = [];
      final List<int> starLordOccupied = [];
      final List<int> starLordOwned = [];
      final List<int> nodeSignLordHouses = [];
      final List<String> conjunctPlanetsTa = [];
      final List<int> conjunctPlanetsHouses = [];

      String subLordStarLordTa = '-';
      String? nodeSignLordTa;
      bool isSubLordNode = isNode(subLordName);

      if (subLordPlanet != null) {
        // Level 1: Sub Lord Occupation
        if (subLordPlanet.cuspOccupied >= 1 && subLordPlanet.cuspOccupied <= 12) {
          subLordOccupied.add(subLordPlanet.cuspOccupied);
          relatedHousesSet.add(subLordPlanet.cuspOccupied);
        }

        // Level 2: Sub Lord Ownership (Non-nodes or node-owned)
        final ownedBySub = getOwnedHouses(sortedCusps, subLordPlanet);
        subLordOwned.addAll(ownedBySub);
        relatedHousesSet.addAll(ownedBySub);

        // Sub Lord's Star Lord
        subLordStarLordTa = subLordPlanet.starLordTa;
        final KpPlanetDetail? starLordPlanet = findPlanet(planets, subLordStarLordTa);

        if (starLordPlanet != null) {
          // Level 3: Star Lord Occupation
          if (starLordPlanet.cuspOccupied >= 1 && starLordPlanet.cuspOccupied <= 12) {
            starLordOccupied.add(starLordPlanet.cuspOccupied);
            relatedHousesSet.add(starLordPlanet.cuspOccupied);
          }

          // Level 3: Star Lord Ownership
          final ownedByStar = getOwnedHouses(sortedCusps, starLordPlanet);
          starLordOwned.addAll(ownedByStar);
          relatedHousesSet.addAll(ownedByStar);

          // If Star Lord is a Node (Rahu/Ketu), include its Node Sign Lord
          if (isNode(starLordPlanet.planetNameTa)) {
            final starNodeSignLord = findPlanet(planets, starLordPlanet.signLordTa);
            if (starNodeSignLord != null) {
              if (starNodeSignLord.cuspOccupied >= 1 && starNodeSignLord.cuspOccupied <= 12) {
                relatedHousesSet.add(starNodeSignLord.cuspOccupied);
              }
              final starSignLordOwned = getOwnedHouses(sortedCusps, starNodeSignLord);
              relatedHousesSet.addAll(starSignLordOwned);
            }
          }
        }

        // Special Node Logic if Sub Lord is Rahu or Ketu
        if (isSubLordNode) {
          // Node's Sign Lord
          nodeSignLordTa = subLordPlanet.signLordTa;
          final KpPlanetDetail? nodeSignLordPlanet = findPlanet(planets, nodeSignLordTa);
          if (nodeSignLordPlanet != null) {
            if (nodeSignLordPlanet.cuspOccupied >= 1 && nodeSignLordPlanet.cuspOccupied <= 12) {
              nodeSignLordHouses.add(nodeSignLordPlanet.cuspOccupied);
              relatedHousesSet.add(nodeSignLordPlanet.cuspOccupied);
            }
            final signLordOwned = getOwnedHouses(sortedCusps, nodeSignLordPlanet);
            nodeSignLordHouses.addAll(signLordOwned);
            relatedHousesSet.addAll(signLordOwned);
          }

          // Node's Conjunctions (Planets occupying same cusp as the Node)
          for (final p in planets) {
            if (p.planetNameTa != subLordPlanet.planetNameTa &&
                p.cuspOccupied == subLordPlanet.cuspOccupied) {
              conjunctPlanetsTa.add(p.planetNameTa);
              if (p.cuspOccupied >= 1 && p.cuspOccupied <= 12) {
                conjunctPlanetsHouses.add(p.cuspOccupied);
                relatedHousesSet.add(p.cuspOccupied);
              }
              final conjOwned = getOwnedHouses(sortedCusps, p);
              conjunctPlanetsHouses.addAll(conjOwned);
              relatedHousesSet.addAll(conjOwned);
            }
          }
        }
      }

      // Filter to strictly 1..12 and sort ascending
      final List<int> finalSortedHouses = relatedHousesSet
          .where((h) => h >= 1 && h <= 12)
          .toList()
        ..sort();

      results.add(KpCuspHouseRelationResult(
        houseNumber: cusp.cuspNumber,
        cuspLongitude: cusp.cuspLongitude,
        nakshatraNameTa: nakTa,
        nakshatraNameEn: nakEn,
        cuspStarLordTa: cusp.starLordTa,
        cuspSubLordTa: cusp.subLordTa,
        subLordOccupiedHouses: subLordOccupied,
        subLordOwnedHouses: subLordOwned,
        subLordStarLordTa: subLordStarLordTa,
        starLordOccupiedHouses: starLordOccupied,
        starLordOwnedHouses: starLordOwned,
        isSubLordNode: isSubLordNode,
        nodeSignLordTa: nodeSignLordTa,
        nodeSignLordHouses: nodeSignLordHouses.toSet().toList()..sort(),
        conjunctPlanetsTa: conjunctPlanetsTa,
        conjunctPlanetsHouses: conjunctPlanetsHouses.toSet().toList()..sort(),
        finalRelatedHouses: finalSortedHouses,
      ));
    }

    return results;
  }
}

extension on String {
  bool equalsIgnoreCase(String other) => toLowerCase() == other.toLowerCase();
}
