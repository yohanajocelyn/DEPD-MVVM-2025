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
    // Kirim request POST untuk kalkulasi ongkir
    final response = await _apiServices
        .postApiResponse('calculate/international-cost', {
          "origin": origin,
          "destination": destination,
          "weight": weight.toString(),
          "courier": courier,
        });

    // Validasi response meta
    final meta = response['meta'];
    if (meta == null || meta['status'] != 'success') {
      throw Exception("API Error: ${meta?['message'] ?? 'Unknown error'}");
    }

    final data = response['data'];
    
    // === FIX STARTS HERE ===
    if (data is! List) return [];

    // Since the JSON is already flat (it has 'service', 'cost', 'name' directly),
    // we don't need the nested loops. We just convert it directly.
    return data.map((e) => InternationalCosts.fromJson(e)).toList();
  }
}
