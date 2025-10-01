import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lottie/lottie.dart';
import '../../../bloc/order/order_bloc.dart';
import '../../../data/models/order_status.dart';
import '../../utils/custom_text_style.dart';

import 'package:food_ninja/src/data/models/order.dart' as model;

class OrderTrackingScreen extends StatefulWidget {
  final model.Order order;
  const OrderTrackingScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

String? orderId;
Future<String> getFirstOrderId() async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('orders')
      .orderBy(
        'createdAt',
        descending: true
      ) // Sort by createdAt field
      .limit(1) // Get the first document
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    final firstDoc = querySnapshot.docs.first;
    final docId = firstDoc.id;
    orderId = docId;

    return docId;
  } else {
    return '';
  }
}
class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  int _secondsLeft = 60;
  bool _navigated = false;
  Timer? _timer; // Make it nullable

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) return; // Don't proceed if widget is not mounted

      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        _timer?.cancel();

        if (orderId != null) {
          final docSnapshot = await FirebaseFirestore.instance
              .collection('orders')
              .doc(orderId)
              .get();

          final data = docSnapshot.data();
          final currentStatus = data?['status'] ?? -1;

          if (currentStatus != OrderStatus.canceled.index) {
            await cancelOrder(orderId!);
          }
        }
      }
    });
  }

  Future<void> cancelOrder(String orderId) async {
    print('Order ID: $orderId');

    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({'status': OrderStatus.canceled.index});
  }

  @override
  void initState() {
    super.initState();
    getFirstOrderId();
    BlocProvider.of<OrderBloc>(context).add(
      FetchOrders(),
    );
    _startCountdown();
  }
@override
  void dispose() {
    _timer?.cancel(); // Cancel the timer to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: ListView(
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .doc(orderId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text("Error fetching order."));
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;
              final statusIndex = data['status'] ?? -1;

              if (statusIndex < 0 || statusIndex >= OrderStatus.values.length) {
                return const Center(child: Text("Invalid order status."));
              }

              final currentStatus = OrderStatus.values[statusIndex];

              // UI based on status
              if (currentStatus == OrderStatus.pending) {
                return Column(
                  children: [
                    const SizedBox(height: 20),
                    Lottie.asset('assets/lottie/pending.json', height: 300),
                    const Text(
                      'We’re confirming your order with the restaurant...',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Please wait while we finalize your delicious meal.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 200),
                    Text(
                      'Estimated confirmation in: $_secondsLeft seconds',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => cancelOrder(orderId!),
                      child: const Text(
                        "Cancel Order",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                );
              } else if (currentStatus == OrderStatus.canceled) {
                return Center(
                  child: Center(
                    child: Text(
                      "Order Canceled",
                      style: CustomTextStyle.size16Weight400Text(),
                    ),
                  ),
                );
              } else if (currentStatus == OrderStatus.preparing) {
                // Navigate only once
                if (!_navigated) {
                  _navigated = true;

                  // Delay to let UI finish building before navigating
                  Future.microtask(() {
                    Navigator.pushReplacementNamed(
                      context,
                      '/order/review', // <-- change to your actual route
                      arguments: widget.order,
                    );
                  });
                }

                return const Center(
                  child:
                      CircularProgressIndicator(), // Optional: some transition UI
                );
              } else {
                return Center(
                  child: Text(
                    "Order Status: ${currentStatus.name}",
                    style: TextStyle(
                      color: currentStatus.color,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      )),
    );
  }
}
// enum OrderStatus {
//   pending,
//   confirmed,
//   delivered,
//   canceled;

//   Color get color {
//     switch (this) {
//       case OrderStatus.pending:
//         return Colors.orange;
//       case OrderStatus.confirmed:
//         return Colors.green;
//       case OrderStatus.delivered:
//         return Colors.blue;
//       case OrderStatus.canceled:
//         return Colors.red;
//     }
//   }
// }




//  ListView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: state.orders.length,
//                   itemBuilder: (context, index) {
//                     return Column(
//                       children: [
//                         OrderItem(
//                           order: state.orders[index],
//                         ),
//                         const SizedBox(height: 20),
//                       ],
//                     );
//                   },
//                 );