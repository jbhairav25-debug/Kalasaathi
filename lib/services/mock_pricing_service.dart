import '../data/mock_data.dart';

/// Mock Pricing Service
/// Calculates cost floor and suggested selling range using production costs
/// and mock comparable market prices.
/// Replace comparable prices with real market data API when backend is ready.
class MockPricingService {
  /// Calculates the production cost floor.
  static double calculateCostFloor({
    required double materialCost,
    required double workHours,
    required double hourlyWage,
    required double packagingCost,
  }) {
    final labourCost = workHours * hourlyWage;
    return materialCost + labourCost + packagingCost;
  }

  /// Returns suggested selling range based on cost floor and comparable prices.
  static Map<String, dynamic> getSuggestedPricing({
    required double costFloor,
  }) {
    final comparables = MockData.getComparablePrices(costFloor);
    final avgMarketPrice = comparables.reduce((a, b) => a + b) / comparables.length;

    // Suggested range: at least cost floor, up to avg market + margin
    final minSuggested = (costFloor * 1.10).roundToDouble();
    final maxSuggested = (avgMarketPrice * 1.10).roundToDouble();
    final recommended = ((minSuggested + maxSuggested) / 2).roundToDouble();

    return {
      'costFloor': costFloor,
      'comparablePrices': comparables,
      'avgMarketPrice': avgMarketPrice,
      'minSuggested': minSuggested,
      'maxSuggested': maxSuggested,
      'recommended': recommended,
    };
  }

  // TODO: Replace with real API call
  // static Future<Map<String, dynamic>> getMarketPricesReal(String category) async {
  //   final response = await http.get(
  //     Uri.parse('$baseUrl/api/market-prices?category=$category'),
  //   );
  //   return jsonDecode(response.body);
  // }
}
