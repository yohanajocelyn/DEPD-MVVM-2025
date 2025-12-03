abstract class ShippingCosts {
  String? get displayName;    // Corresponds to 'name'
  String? get displayCode;
  String? get displayService; // Corresponds to 'service'
  double? get displayCost;    // Standardize to double
  String? get displayEtd;     // Corresponds to 'etd'
  String? get currencyCode;   // 'IDR' for domestic, dynamic for international
  String? get description;
}