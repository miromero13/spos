import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:spos_app/services/api_service.dart';
import 'package:spos_app/screens/cart_screen.dart';
import 'package:spos_app/utils/cart_manager.dart';
import 'package:spos_app/screens/product_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  ProductDetailScreen({required this.product});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  List<dynamic> _products = []; // Lista para almacenar los productos
  bool _isLoading = false; // Variable para manejar el estado de carga
  stt.SpeechToText _speechToText = stt.SpeechToText(); // Instancia de SpeechToText
  bool _isListening = false; // Para saber si estamos escuchando
  String _detectedText = ''; 
  int _quantity = 0;
  List<dynamic> _suggestedProducts = [];

  @override
  void initState() {
    super.initState();
    _fetchSuggestedProducts();
  }

  // Función para agregar al carrito
  Future<void> _addToCart() async {
    Map<String, dynamic> productDetails = {
      'price': widget.product['sale_price'],
      'quantity': _quantity,
      'product': widget.product['id'],
      'name': widget.product['name'],
    };

    // Usar CartManager para agregar al carrito
    CartManager.addToCart(productDetails);

    // Mostrar el carrito actualizado
    await Fluttertoast.showToast(msg: 'Producto añadido al carrito');

    // Limpiar la cantidad después de añadir al carrito
    setState(() {
      _quantity = 0;
    });

    await Future.delayed(Duration(seconds: 1)); // Espera que pase 1 segundo
    
    // Navegar al producto
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductScreen()),
    );
  }

  // Función para obtener productos sugeridos
  Future<void> _fetchSuggestedProducts() async {
    setState(() {
      _isLoading = true;
    });

    var response =
        await ApiService()
            .fetchRecommendedProducts(widget.product['id']); // Usamos el mismo endpoint para obtener productos
    if (response['statusCode'] == 200) {
      setState(() {
        _suggestedProducts = response['data']; // Productos sugeridos
      });
    } else {
      Fluttertoast.showToast(msg: 'Error al cargar productos sugeridos');
    }

    setState(() {
      _isLoading = false;
    });
  }
  void _startListening() async {
    bool available = await _speechToText.initialize();
    if (available) {
      setState(() {
        _isListening = true;
      });
      _speechToText.listen(
        localeId: "es_ES",
        onResult: (result) {
          setState(() {
            _detectedText = result.recognizedWords;
          });
          _handleVoiceCommand(_detectedText);
        },
      );
    }
  }

  // Función para detener la escucha
  void _stopListening() {
    _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

    void _handleVoiceCommand(String command) {
    if (command.isNotEmpty) {
      command = command.toLowerCase(); // Convertir todo a minúsculas

      if (command.contains("retroceder") || command.contains("regresar")) {
        // Volver a la pantalla anterior
        Navigator.pop(context);
        _stopListening();
      } else if (command.contains("aumentar stock") ||
          command.contains("subir stock") ||
          command.contains("más stock")) {
        // Aumentar el stock
        setState(() {
          if (_quantity < widget.product['stock']) {
            _quantity++;
          }
        });
        _stopListening();
      } else if (command.contains("disminuir stock") ||
          command.contains("bajar stock") ||
          command.contains("menos stock")) {
        // Disminuir el stock
        setState(() {
          if (_quantity > 0) {
            _quantity--;
          }
        });
        _stopListening();
      } else if (command.contains("agregar al carrito") ||
          command.contains("añadir al carrito")) {
        _stopListening();
        _addToCart();
      } else if (command.contains("entrar al carrito") || 
          command.contains("carrito de compras") ||
          command.contains("carrito")) {
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: 
              (context) => CartScreen()
          )
        );
        _stopListening();
      } else {
        // Buscar el producto por nombre
        var matchedProduct = _suggestedProducts.firstWhere(
          (product) => product['name'].toLowerCase().contains(command),
          orElse: () => null,
        );

        if (matchedProduct != null) {
          // Ir a la pantalla de detalles del producto
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ProductDetailScreen(product: matchedProduct),
            ),
          );
          _stopListening();
        } else {
          Fluttertoast.showToast(msg: 'Producto no encontrado');
        }
      }
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
        title: Text(widget.product['name']),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              Icons.mic,
              color: _isListening ? Colors.green : Colors.black,
            ),
            onPressed: _isListening ? _stopListening : _startListening,
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.black),
            onPressed: _goToCart,
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      color: Colors.grey[300],
                      width: 100,
                      height: 100,
                      child: widget.product['photo_url'] != null && widget.product['photo_url'].isNotEmpty
                          ? Image.network(
                              widget.product['photo_url'],
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
                    SizedBox(height: 20),
                    // Nombre del producto
                    Text(
                      widget.product['name'],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    // Descripción del producto
                    Text(
                      widget.product['description'],
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    // Stock disponible
                    Text('Stock: ${widget.product['stock']}'),
                    SizedBox(height: 20),
                    // Ajuste de la cantidad
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            if (_quantity > 0) {
                              setState(() {
                                _quantity--;
                              });
                            }
                          },
                        ),
                        Text('$_quantity', style: TextStyle(fontSize: 20)),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            if (_quantity < widget.product['stock']) {
                              setState(() {
                                _quantity++;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    // Botón para agregar al carrito
                    ElevatedButton(
                      onPressed: _addToCart,
                      child: Text(
                        'Añadir al carrito',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Título de productos sugeridos
                    Text(
                      'Productos sugeridos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    // Lista de productos sugeridos
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 3 / 4,
                      ),
                      itemCount: _suggestedProducts.length,
                      itemBuilder: (context, index) {
                        var suggestedProduct = _suggestedProducts[index];
                        return InkWell(
                          onTap: () {
                            // Al hacer click en un producto sugerido, mostrar sus detalles
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ProductDetailScreen(
                                      product: suggestedProduct,
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
                          child: suggestedProduct['photo_url'] != null && suggestedProduct['photo_url'].isNotEmpty
                              ? Image.network(
                                  suggestedProduct['photo_url'],
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
                                  suggestedProduct['name'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),
                                Text('\$${suggestedProduct['sale_price']}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
    );
  }
}
