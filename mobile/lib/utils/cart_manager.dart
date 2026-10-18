class CartManager {
  // El carrito estará en memoria
  static List<Map<String, dynamic>> cartItems = [];
  static double totalPrice = 0.0;

  // Añadir un producto al carrito
  static void addToCart(Map<String, dynamic> productDetails) {
    cartItems.add(productDetails);

    // Calcular el total
    totalPrice = cartItems.fold(0.0, (sum, item) {
      return sum + (item['price'] * item['quantity']);
    });
  }

  // Obtener el carrito
  static List<Map<String, dynamic>> getCartItems() {
    return cartItems;
  }

  // Obtener el total
  static double getTotal() {
    return totalPrice;
  }

  // Limpiar el carrito
  static void clearCart() {
    cartItems.clear();
    totalPrice = 0.0;
  }
}
