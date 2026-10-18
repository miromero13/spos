import 'package:flutter/material.dart';
import 'package:spos_app/services/api_service.dart'; // Importar el servicio para obtener los datos del usuario

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _userName = ''; // Variable para guardar el nombre del usuario

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  // Función para recuperar los datos del usuario desde el almacenamiento local
  _getUserData() async {
    var userData = await AuthService().getUserData();
    if (userData != null) {
      setState(() {
        _userName = userData['name'] ?? 'Usuario';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ElectroPos'),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '¡Hola, $_userName!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Agrega más widgets aquí si es necesario
          ],
        ),
      ),
    );
  }
}
