import '../models/bnn_method1_model.dart';

/// Centralized BNN Method 1 Planetary Relationship Engine
/// Evaluates classical directional friendship/enmity/neutrality.
class BnnMethod1PlanetRelationEngine {
  /// English to Tamil planet name mapping
  static const Map<String, String> keyToTamil = {
    'Sun': 'சூரியன்',
    'Moon': 'சந்திரன்',
    'Mars': 'செவ்வாய்',
    'Mercury': 'புதன்',
    'Jupiter': 'குரு',
    'Venus': 'சுக்கிரன்',
    'Saturn': 'சனி',
    'Rahu': 'ராகு',
    'Ketu': 'கேது',
  };

  /// Tamil to standard key mapping
  static const Map<String, String> tamilToKey = {
    'சூரியன்': 'Sun',
    'சந்திரன்': 'Moon',
    'செவ்வாய்': 'Mars',
    'புதன்': 'Mercury',
    'குரு': 'Jupiter',
    'சுக்கிரன்': 'Venus',
    'சனி': 'Saturn',
    'ராகு': 'Rahu',
    'கேது': 'Ketu',
  };

  /// Classical BNN Friendship Matrix (Source -> Target)
  static const Map<String, Map<String, BnnMethod1Relation>> _friendshipMatrix = {
    'Sun': {
      'Moon': BnnMethod1Relation.friend,
      'Mars': BnnMethod1Relation.friend,
      'Jupiter': BnnMethod1Relation.friend,
      'Mercury': BnnMethod1Relation.neutral,
      'Venus': BnnMethod1Relation.enemy,
      'Saturn': BnnMethod1Relation.enemy,
      'Rahu': BnnMethod1Relation.enemy,
      'Ketu': BnnMethod1Relation.enemy,
    },
    'Moon': {
      'Sun': BnnMethod1Relation.friend,
      'Mercury': BnnMethod1Relation.friend,
      'Mars': BnnMethod1Relation.neutral,
      'Jupiter': BnnMethod1Relation.neutral,
      'Venus': BnnMethod1Relation.neutral,
      'Saturn': BnnMethod1Relation.neutral,
      'Rahu': BnnMethod1Relation.enemy,
      'Ketu': BnnMethod1Relation.enemy,
    },
    'Mars': {
      'Sun': BnnMethod1Relation.friend,
      'Moon': BnnMethod1Relation.friend,
      'Jupiter': BnnMethod1Relation.friend,
      'Venus': BnnMethod1Relation.neutral,
      'Saturn': BnnMethod1Relation.neutral,
      'Ketu': BnnMethod1Relation.neutral,
      'Mercury': BnnMethod1Relation.enemy,
      'Rahu': BnnMethod1Relation.enemy,
    },
    'Mercury': {
      'Sun': BnnMethod1Relation.friend,
      'Venus': BnnMethod1Relation.friend,
      'Mars': BnnMethod1Relation.neutral,
      'Jupiter': BnnMethod1Relation.neutral,
      'Saturn': BnnMethod1Relation.neutral,
      'Rahu': BnnMethod1Relation.neutral,
      'Ketu': BnnMethod1Relation.neutral,
      'Moon': BnnMethod1Relation.enemy,
    },
    'Jupiter': {
      'Sun': BnnMethod1Relation.friend,
      'Moon': BnnMethod1Relation.friend,
      'Mars': BnnMethod1Relation.friend,
      'Saturn': BnnMethod1Relation.neutral,
      'Rahu': BnnMethod1Relation.neutral,
      'Ketu': BnnMethod1Relation.neutral,
      'Mercury': BnnMethod1Relation.enemy,
      'Venus': BnnMethod1Relation.enemy,
    },
    'Venus': {
      'Mercury': BnnMethod1Relation.friend,
      'Saturn': BnnMethod1Relation.friend,
      'Rahu': BnnMethod1Relation.friend,
      'Ketu': BnnMethod1Relation.friend,
      'Mars': BnnMethod1Relation.neutral,
      'Jupiter': BnnMethod1Relation.neutral,
      'Sun': BnnMethod1Relation.enemy,
      'Moon': BnnMethod1Relation.enemy,
    },
    'Saturn': {
      'Mercury': BnnMethod1Relation.friend,
      'Venus': BnnMethod1Relation.friend,
      'Rahu': BnnMethod1Relation.friend,
      'Jupiter': BnnMethod1Relation.neutral,
      'Ketu': BnnMethod1Relation.neutral,
      'Sun': BnnMethod1Relation.enemy,
      'Moon': BnnMethod1Relation.enemy,
      'Mars': BnnMethod1Relation.enemy,
    },
    'Rahu': {
      'Venus': BnnMethod1Relation.friend,
      'Saturn': BnnMethod1Relation.friend,
      'Mercury': BnnMethod1Relation.friend,
      'Jupiter': BnnMethod1Relation.neutral,
      'Ketu': BnnMethod1Relation.neutral,
      'Sun': BnnMethod1Relation.enemy,
      'Moon': BnnMethod1Relation.enemy,
      'Mars': BnnMethod1Relation.enemy,
    },
    'Ketu': {
      'Mars': BnnMethod1Relation.friend,
      'Venus': BnnMethod1Relation.friend,
      'Jupiter': BnnMethod1Relation.friend,
      'Mercury': BnnMethod1Relation.neutral,
      'Saturn': BnnMethod1Relation.neutral,
      'Sun': BnnMethod1Relation.enemy,
      'Moon': BnnMethod1Relation.enemy,
      'Rahu': BnnMethod1Relation.enemy,
    },
  };

  /// Normalizes planet representation to standard English key
  static String normalizePlanetKey(String planetIdentifier) {
    if (tamilToKey.containsKey(planetIdentifier)) {
      return tamilToKey[planetIdentifier]!;
    }
    return planetIdentifier;
  }

  /// Evaluates relationship between sourcePlanet and targetPlanet.
  /// If relation is not defined, returns BnnMethod1Relation.neutral (சமம்).
  static BnnMethod1Relation getRelation(String sourcePlanet, String targetPlanet) {
    final sKey = normalizePlanetKey(sourcePlanet);
    final tKey = normalizePlanetKey(targetPlanet);

    if (sKey == tKey) {
      return BnnMethod1Relation.friend;
    }

    final sourceMap = _friendshipMatrix[sKey];
    if (sourceMap == null) {
      return BnnMethod1Relation.neutral;
    }

    return sourceMap[tKey] ?? BnnMethod1Relation.neutral;
  }
}
