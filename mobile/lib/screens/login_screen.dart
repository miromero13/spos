import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:spos_app/services/api_service.dart';
import 'package:spos_app/screens/register_screen.dart';
import 'package:spos_app/screens/product_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false; // Variable para manejar el estado de carga
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _speechText = "Di algo..."; // Mensaje que muestra lo que se escucha

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Por favor ingresa todos los campos');
      return;
    }

    setState(() {
      _isLoading = true; // Activamos el estado de carga
    });

    var loginData = {
      'email': _emailController.text,
      'password': _passwordController.text,
    };

    var response = await ApiService().loginUser(loginData);
    setState(() {
      _isLoading = false; // Desactivamos el estado de carga
    });

    if (response['statusCode'] == 200) {
      String token = response['data']['access'];
      var userData = response['data']['user'];

      await AuthService().saveToken(token, userData);
      Fluttertoast.showToast(msg: 'Login exitoso');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProductScreen()),
      );
    } else {
      Fluttertoast.showToast(msg: 'Error: ${response['message']}');
    }
  }

  // Función para iniciar el reconocimiento de voz
  void _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
        _speechText = "Escuchando...";
      });
      _speech.listen(
        localeId: "es_ES", // Configurar idioma a español
        onResult: (result) {
          setState(() {
            _speechText = result.recognizedWords;
          });
          _processSpeechCommand(_speechText);
        },
      );
    } else {
      Fluttertoast.showToast(
        msg: "No se pudo iniciar el reconocimiento de voz",
      );
    }
  }

  void _processSpeechCommand(String command) {
    command = command.toLowerCase();

    if (command.contains("iniciar sesión")) {
      _login();
    } else if (command.contains("mi correo electrónico es")) {
      // Extraer el correo electrónico después de "es"
      final email = command.split("es").last.trim();
      if (_isValidEmail(email)) {
        setState(() {
          _emailController.text = email;
        });
      } else {
        Fluttertoast.showToast(msg: "Correo electrónico no válido");
      }
    } else if (command.contains("mi contraseña es")) {
      // Extraer la contraseña después de "es"
      final password = command.split("es").last.trim();
      setState(() {
        _passwordController.text = password;
      });
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  // Detener el reconocimiento de voz
  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Iniciar sesión'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Título ElectroPos
                Text(
                  'ElectroPos',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 40),
                // Input Correo Electrónico
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        10,
                      ), // Borde redondeado
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      ), // Borde negro al tener el foco
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Input Contraseña
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        10,
                      ), // Borde redondeado
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      ), // Borde negro al tener el foco
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Botón de iniciar sesión con animación de toque y color gris cuando está bloqueado
                InkWell(
                  onTap:
                      _isLoading
                          ? null
                          : _login, // Desactivar el botón si está cargando
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color:
                          _isLoading
                              ? Colors.grey
                              : Colors.black, // Gris cuando está bloqueado
                      borderRadius: BorderRadius.circular(
                        10,
                      ), // Borde redondeado
                    ),
                    child: Center(
                      child:
                          _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                'Iniciar sesión',
                                style: TextStyle(color: Colors.white),
                              ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Botón para ir al registro
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    );
                  },
                  child: Text(
                    '¿No tienes cuenta? Regístrate',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                SizedBox(height: 16),
                // Botón para activar el reconocimiento de voz
                ElevatedButton(
                  onPressed: _isListening ? _stopListening : _startListening,
                  child: Text(
                    _isListening ? 'Detener Escucha' : 'Iniciar Escucha',
                    style: TextStyle(color: Colors.white), // Estilo consistente con el botón de inicio de sesión
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isListening ? Colors.grey : Colors.black, // Gris cuando está bloqueado
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Text('Reconocimiento de voz: $_speechText'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
