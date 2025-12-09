import 'dart:convert';

import 'package:http/http.dart' as http;

/// Simple API client for talking to the Django backend.
class ApiClient {
  /// Change this if your backend runs on a different host/port.
  static const String baseUrl = 'https://apikumbh.pythonanywhere.com';
  // static const String baseUrl = 'http://192.168.1.15:8000';

  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<Map<String, dynamic>> register({
    required String email,
    required String fullName,
    required String password,
  }) async {
    final response = await _client.post(
      _uri('/api/user/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'full_name': fullName,
        'password': password,
      }),
    );

    final data = _decodeJson(response);
    _throwIfNotOk(response, data);
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      _uri('/api/user/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = _decodeJson(response);
    _throwIfNotOk(response, data);
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getProfile({
    required String accessToken,
  }) async {
    final response = await _client.get(
      _uri('/api/user/profile/'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    final data = _decodeJson(response);
    _throwIfNotOk(response, data);
    return data as Map<String, dynamic>;
  }

  // Zones APIs
  Future<List<Map<String, dynamic>>> getZones() async {
    final response = await _client.get(_uri('/api/zones/'));
    final data = _decodeJson(response);
    _throwIfNotOk(response, data);
    if (data is Map && data['results'] != null) {
      return List<Map<String, dynamic>>.from(data['results']);
    }
    return [];
  }

  Future<Map<String, dynamic>> getZone(int id) async {
    final response = await _client.get(_uri('/api/zones/$id/'));
    final data = _decodeJson(response);
    _throwIfNotOk(response, data);
    return data as Map<String, dynamic>;
  }

  // Amenities APIs
  Future<List<Map<String, dynamic>>> getAmenities({String? category}) async {
    final uri = category != null 
        ? _uri('/api/amenities/?category=$category')
        : _uri('/api/amenities/');
    final response = await _client.get(uri);
    final data = _decodeJson(response);
    _throwIfNotOk(response, data);
    if (data is Map && data['results'] != null) {
      return List<Map<String, dynamic>>.from(data['results']);
    }
    return [];
  }

  Future<Map<String, dynamic>> getAmenity(int id) async {
    final response = await _client.get(_uri('/api/amenities/$id/'));
    final data = _decodeJson(response);
    _throwIfNotOk(response, data);
    return data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getAmenityCategories() async {
    final response = await _client.get(_uri('/api/amenities/categories/'));
    final data = _decodeJson(response);
    _throwIfNotOk(response, data);
    if (data is Map && data['categories'] != null) {
      return List<Map<String, dynamic>>.from(data['categories']);
    }
    return [];
  }

  // SOS Request APIs
  Future<Map<String, dynamic>> createSosRequest({
    required String userEmail,
    String? userName,
    required String sosType,
    required double latitude,
    required double longitude,
    String? description,
    String? accessToken,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    // Format coordinates to 6 decimal places (max 9 digits total)
    final formattedLat = double.parse(latitude.toStringAsFixed(6));
    final formattedLng = double.parse(longitude.toStringAsFixed(6));

    final requestBody = <String, dynamic>{
      'user_email': userEmail,
      'sos_type': sosType,
      'latitude': formattedLat.toString(),
      'longitude': formattedLng.toString(),
    };
    
    if (userName != null && userName.isNotEmpty) {
      requestBody['user_name'] = userName;
    }
    
    if (description != null && description.isNotEmpty) {
      requestBody['description'] = description;
    }

    print('Sending SOS request with data: $requestBody');

    final response = await _client.post(
      _uri('/api/sos-requests/'),
      headers: headers,
      body: jsonEncode(requestBody),
    );

    final data = _decodeJson(response);
    if (response.statusCode >= 400) {
      print('SOS Request Error - Status: ${response.statusCode}');
      print('SOS Request Error - Body: ${response.body}');
      print('SOS Request Error - Data: $data');
    }
    _throwIfNotOk(response, data);
    return data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getSosRequests({String? status}) async {
    final uri = status != null 
        ? _uri('/api/sos-requests/?status=$status')
        : _uri('/api/sos-requests/');
    final response = await _client.get(uri);
    final data = _decodeJson(response);
    _throwIfNotOk(response, data);
    if (data is Map && data['results'] != null) {
      return List<Map<String, dynamic>>.from(data['results']);
    }
    return [];
  }

  Future<Map<String, dynamic>> getSosRequest(int id) async {
    final response = await _client.get(_uri('/api/sos-requests/$id/'));
    final data = _decodeJson(response);
    _throwIfNotOk(response, data);
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateSosRequest(
    int id, {
    String? status,
    String? assignedTeam,
    String? accessToken,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    final body = <String, dynamic>{};
    if (status != null) body['status'] = status;
    if (assignedTeam != null) body['assigned_team'] = assignedTeam;

    final response = await _client.patch(
      _uri('/api/sos-requests/$id/'),
      headers: headers,
      body: jsonEncode(body),
    );

    final data = _decodeJson(response);
    _throwIfNotOk(response, data);
    return data as Map<String, dynamic>;
  }

  // Family Member APIs
  Future<List<Map<String, dynamic>>> getFamilyMembers({required String userEmail}) async {
    final uri = _uri('/api/family-members/?user_email=$userEmail');
    final response = await _client.get(uri);
    final data = _decodeJson(response);
    _throwIfNotOk(response, data);
    if (data is Map && data['results'] != null) {
      return List<Map<String, dynamic>>.from(data['results']);
    }
    return [];
  }

  Future<Map<String, dynamic>> createFamilyMember({
    required String userEmail,
    required String name,
    required String phone,
    required String relationship,
    String? accessToken,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    final response = await _client.post(
      _uri('/api/family-members/'),
      headers: headers,
      body: jsonEncode({
        'user_email': userEmail,
        'name': name,
        'phone': phone,
        'relationship': relationship,
      }),
    );

    final data = _decodeJson(response);
    _throwIfNotOk(response, data);
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateFamilyMember(
    int id, {
    String? name,
    String? phone,
    String? relationship,
    double? latitude,
    double? longitude,
    String? accessToken,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (relationship != null) body['relationship'] = relationship;
    if (latitude != null) body['latitude'] = latitude.toStringAsFixed(6);
    if (longitude != null) body['longitude'] = longitude.toStringAsFixed(6);

    final response = await _client.patch(
      _uri('/api/family-members/$id/'),
      headers: headers,
      body: jsonEncode(body),
    );

    final data = _decodeJson(response);
    _throwIfNotOk(response, data);
    return data as Map<String, dynamic>;
  }

  Future<void> deleteFamilyMember(int id, {String? accessToken}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    final response = await _client.delete(
      _uri('/api/family-members/$id/'),
      headers: headers,
    );

    _throwIfNotOk(response, null);
  }

  // Family Invitation APIs
  Future<Map<String, dynamic>> createFamilyInvitation({
    required String inviterEmail,
    required String inviteeEmail,
    String? relationship,
    String? accessToken,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    final response = await _client.post(
      _uri('/api/family-invitations/create/'),
      headers: headers,
      body: jsonEncode({
        'inviter_email': inviterEmail,
        'invitee_email': inviteeEmail,
        if (relationship != null && relationship.isNotEmpty) 'relationship': relationship,
      }),
    );

    final data = _decodeJson(response);
    _throwIfNotOk(response, data);
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getFamilyInvitation(String token) async {
    final uri = _uri('/api/family-invitations/accept/?token=$token');
    final response = await _client.get(uri);
    final data = _decodeJson(response);
    _throwIfNotOk(response, data);
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> acceptFamilyInvitation({
    required String token,
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      _uri('/api/family-invitations/accept/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
        'email': email,
        'password': password,
      }),
    );

    final data = _decodeJson(response);
    _throwIfNotOk(response, data);
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateUserLocation({
    required String userEmail,
    required double latitude,
    required double longitude,
    String? accessToken,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    final response = await _client.post(
      _uri('/api/family-members/update-location/'),
      headers: headers,
      body: jsonEncode({
        'user_email': userEmail,
        'latitude': latitude.toStringAsFixed(6),
        'longitude': longitude.toStringAsFixed(6),
      }),
    );

    final data = _decodeJson(response);
    _throwIfNotOk(response, data);
    return data as Map<String, dynamic>;
  }

  // Lost & Found APIs
  Future<Map<String, dynamic>> getLostFoundReports({
    String? type,
    String? status,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (type != null && type.isNotEmpty) queryParams['type'] = type;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    var uri = _uri('/api/lost-found/');
    if (queryParams.isNotEmpty) {
      final queryString = queryParams.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
      uri = Uri.parse('${uri.toString()}?$queryString');
    }

    final response = await _client.get(uri);
    final data = _decodeJson(response);
    _throwIfNotOk(response, data);
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createLostFoundReport({
    required String reportType,
    required String userEmail,
    required String personName,
    required String description,
    required String location,
    String? userName,
    String? userPhone,
    int? age,
    double? latitude,
    double? longitude,
    String? photoUrl,
    String? accessToken,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    final body = <String, dynamic>{
      'report_type': reportType,
      'user_email': userEmail,
      'person_name': personName,
      'description': description,
      'location': location,
    };
    if (userName != null) body['user_name'] = userName;
    if (userPhone != null) body['user_phone'] = userPhone;
    if (age != null) body['age'] = age;
    if (latitude != null) body['latitude'] = latitude.toStringAsFixed(6);
    if (longitude != null) body['longitude'] = longitude.toStringAsFixed(6);
    if (photoUrl != null) body['photo_url'] = photoUrl;

    final response = await _client.post(
      _uri('/api/lost-found/'),
      headers: headers,
      body: jsonEncode(body),
    );

    final data = _decodeJson(response);
    _throwIfNotOk(response, data);
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getLostFoundReport(int id) async {
    final response = await _client.get(_uri('/api/lost-found/$id/'));
    final data = _decodeJson(response);
    _throwIfNotOk(response, data);
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateLostFoundReport(
    int id, {
    String? status,
    String? accessToken,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    final body = <String, dynamic>{};
    if (status != null) body['status'] = status;

    final response = await _client.patch(
      _uri('/api/lost-found/$id/'),
      headers: headers,
      body: jsonEncode(body),
    );

    final data = _decodeJson(response);
    _throwIfNotOk(response, data);
    return data as Map<String, dynamic>;
  }

  dynamic _decodeJson(http.Response response) {
    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }

  void _throwIfNotOk(http.Response response, dynamic data) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    final message = data is Map && data['detail'] != null
        ? data['detail'].toString()
        : 'Request failed with status ${response.statusCode}';
    throw Exception(message);
  }
}


