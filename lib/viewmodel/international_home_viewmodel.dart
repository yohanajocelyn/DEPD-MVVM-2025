import 'package:flutter/material.dart';
import 'package:depd_mvvm_2025/model/model.dart';
import 'package:depd_mvvm_2025/data/response/api_response.dart';
import 'package:depd_mvvm_2025/data/response/status.dart';
import 'package:depd_mvvm_2025/repository/international_home_repository.dart';

class InternationalHomeViewModel with ChangeNotifier {
  final _homeRepo = InternationalHomeRepository();

  ApiResponse<List<Province>> provinceList = ApiResponse.notStarted();
  
  setProvinceList(ApiResponse<List<Province>> response) {
    provinceList = response;
    notifyListeners();
  }

  Future getProvinceList() async {
    setProvinceList(ApiResponse.loading());
    _homeRepo.fetchProvinceList().then((value) {
      setProvinceList(ApiResponse.completed(value));
    }).onError((error, stackTrace) {
      setProvinceList(ApiResponse.error(error.toString()));
    });
  }

  final Map<int, List<City>> _cityCache = {};
  ApiResponse<List<City>> cityOriginList = ApiResponse.notStarted();

  setCityOriginList(ApiResponse<List<City>> response) {
    cityOriginList = response;
    notifyListeners();
  }

  Future getCityOriginList(int provId) async {
    if (_cityCache.containsKey(provId)) {
      setCityOriginList(ApiResponse.completed(_cityCache[provId]!));
      return;
    }
    setCityOriginList(ApiResponse.loading());
    _homeRepo.fetchCityList(provId).then((value) {
      _cityCache[provId] = value;
      setCityOriginList(ApiResponse.completed(value));
    }).onError((error, _) {
      setCityOriginList(ApiResponse.error(error.toString()));
    });
  }

  ApiResponse<List<Country>> countryList = ApiResponse.notStarted();
  
  setCountryList(ApiResponse<List<Country>> response) {
    countryList = response;
    notifyListeners();
  }

  Future<List<Country>> searchCountries(String query) async {
    try {
      // Only search if query is long enough to save API calls
      if (query.length < 3) return []; 
      
      return await _homeRepo.fetchCountryList(query);
    } catch (e) {
      // Return empty list on error to prevent UI crash
      debugPrint("Search Error: $e");
      return [];
    }
  }

  ApiResponse<List<InternationalCosts>> costList = ApiResponse.notStarted();
  
  setCostList(ApiResponse<List<InternationalCosts>> response) {
    costList = response;
    notifyListeners();
  }

  bool isLoading = false;
  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future checkShipmentCost(
    String origin,
    String destination,
    int weight,
    String courier,
  ) async {
    setLoading(true);
    setCostList(ApiResponse.loading());
    
    _homeRepo.checkShipmentCost(
      origin,
      destination,
      weight,
      courier,
    ).then((value) {
      setCostList(ApiResponse.completed(value));
      setLoading(false);
    }).onError((error, _) {
      setCostList(ApiResponse.error(error.toString()));
      setLoading(false);
    });
  }
}