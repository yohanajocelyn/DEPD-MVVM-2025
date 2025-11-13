abstract class BaseApiService {
  Future<dynamic> getApiResponse(String endpoint);
  Future<dynamic> postApiResponse(String endpoint, dynamic data);
}