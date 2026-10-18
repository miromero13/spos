import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:spos_app/services/api_service.dart';
import 'package:spos_app/screens/product_detail_screen.dart';
import 'package:spos_app/screens/cart_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ProductScreen extends StatefulWidget {
  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<dynamic> _products = []; // Lista para almacenar los productos
  bool _isLoading = false; // Variable para manejar el estado de carga
  stt.SpeechToText _speechToText = stt.SpeechToText(); // Instancia de SpeechToText
  bool _isListening = false; // Para saber si estamos escuchando
  String _detectedText = ''; // Para almacenar el texto detectado

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  // Función para obtener los productos desde el API
  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });

    var response = await ApiService().fetchProducts();
    if (response['statusCode'] == 200) {
      setState(() {
        _products = response['data'];
      });
    } else {
      Fluttertoast.showToast(msg: 'Error al cargar productos');
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Función para iniciar el reconocimiento de voz
  void _startListening() async {
    bool available = await _speechToText.initialize();
    if (available) {
      setState(() {
        _isListening = true;
      });
      _speechToText.listen(onResult: (result) {
        setState(() {
          _detectedText = result.recognizedWords;
        });
        _handleVoiceCommand(_detectedText);
      });
    }
  }

  // Función para detener la escucha
  void _stopListening() {
    _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  // Función para manejar el comando de voz
  void _handleVoiceCommand(String command) {
    if (command.isNotEmpty) {
      for (var product in _products) {
        if (product['name'].toLowerCase().contains(command.toLowerCase())) {
          _stopListening();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(product: product),
            ),
          );
          return; // Salimos de la función si encontramos el producto
        }
      }
      Fluttertoast.showToast(msg: 'Producto no encontrado');
    }
  }

  void _goToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CartScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Productos'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.mic, color: _isListening ? Colors.green : Colors.black),
            onPressed: _isListening ? _stopListening : _startListening,
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.black),
            onPressed: _goToCart,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Número de columnas
                crossAxisSpacing: 16, // Espacio entre columnas
                mainAxisSpacing: 16, // Espacio entre filas
                childAspectRatio: 3 / 4, // Relación de aspecto de las celdas
              ),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                var product = _products[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(
                          product: product,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          color: Colors.grey[300],
                          width: 100,
                          height: 100,
                          child: product['photo_url'] != null && product['photo_url'].isNotEmpty
                              ? Image.network(
                                  product['photo_url'],
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.broken_image,
                                      size: 50,
                                      color: Colors.black,
                                    );
                                  },
                                )
                              : Icon(
                                  Icons.image,
                                  size: 50,
                                  color: Colors.black,
                                ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          product['name'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text('\$${product['sale_price']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
