import 'package:depd_mvvm_2025/data/network/network_api_service.dart';
import 'package:depd_mvvm_2025/model/model.dart';

// Repository untuk menangani logika bisnis terkait data ongkir
class InternationalHomeRepository {
  // NetworkApiServices hanya perlu 1 instance sehingga tidak perlu ganti service selama aplikasi berjalan
  final _apiServices = NetworkApiServices();

  Future<List<Province>> fetchProvinceList() async {
    final response = await _apiServices.getApiResponse('destination/province');

    // Validasi response meta
    final meta = response['meta'];
    if (meta == null || meta['status'] != 'success') {
      throw Exception("API Error: ${meta?['message'] ?? 'Unknown error'}");
    }

    // Parse data provinsi
    final data = response['data'];
    if (data is! List) return [];

    // Ubah setiap item (Map) menjadi object Province
    return data.map((e) => Province.fromJson(e)).toList();
  }

  // Mengambil daftar kota berdasarkan ID provinsi
  Future<List<City>> fetchCityList(var provId) async {
    final response = await _apiServices.getApiResponse(
      'destination/city/$provId',
    );

    // Validasi response meta
    final meta = response['meta'];
    if (meta == null || meta['status'] != 'success') {
      throw Exception("API Error: ${meta?['message'] ?? 'Unknown error'}");
    }

    // Parse data kota
    final data = response['data'];
    if (data is! List) return [];

    return data.map((e) => City.fromJson(e)).toList();
  }

  // Mengambil daftar provinsi dari API
  Future<List<Country>> fetchCountryList(String query) async {
    // We append the search query to the URL
    final response = await _apiServices.getApiResponse(
      'destination/international-destination?search=$query',
    );

    final meta = response['meta'];
    if (meta == null || meta['status'] != 'success') {
      throw Exception("API Error: ${meta?['message'] ?? 'Unknown error'}");
    }

    final data = response['data'];
    if (data is! List) return [];

    return data.map((e) => Country.fromJson(e)).toList();
  }

  // Menghitung biaya pengiriman berdasarkan parameter yang diberikan
  Future<List<InternationalCosts>> checkShipmentCost(
    String origin,
    String destination,
    int weight,
    String courier,
  ) async {
    int attempts = 0;
    int maxRetries = 3; // Retry up to 3 times

    while (attempts < maxRetries) {
      try {
        attempts++;
        
        // --- YOUR EXISTING API CALL ---
        final response = await _apiServices.postApiResponse(
          'calculate/international-cost', 
          {
            "origin": origin,
            "destination": destination,
            "weight": weight.toString(),
            "courier": courier,
          }
        );

        final meta = response['meta'];
        
        // If success, break the loop and process data
        if (meta != null && meta['status'] == 'success') {
          final data = response['data'];
          if (data is! List) return [];
          return data.map((e) => InternationalCosts.fromJson(e)).toList();
        } 
        
        // If specific 404 "Not Found", treat as failure and trigger retry loop
        if (meta != null && meta['code'] == 404) {
           throw Exception(meta['message']); 
        }
        
      } catch (e) {
        // Log the error
        print("Attempt $attempts failed: $e");

        // If we reached max retries, throw the error to the UI
        if (attempts >= maxRetries) {
          throw Exception("Gagal mengambil data setelah $attempts percobaan. Server sibuk.");
        }

        // Wait 1 second before retrying (Backoff strategy)
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    
    return [];
  }
}
