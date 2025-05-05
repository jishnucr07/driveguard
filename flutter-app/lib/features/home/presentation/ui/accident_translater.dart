import 'package:flutter/material.dart';

class AccidentInputTranslator {
  // Valid values from API
  static const Map<String, List<String>> validValues = {
    "Weather": [
      "clear",
      "cloudy",
      "light rain",
      "heavy rain",
      "thunderstorm with heavy rain",
      "snow",
      "fog"
    ],
    "Road_Type": [
      "highway",
      "city_street",
      "rural",
      "mountain_pass",
      "residential",
      "bridge"
    ],
    "Road_Condition": ["dry", "wet", "icy", "snowy", "under_construction"],
    "Vehicle_Type": ["sedan", "suv", "truck", "motorcycle", "bus", "van"],
    "Road_Light_Condition": [
      "daylight",
      "dawn_dusk",
      "night",
      "night_with_streetlights"
    ],
  };

  // Weather translation mapping - Enhanced with OpenWeatherMap codes and descriptions
  static String translateWeather(String input) {
    input = input.toLowerCase().trim();

    // Direct matches
    if (validValues["Weather"]!.contains(input)) {
      return input;
    }

    // Extended mapping including OpenWeatherMap codes and descriptions
    Map<String, String> weatherMap = {
      // Clear conditions (OpenWeatherMap Group 800)
      "800": "clear",
      "clear sky": "clear",
      "sunny": "clear",
      "sunshine": "clear",
      "fair": "clear",
      "bright": "clear",
      "fine": "clear",

      // Cloudy conditions (OpenWeatherMap Groups 801-804)
      "801": "cloudy",
      "802": "cloudy",
      "803": "cloudy",
      "804": "cloudy",
      "few clouds": "cloudy",
      "scattered clouds": "cloudy",
      "broken clouds": "cloudy",
      "overcast": "cloudy",
      "overcast clouds": "cloudy",
      "partly cloudy": "cloudy",
      "mostly cloudy": "cloudy",

      // Light rain conditions (OpenWeatherMap Groups 300-311, 500-501)
      "300": "light rain",
      "301": "light rain",
      "302": "light rain",
      "310": "light rain",
      "311": "light rain",
      "500": "light rain",
      "501": "light rain",
      "drizzle": "light rain",
      "light drizzle": "light rain",
      "light shower": "light rain",
      "light intensity drizzle": "light rain",
      "drizzle rain": "light rain",
      "light intensity drizzle rain": "light rain",
      "shower rain and drizzle": "light rain",
      "light rain and drizzle": "light rain",
      "light intensity shower rain": "light rain",
      "light intensity rain": "light rain",
      "moderate rain": "light rain",
      "rainy": "light rain",
      "scattered showers": "light rain",
      "sprinkle": "light rain",
      "misty rain": "light rain",

      // Heavy rain conditions (OpenWeatherMap Groups 312-321, 502-504, 520-531)
      "312": "heavy rain",
      "313": "heavy rain",
      "314": "heavy rain",
      "321": "heavy rain",
      "502": "heavy rain",
      "503": "heavy rain",
      "504": "heavy rain",
      "520": "heavy rain",
      "521": "heavy rain",
      "522": "heavy rain",
      "531": "heavy rain",
      "heavy intensity rain": "heavy rain",
      "very heavy rain": "heavy rain",
      "extreme rain": "heavy rain",
      "freezing rain": "heavy rain",
      "heavy intensity shower rain": "heavy rain",
      "shower rain": "heavy rain",
      "heavy shower rain and drizzle": "heavy rain",
      "shower drizzle": "heavy rain",
      "downpour": "heavy rain",
      "storm": "heavy rain",
      "heavy shower": "heavy rain",
      "torrential rain": "heavy rain",
      "consistent rain": "heavy rain",

      // Thunderstorm conditions (OpenWeatherMap Group 200-232)
      "200": "thunderstorm with heavy rain",
      "201": "thunderstorm with heavy rain",
      "202": "thunderstorm with heavy rain",
      "210": "thunderstorm with heavy rain",
      "211": "thunderstorm with heavy rain",
      "212": "thunderstorm with heavy rain",
      "221": "thunderstorm with heavy rain",
      "230": "thunderstorm with heavy rain",
      "231": "thunderstorm with heavy rain",
      "232": "thunderstorm with heavy rain",
      "thunderstorm": "thunderstorm with heavy rain",
      "thunderstorm with light rain": "thunderstorm with heavy rain",
      "thunderstorm with rain": "thunderstorm with heavy rain",
      "thunderstorm with heavy rain": "thunderstorm with heavy rain",
      "light thunderstorm": "thunderstorm with heavy rain",
      "heavy thunderstorm": "thunderstorm with heavy rain",
      "ragged thunderstorm": "thunderstorm with heavy rain",
      "thunderstorm with light drizzle": "thunderstorm with heavy rain",
      "thunderstorm with drizzle": "thunderstorm with heavy rain",
      "thunderstorm with heavy drizzle": "thunderstorm with heavy rain",
      "lightning": "thunderstorm with heavy rain",
      "thunder": "thunderstorm with heavy rain",
      "electrical storm": "thunderstorm with heavy rain",

      // Snow conditions (OpenWeatherMap Group 600-622)
      "600": "snow",
      "601": "snow",
      "602": "snow",
      "611": "snow",
      "612": "snow",
      "613": "snow",
      "615": "snow",
      "616": "snow",
      "620": "snow",
      "621": "snow",
      "622": "snow",
      "light snow": "snow",
      "snow": "snow",
      "heavy snow": "snow",
      "sleet": "snow",
      "light shower sleet": "snow",
      "shower sleet": "snow",
      "light rain and snow": "snow",
      "rain and snow": "snow",
      "light shower snow": "snow",
      "shower snow": "snow",
      "heavy shower snow": "snow",
      "snowfall": "snow",
      "blizzard": "snow",
      "hail": "snow",

      // Fog conditions (OpenWeatherMap Group 701-771)
      "701": "fog",
      "711": "fog",
      "721": "fog",
      "731": "fog",
      "741": "fog",
      "751": "fog",
      "761": "fog",
      "762": "fog",
      "771": "fog",
      "mist": "fog",
      "smoke": "fog",
      "haze": "fog",
      "sand/dust whirls": "fog",
      "fog": "fog",
      "sand": "fog",
      "dust": "fog",
      "volcanic ash": "fog",
      "squalls": "fog",
      "misty": "fog",
      "foggy": "fog",
      "smog": "fog",
      "reduced visibility": "fog"
    };

    // Check for match in mapping
    for (var key in weatherMap.keys) {
      if (input.contains(key)) {
        return weatherMap[key]!;
      }
    }

    // Default if no match found
    return "cloudy"; // Most neutral default
  }

  // Road Type translation - Enhanced with OpenStreetMap highway types
  static String translateRoadType(String input) {
    input = input.toLowerCase().trim();

    // Direct matches
    if (validValues["Road_Type"]!.contains(input)) {
      return input;
    }

    // Extended mapping including OpenStreetMap highway types
    Map<String, String> roadTypeMap = {
      // Highway types (OSM: motorway, trunk, primary)
      "motorway": "highway",
      "motorway_link": "highway",
      "trunk": "highway",
      "trunk_link": "highway",
      "primary": "highway",
      "primary_link": "highway",
      "freeway": "highway",
      "expressway": "highway",
      "interstate": "highway",
      "highway_link": "highway",

      // City street types (OSM: secondary, tertiary, unclassified, service)
      "secondary": "city_street",
      "secondary_link": "city_street",
      "tertiary": "city_street",
      "tertiary_link": "city_street",
      "unclassified": "city_street",
      "service": "city_street",
      "urban": "city_street",
      "downtown": "city_street",
      "city": "city_street",
      "main street": "city_street",
      "avenue": "city_street",
      "boulevard": "city_street",
      "town road": "city_street",

      // Rural types (OSM: track, path in rural areas)
      "track": "rural",
      "country": "rural",
      "countryside": "rural",
      "farm road": "rural",
      "village road": "rural",
      "dirt road": "rural",
      "gravel road": "rural",

      // Mountain pass types
      "mountain": "mountain_pass",
      "mountainous": "mountain_pass",
      "alpine": "mountain_pass",
      "hill": "mountain_pass",
      "slope": "mountain_pass",
      "winding": "mountain_pass",
      "pass": "mountain_pass",

      // Residential types (OSM: residential, living_street)
      "residential": "residential",
      "living_street": "residential",
      "suburban": "residential",
      "subdivision": "residential",
      "living area": "residential",
      "housing": "residential",
      "community": "residential",
      "neighborhood": "residential",

      // Bridge types (OSM: bridge=yes tag)
      "bridge": "bridge",
      "overpass": "bridge",
      "underpass": "bridge",
      "viaduct": "bridge",
      "crossing": "bridge",
      "flyover": "bridge",
      "tunnel": "bridge", // Not strictly accurate but closest match

      // Additional OSM highway types mapping
      "footway": "city_street",
      "pedestrian": "city_street",
      "steps": "city_street",
      "path": "rural",
      "cycleway": "city_street",
      "raceway": "highway",
      "road": "city_street",
      "construction":
          "under_construction" // Technically not a road type but shows construction
    };

    // Check for match in mapping
    for (var key in roadTypeMap.keys) {
      if (input.contains(key)) {
        return roadTypeMap[key]!;
      }
    }

    // Check for additional special cases from OSM
    if (input.contains("motorroad") || input.contains("toll")) {
      return "highway";
    }

    // Default if no match found
    return "city_street"; // Most common default
  }

  // Road Condition translation - Enhanced with weather condition impacts
  static String translateRoadCondition(String input) {
    input = input.toLowerCase().trim();

    // Direct matches
    if (validValues["Road_Condition"]!.contains(input)) {
      return input;
    }

    // Extended mapping
    Map<String, String> roadConditionMap = {
      // Dry conditions
      "normal": "dry",
      "good": "dry",
      "clear": "dry",
      "asphalt": "dry",
      "tarmac": "dry",
      "concrete": "dry",
      "paved": "dry",
      "bitumen": "dry",
      "sealed": "dry",

      // Wet conditions
      "damp": "wet",
      "moist": "wet",
      "rainy": "wet",
      "slippery": "wet",
      "puddles": "wet",
      "after rain": "wet",
      "rain": "wet",
      "drizzle": "wet",
      "storm": "wet",
      "flooded": "wet",
      "water": "wet",

      // Icy conditions
      "frozen": "icy",
      "slick": "icy",
      "black ice": "icy",
      "freezing": "icy",
      "frosty": "icy",
      "ice": "icy",
      "glazed": "icy",
      "frost": "icy",

      // Snowy conditions
      "snow covered": "snowy",
      "slushy": "snowy",
      "snowfall": "snowy",
      "snow packed": "snowy",
      "snow": "snowy",
      "blizzard": "snowy",
      "plowed": "snowy",
      "powder": "snowy",

      // Under construction conditions
      "roadwork": "under_construction",
      "construction": "under_construction",
      "repair": "under_construction",
      "maintenance": "under_construction",
      "closed": "under_construction",
      "work zone": "under_construction",
      "detour": "under_construction",
      "temporary": "under_construction",
      "construction zone": "under_construction",
      "work in progress": "under_construction"
    };

    // Check for match in mapping
    for (var key in roadConditionMap.keys) {
      if (input.contains(key)) {
        return roadConditionMap[key]!;
      }
    }

    // Map from surface types (common in OSM)
    Map<String, String> surfaceMap = {
      "asphalt": "dry",
      "concrete": "dry",
      "paved": "dry",
      "unpaved": "dry",
      "gravel": "dry",
      "dirt": "dry",
      "earth": "dry",
      "grass": "dry",
      "ground": "dry",
      "paving_stones": "dry",
      "cobblestone": "dry",
      "metal": "dry",
      "wood": "dry",
      "compacted": "dry",
      "fine_gravel": "dry",
      "pebblestone": "dry",
      "sand": "dry",
      "salt": "dry",
      "snow": "snowy",
      "ice": "icy",
      "mud": "wet"
    };

    // Check for surface types
    for (var key in surfaceMap.keys) {
      if (input.contains(key)) {
        return surfaceMap[key]!;
      }
    }

    // Default if no match found
    return "dry"; // Most common default
  }

  // Vehicle Type translation - Enhanced with more specific vehicle classifications
  static String translateVehicleType(String input) {
    input = input.toLowerCase().trim();

    // Direct matches
    if (validValues["Vehicle_Type"]!.contains(input)) {
      return input;
    }

    // Extended mapping
    Map<String, String> vehicleTypeMap = {
      // Sedan types
      "car": "sedan",
      "automobile": "sedan",
      "hatchback": "sedan",
      "compact": "sedan",
      "coupe": "sedan",
      "saloon": "sedan",
      "convertible": "sedan",
      "sports car": "sedan",
      "passenger car": "sedan",
      "station wagon": "sedan",
      "estate": "sedan",
      "liftback": "sedan",
      "fastback": "sedan",

      // SUV types
      "suv": "suv",
      "crossover": "suv",
      "4x4": "suv",
      "4wd": "suv",
      "sport utility": "suv",
      "sport utility vehicle": "suv",
      "jeep": "suv",
      "off-road": "suv",
      "off road": "suv",
      "all-terrain": "suv",
      "all terrain": "suv",

      // Truck types
      "pickup": "truck",
      "pick-up": "truck",
      "pickup truck": "truck",
      "lorry": "truck",
      "semi": "truck",
      "semi-truck": "truck",
      "18 wheeler": "truck",
      "tractor trailer": "truck",
      "dump truck": "truck",
      "tractor": "truck",
      "commercial truck": "truck",
      "commercial": "truck",
      "heavy duty": "truck",
      "flatbed": "truck",
      "tanker": "truck",
      "box truck": "truck",

      // Motorcycle types
      "bike": "motorcycle",
      "motorbike": "motorcycle",
      "motorcycle": "motorcycle",
      "scooter": "motorcycle",
      "moped": "motorcycle",
      "chopper": "motorcycle",
      "cruiser": "motorcycle",
      "sportbike": "motorcycle",
      "dirt bike": "motorcycle",
      "trike": "motorcycle",

      // Bus types
      "bus": "bus",
      "coach": "bus",
      "shuttle": "bus",
      "minibus": "bus",
      "transit": "bus",
      "school bus": "bus",
      "tour bus": "bus",
      "double decker": "bus",
      "articulated bus": "bus",
      "trolleybus": "bus",
      "passenger bus": "bus",

      // Van types
      "van": "van",
      "minivan": "van",
      "cargo van": "van",
      "delivery": "van",
      "delivery van": "van",
      "panel van": "van",
      "mpv": "van",
      "multi-purpose vehicle": "van",
      "passenger van": "van",
      "camper": "van",
      "campervan": "van",
      "caravan": "van"
    };

    // Check for match in mapping
    for (var key in vehicleTypeMap.keys) {
      if (input.contains(key)) {
        return vehicleTypeMap[key]!;
      }
    }

    // Default if no match found
    return "sedan"; // Most common default
  }

  // Road Light Condition translation - Enhanced with additional time detection
  static String translateRoadLightCondition(String input) {
    input = input.toLowerCase().trim();

    // Direct matches
    if (validValues["Road_Light_Condition"]!.contains(input)) {
      return input;
    }

    // Extended mapping
    Map<String, String> lightConditionMap = {
      // Daylight conditions
      "day": "daylight",
      "afternoon": "daylight",
      "morning": "daylight",
      "sunny": "daylight",
      "bright": "daylight",
      "midday": "daylight",
      "noon": "daylight",
      "daytime": "daylight",

      // Dawn/dusk conditions
      "dawn": "dawn_dusk",
      "dusk": "dawn_dusk",
      "twilight": "dawn_dusk",
      "sunset": "dawn_dusk",
      "sunrise": "dawn_dusk",
      "evening": "dawn_dusk",
      "early morning": "dawn_dusk",
      "late evening": "dawn_dusk",

      // Night conditions
      "night": "night",
      "darkness": "night",
      "midnight": "night",
      "late night": "night",
      "dark": "night",
      "overnight": "night",
      "pitch black": "night",
      "no light": "night",

      // Night with streetlights conditions
      "street lit": "night_with_streetlights",
      "street light": "night_with_streetlights",
      "streetlight": "night_with_streetlights",
      "lamp": "night_with_streetlights",
      "illuminated": "night_with_streetlights",
      "lit": "night_with_streetlights",
      "lighted": "night_with_streetlights",
      "artificial light": "night_with_streetlights",
      "well lit": "night_with_streetlights",
      "urban night": "night_with_streetlights"
    };

    // Check for match in mapping
    for (var key in lightConditionMap.keys) {
      if (input.contains(key)) {
        return lightConditionMap[key]!;
      }
    }

    // Time-based detection - More comprehensive for detecting time formats
    // Check if input contains numbers that might represent time
    RegExp timePattern = RegExp(r'(\d{1,2})[:\.]?(\d{2})?');
    var matches = timePattern.allMatches(input);

    if (matches.isNotEmpty) {
      try {
        var match = matches.first;
        int hour;

        // Extract hour from the first match
        if (match.group(1) != null) {
          hour = int.parse(match.group(1)!);

          // Adjust for PM indicator
          if (input.contains('pm') && hour < 12) {
            hour += 12;
          }
          // Adjust for AM indicator for 12 AM
          if (input.contains('am') && hour == 12) {
            hour = 0;
          }

          // Determine light condition based on hour
          if (hour >= 7 && hour < 18) {
            return "daylight";
          } else if ((hour >= 5 && hour < 7) || (hour >= 18 && hour < 20)) {
            return "dawn_dusk";
          } else {
            // Check if urban/street context for night
            if (input.contains("urban") ||
                input.contains("city") ||
                input.contains("town") ||
                input.contains("street") ||
                input.contains("residential")) {
              return "night_with_streetlights";
            } else {
              return "night";
            }
          }
        }
      } catch (e) {
        // If parsing fails, continue to default
      }
    }

    // Default if no match found
    return "daylight"; // Most common default
  }

  // Main translation function
  static Map<String, dynamic> translateAccidentInput(
      Map<String, dynamic> input) {
    Map<String, dynamic> translatedInput = Map.from(input);

    // Translate each field if present
    if (input.containsKey("Weather")) {
      translatedInput["Weather"] =
          translateWeather(input["Weather"].toString());
    }

    if (input.containsKey("Road_Type")) {
      translatedInput["Road_Type"] =
          translateRoadType(input["Road_Type"].toString());
    }

    if (input.containsKey("Road_Condition")) {
      translatedInput["Road_Condition"] =
          translateRoadCondition(input["Road_Condition"].toString());
    }

    if (input.containsKey("Vehicle_Type")) {
      translatedInput["Vehicle_Type"] =
          translateVehicleType(input["Vehicle_Type"].toString());
    }

    if (input.containsKey("Road_Light_Condition")) {
      translatedInput["Road_Light_Condition"] =
          translateRoadLightCondition(input["Road_Light_Condition"].toString());
    }

    // Remove the Accident_Severity field as it's not used for prediction
    translatedInput.remove("Accident_Severity");

    return translatedInput;
  }

  // Helper method to get dropdown items for each category
  static List<DropdownMenuItem<String>> getDropdownItems(String category) {
    return validValues[category]!.map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
  }

  // Helper to test the translator with typical values from external APIs
  static void testExternalAPIMappings() {
    // OpenWeatherMap test values
    final List<String> openWeatherValues = [
      "clear sky",
      "few clouds",
      "scattered clouds",
      "broken clouds",
      "overcast clouds",
      "light intensity drizzle",
      "thunderstorm with heavy rain",
      "snow",
      "mist",
      "smoke",
      "fog",
      "200",
      "500",
      "800"
    ];

    print("=== OpenWeatherMap Translations ===");
    for (var value in openWeatherValues) {
      print("'$value' -> '${translateWeather(value)}'");
    }

    // OpenStreetMap test values
    final List<String> openStreetMapValues = [
      "motorway",
      "trunk",
      "primary",
      "secondary",
      "residential",
      "living_street",
      "track",
      "path",
      "cycleway",
      "footway",
      "bridge",
      "tunnel",
      "construction"
    ];

    print("\n=== OpenStreetMap Translations ===");
    for (var value in openStreetMapValues) {
      print("'$value' -> '${translateRoadType(value)}'");
    }
  }

  // // Helper to translate your original input
  // static void translateOriginalExample() {
  //   final Map<String, dynamic> originalInput = {
  //     "Speed_Limit": 50,
  //     "Number_of_Vehicles": 1,
  //     "Driver_Age": 30,
  //     "Driver_Experience": 5,
  //     "Weather": "overcast clouds",
  //     "Road_Type": "trunk_link",
  //     "Time_of_Day": "20:11:08",
  //     "Traffic_Density": 1,
  //     "Road_Condition": "asphalt",
  //     "Vehicle_Type": "Car",
  //     "Road_Light_Condition": "night",
  //     "Accident_Severity": "Minor"
  //   };

  //   final translatedInput = translateAccidentInput(originalInput);

  //   print("\n=== Original Input Translation ===");
  //   print("Weather: '${originalInput['Weather']}' -> '${translatedInput['Weather']}'");
  //   print("Road_Type: '${originalInput['Road_Type']}' -> '${translatedInput['Road_Type']}'");
  //   print("Road_Condition: '${originalInput['Road_Condition']}' -> '${translatedInput['Road_Condition']}'");
  //   print("Vehicle_Type: '${originalInput['Vehicle_Type']}' -> '${translatedInput['Vehicle_Type']}'");
  //   print("Road_Light_Condition: '${originalInput['Road_Light_Condition']}' -> '${translatedInput['Road_Light_Condition']}'");
  //   print("Accident_Severity present in original: ${originalInput.containsKey('Accident_Severity')}");
  //   print("Accident_Severity present in translated: ${translatedInput.containsKey('Accident_Severity')}");
  // }
}
