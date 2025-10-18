import 'package:food_ninja/src/data/models/order.dart' as model;
import 'package:food_ninja/src/data/models/order_status.dart';
import 'package:food_ninja/src/data/models/payment_method.dart';
import 'package:food_ninja/src/data/services/firestore_db.dart';
import 'package:hive/hive.dart';

import '../models/food.dart';

class OrderRepository {
  final FirestoreDatabase _db = FirestoreDatabase();
  static final List<Food> cart = [];

  static final Box<dynamic> box = Hive.box('myBox');

  // load cart from hive
  static void loadCart() {
    if (box.containsKey('cart')) {
      final List<Food> cartList = List<Food>.from(box.get('cart'));
      cart.clear();
      for (Food item in cartList) {
        cart.add(item);
      }
    }
  }

  // update cart in hive
  void updateHive() {
    box.put('cart', cart);
  }

  void addToCart(Food food) {
    if (cart.contains(food)) {
      cart[cart.indexOf(food)].quantity++;
    } else {
      cart.add(food);
      food.quantity++;
    }
    updateHive();
  }

  void removeFromCart(Food food) {
    if (cart.contains(food)) {
      if (food.quantity > 1) {
        food.quantity--;
      }
    }
    updateHive();
  }

  void removeCompletelyFromCart(Food food) {
    if (cart.contains(food)) {
      cart.remove(food);
      food.quantity = 0;
    }
    updateHive();
  }

  // subtotal
  static double get subtotal {
    double total = 0;
    for (var food in cart) {
      total += food.price * food.quantity;
    }
    return total;
  }

  // delivery fee
  static double get deliveryFee {
    if (subtotal < 150 && subtotal != 0) {
      return subtotal * 0.10;
    } else if (subtotal >= 150 && subtotal < 400) {
      return subtotal * 0.10;
    } else if (subtotal == 0) {
      return 0;
    } else {
      return 0;
    }
  }

  // discount
  static double get discount {
    if (subtotal < 150) {
      return 0;
    } else if (subtotal >= 150 && subtotal < 200) {
      return 10;
    } else if (subtotal >= 200 && subtotal <= 300) {
      return subtotal * 0.20;
    } else {
      return subtotal * 0.10;
    }
  }

  // total
  static double get total {
    return subtotal + deliveryFee - discount;
  }

  Future<model.Order> createOrder() async {
    final String? email = box.get('email');
    // final String? name = box.get('name');
    if (email == null) {
      throw Exception("User email not set.");
    }
    
    if (cart.isEmpty) {
      throw Exception("Cart is empty.");
    }

    final model.Order order = model.Order(
      cart: [...cart],
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      discount: discount,
      total: total,
      createdAt: DateTime.now(),
      status: OrderStatus.pending,
      userEmail: email,
      paymentMethod: box.get('paymentMethod', defaultValue: 'visa') == 'visa'
          ? PaymentMethod.visa
          : PaymentMethod.paypal,
    );

    // firestore
    await _db.addDocument(
      'orders',
      order.toMap(),
    );

    cart.clear();
    updateHive();

    return order;
  }

  Future<List<model.Order>> fetchOrders() async {
    final List<model.Order> orders = [];
    var data = await _db.getDocumentsWithQuery(
      'orders',
      'userEmail',
      box.get('email'),
    );
    for (var item in data.docs) {
      model.Order order = model.Order.fromMap(
        item.data() as Map<String, dynamic>,
      );
      order.id = item.id;
      orders.add(order);
    }

    // sort by date
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return orders;
  }

  Future<List<model.Order>> fetchCanteenOrders() async {
    final List<model.Order> orders = [];

    // Fetch all documents from 'orders' collection
    var data = await _db.getCollection('orders');

    for (var item in data.docs) {
      model.Order order = model.Order.fromMap(
        item.data() as Map<String, dynamic>,
      );
      order.id = item.id;
      orders.add(order);
    }

    // Sort orders by creation time (latest first)
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return orders;
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
  try {
    await _db.updateDocument(
      'orders',
      orderId,
      {
        'status': newStatus.index,

      },
    );
  } catch (e) {
    throw Exception("Failed to update order status: $e");
  }
}




}
