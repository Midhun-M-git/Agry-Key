class AIService {
  static String getResponse(String query) {

    query = query.toLowerCase();

    if (query.contains("weather")) {
      return "Today's weather is sunny with 28°C temperature.";
    }

    if (query.contains("market")) {
      return "Current market prices are available in the Market section.";
    }

    if (query.contains("crop")) {
      return "Crop advisory recommends monitoring soil moisture.";
    }

    if (query.contains("disease")) {
      return "Upload a crop image in Disease Detection for analysis.";
    }

    return "I am AGRI KEY AI Assistant. Please ask about weather, market, crops or diseases.";
  }
}