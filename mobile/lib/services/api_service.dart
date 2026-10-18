import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = 'https://spos-backend.onrender.com/api';

  Future<Map<String, dynamic>> registerUser(Map<String, String> userData) async {
    var response = await http.post(
      Uri.parse('$baseUrl/auth/register-customer/'),
      body: jsonEncode(userData),
      headers: {'Content-Type': 'application/json'},
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> loginUser(Map<String, String> loginData) async {
    var response = await http.post(
      Uri.parse('$baseUrl/auth/login-customer/'),
      body: jsonEncode(loginData),
      headers: {'Content-Type': 'application/json'},
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> fetchProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token'); // Recuperamos el token

    if (token == null) {
      throw Exception('No se encontró el token de autenticación');
    }

    // Configuramos los encabezados con el token de autorización
    var headers = {
      'Authorization': 'Bearer $token', // Agregamos el token al encabezado
      'Content-Type': 'application/json',
    };

    // Realizamos la solicitud GET con el token en los encabezados
    var response = await http.get(
      Uri.parse('$baseUrl/products/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Devuelve los productos si la respuesta es exitosa
    } else {
      throw Exception('Error al cargar los productos');
    }
  }
  Future<Map<String, dynamic>> createSale(Map<String, dynamic> saleData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    if (token == null) {
      throw Exception('Token no encontrado');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/sales/'),
      body: json.encode(saleData),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer $token',
      },
    );

    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> fetchRecommendedProducts(String productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token'); // Recuperamos el token

    if (token == null) {
      throw Exception('No se encontró el token de autenticación');
    }

    var headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    // Llamada al endpoint para obtener los productos recomendados
    var response = await http.get(
      Uri.parse('$baseUrl/products/$productId/recommendations/'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Devuelve los productos recomendados
    } else {
      throw Exception('Error al obtener productos recomendados');
    }
  }
}

class AuthService {
  final String baseUrl = 'https://spos-backend.onrender.com/api';

  Future<void> saveToken(String token, Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('access_token', token);
    prefs.setString('user_data', json.encode(userData));
  }

  Future<Map<String, dynamic>?> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user_data');
    if (userData != null) {
      return json.decode(userData);
    }
    return null;
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> clearSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('access_token');
    prefs.remove('user_data');
  }

  Future<bool> checkToken() async {
    String? token = await getToken();
    if (token != null) {
      var response = await http.get(
        Uri.parse('$baseUrl/auth/check-token/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data['statusCode'] == 200;
      }
    }
    return false;
  }
}

