import '../models/assistance_request.dart';
import 'api_client.dart';
import 'auth_service.dart';

/// Roadside assistance requests persisted in PostgreSQL via the API.
class AssistanceService {
  AssistanceService._();

  static final AssistanceService instance = AssistanceService._();

  Future<List<AssistanceRequest>> getRequests(String ownerEmail) async {
    final data = await ApiClient.instance.get(
      '/requests',
      token: AuthService.instance.token,
    );
    return (data as List<dynamic>)
        .map((e) => AssistanceRequest.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<AssistanceRequest> createRequest(
    String ownerEmail,
    AssistanceRequest request,
  ) async {
    final data = await ApiClient.instance.post(
      '/requests',
      body: request.toJson(),
      token: AuthService.instance.token,
    );
    return AssistanceRequest.fromJson(data as Map<String, dynamic>);
  }

  Future<void> updateStatus(
    String ownerEmail,
    String requestId,
    String status,
  ) async {
    await ApiClient.instance.patch(
      '/requests/$requestId',
      body: {'status': status},
      token: AuthService.instance.token,
    );
  }
}
