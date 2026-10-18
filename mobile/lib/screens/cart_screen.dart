import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:spos_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spos_app/utils/cart_manager.dart';
import 'package:spos_app/screens/product_screen.dart';
import 'dart:convert';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> _cartItems = [];
  double _totalPrice = 0.0;
  String _nit = ''; // Variable para almacenar el NIT
  bool _isLoading = false; // Para mostrar un indicador de carga

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  // Cargar carrito desde CartManager
  Future<void> _loadCart() async {
    List<Map<String, dynamic>> cartItems = CartManager.getCartItems();
    double totalPrice = CartManager.getTotal();
    setState(() {
      _cartItems = cartItems;
      _totalPrice = totalPrice;
    });
  }

  // Realizar la venta
  Future<void> _completeSale() async {
    if (_nit.isEmpty) {
      Fluttertoast.showToast(msg: 'Por favor ingrese el NIT');
      return;
    }

    // Obtener el ID del usuario autenticado desde SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user = prefs.getString('user_data') ?? '';
    String userId = user.isNotEmpty
        ? json.decode(user)['id'].toString()
        : '';


    if (userId.isEmpty) {
      Fluttertoast.showToast(msg: 'No se encontró el ID del usuario');
      return;
    }

    // Construir el cuerpo de la solicitud
    List<Map<String, dynamic>> details =
        _cartItems.map((item) {
          // Asegurarnos de que 'price' y 'quantity' sean números decimales (double)
          double price = double.tryParse(item['price'].toString()) ?? 0.0;
          double quantity = double.tryParse(item['quantity'].toString()) ?? 0.0;

          return {
            'quantity': quantity,
            'price': price,
            'product': item['product'],
          };
        }).toList();

    var requestBody = {
      'details': details,
      'nit': _nit,
      'customer': userId, // Usar el ID del usuario autenticado
    };

    setState(() {
      _isLoading = true;
    });

    // Llamar al API para crear la venta
    var response = await ApiService().createSale(requestBody);

    setState(() {
      _isLoading = false;
    });

    // Verificar la respuesta
    if (response['statusCode'] == 201) {
      // Venta exitosa, mostrar dialogo de éxito
      _showSuccessDialog();
    } else {
      Fluttertoast.showToast(msg: 'Error: ${response['message']}');
    }
  }

  // Mostrar el dialogo de éxito
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Venta Exitosa'),
          content: Text('¡Tu pedido ha sido realizado con éxito!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Limpiar el carrito después de completar la venta
                CartManager.clearCart();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductScreen(),
                  ), // Cambia 'ProductScreen()' por la pantalla que necesites
                );
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carrito de Compras'),
        backgroundColor: Colors.black,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Mostrar los productos en un ListView
                    Expanded(
                      child: ListView.builder(
                        itemCount: _cartItems.length,
                        itemBuilder: (context, index) {
                          var item = _cartItems[index];

                          // Asegurarnos de que 'price' sea un número decimal (double)
                          double price =
                              double.tryParse(item['price'].toString()) ?? 0.0;
                          double quantity =
                              double.tryParse(item['quantity'].toString()) ??
                              0.0;
                          double subtotal = price * quantity;

                          return Column(
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                title: Text(item['name']),
                                subtitle: Text('Cantidad: ${item['quantity']}'),
                                trailing: Text(
                                  '\$${subtotal.toStringAsFixed(2)}',
                                ),
                                leading: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    CartManager.cartItems.removeAt(index);
                                    CartManager.totalPrice = CartManager
                                        .cartItems
                                        .fold(0.0, (sum, item) {
                                          return sum +
                                              (item['price'] *
                                                  item['quantity']);
                                        });
                                    Fluttertoast.showToast(
                                      msg: 'Producto eliminado',
                                    );
                                    setState(() {});
                                  },
                                ),
                              ),
                              Divider(color: Colors.grey[300], thickness: 1),
                            ],
                          );
                        },
                      ),
                    ),

                    // Mostrar el total
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Total: \$${_totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Campo para ingresar el NIT
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _nit = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'NIT',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),

                    // Botón para realizar el pedido
                    ElevatedButton(
                      onPressed: _completeSale,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Realizar Pedido',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
