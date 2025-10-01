// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:food_ninja/src/data/models/order.dart';
import 'package:food_ninja/src/bloc/order/order_bloc.dart';
import 'package:food_ninja/src/bloc/theme/theme_bloc.dart';
import 'package:food_ninja/src/data/repositories/order_repository.dart';
import 'package:food_ninja/src/presentation/Canteen/home/menu.dart';
import 'package:food_ninja/src/presentation/Canteen/home/report.dart';
import 'package:food_ninja/src/presentation/screens/home/profile_screen.dart';
import 'package:food_ninja/src/presentation/widgets/items/order_item.dart';
import 'package:food_ninja/src/presentation/widgets/search_filter_widget.dart';
import 'package:food_ninja/src/presentation/utils/app_colors.dart';
import 'package:food_ninja/src/presentation/utils/app_styles.dart';
import 'package:food_ninja/src/presentation/utils/custom_text_style.dart';
import 'package:intl/intl.dart';

import '../../../data/models/order_status.dart';
import '../../widgets/buttons/primary_button.dart';

class CanteenHomeScreen extends StatefulWidget {
  const CanteenHomeScreen({super.key});

  @override
  State<CanteenHomeScreen> createState() => _CanteenHomeScreenState();
}

class _CanteenHomeScreenState extends State<CanteenHomeScreen> {
  int _selectedIndex = 0;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    // BlocProvider.of<RestaurantBloc>(context).add(
    //   LoadRestaurants(
    //     limit: _restaurantLimit,
    //     lastDocument: null,
    //   ),
    // );

    // BlocProvider.of<FoodBloc>(context).add(
    //   LoadFoods(
    //     limit: _foodLimit,
    //     lastDocument: null,
    //   ),
    // );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<OrderBloc>(context).add(FetchCanteenOrders());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Hide keyboard when user taps outside an input field
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        bottomNavigationBar: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            return Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              decoration: BoxDecoration(
                color: AppColors().cardColor,
                borderRadius: AppStyles.largeBorderRadius,
                boxShadow: [AppStyles().largeBoxShadow],
              ),
              child: NavigationBar(
                backgroundColor: Colors.transparent,
                labelBehavior:
                    NavigationDestinationLabelBehavior.onlyShowSelected,
                onDestinationSelected: (int index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                selectedIndex: _selectedIndex,
                destinations: [
                  NavigationDestination(
                    icon: Opacity(
                      opacity: 0.5,
                      child: FaIcon(
                        FontAwesomeIcons.house,
                        color: AppColors.kMain,
                      ),
                    ),
                    selectedIcon: FaIcon(
                      FontAwesomeIcons.house,
                      color: AppColors.kMain,
                    ),
                    label: "Home",
                  ),
                  NavigationDestination(
                    icon: Opacity(
                      opacity: 0.5,
                      child: FaIcon(
                        FontAwesomeIcons.list,
                        color: AppColors.kMain,
                      ),
                    ),
                    selectedIcon: FaIcon(
                      FontAwesomeIcons.list,
                      color: AppColors.kMain,
                    ),
                    label: "Menu",
                  ),
                  NavigationDestination(
                    icon: BlocBuilder<OrderBloc, OrderState>(
                      builder: (context, state) {
                        return Badge(
                          backgroundColor: AppColors.errorColor,
                          isLabelVisible: OrderRepository.cart.isNotEmpty,
                          label: Text(
                            OrderRepository.cart.length.toString(),
                            style: CustomTextStyle.size14Weight400Text(
                              Colors.white,
                            ),
                          ),
                          offset: const Offset(10, -10),
                          child: Opacity(
                            opacity: 0.5,
                            child: FaIcon(
                              FontAwesomeIcons.chartLine,
                              color: AppColors.kMain,
                            ),
                          ),
                        );
                      },
                    ),
                    selectedIcon: BlocBuilder<OrderBloc, OrderState>(
                      builder: (context, state) {
                        return Badge(
                          backgroundColor: AppColors.errorColor,
                          isLabelVisible: OrderRepository.cart.isNotEmpty,
                          label: Text(
                            OrderRepository.cart.length.toString(),
                            style: CustomTextStyle.size14Weight400Text(
                              Colors.white,
                            ),
                          ),
                          offset: const Offset(10, -10),
                          child: FaIcon(
                            FontAwesomeIcons.chartLine,
                            color: AppColors.kMain,
                          ),
                        );
                      },
                    ),
                    label: "Report",
                  ),
                  NavigationDestination(
                    icon: Opacity(
                      opacity: 0.5,
                      child: FaIcon(
                        FontAwesomeIcons.user,
                        color: AppColors.kMain,
                      ),
                    ),
                    selectedIcon: FaIcon(
                      FontAwesomeIcons.user,
                      color: AppColors.kMain,
                    ),
                    label: "Profile",
                  ),
                ],
              ),
            );
          },
        ),
        body: _selectedIndex == 0
            ? _buildHomeBody(context)
            : _selectedIndex == 1
                ? const CanteenMenu()
                : _selectedIndex == 2
                    ? const CanteenReport()
                    : const ProfileScreen(),
      ),
    );
  }

  Widget _buildHomeBody(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: SvgPicture.asset(
            "assets/svg/pattern-small.svg",
          ),
        ),
        SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          "Canteen Dashboard",
                          style: CustomTextStyle.size30Weight600Text(),
                        ),
                      ),
                      Material(
                        color: AppColors().cardColor,
                        borderRadius: AppStyles.defaultBorderRadius,
                        child: InkWell(
                          borderRadius: AppStyles.defaultBorderRadius,
                          onTap: () {
                            Navigator.pushNamed(context, "/notification");
                          },
                          child: Container(
                            height: 45,
                            width: 45,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              boxShadow: [AppStyles().largeBoxShadow],
                            ),
                            child: FaIcon(
                              FontAwesomeIcons.bell,
                              color: AppColors.kMain,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  OrdersPage(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// class OrdersTab extends StatelessWidget {
//   const OrdersTab({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: 1,
//       shrinkWrap: true,
//       itemBuilder: (context, index) {
//         return Card(
//           child: Container(
//             child: ,
//           ),
//         );
//       },
//     );
//   }
// }
class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final TextEditingController searchController = TextEditingController();
  int _selectedIndex = 1; // Default to 1st tab (Order)

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Outlet Online',
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            SearchFilterWidget(
              searchController: searchController,
              onChanged: (value) {},
              text: 'Search by order id',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  buildTabButton('Order', index: 1),
                  const SizedBox(width: 8),
                  buildTabButton('Preparing', index: 2),
                  const SizedBox(width: 8),
                  buildTabButton('Picked up', index: 3),
                  const SizedBox(width: 8),
                  buildTabButton('Delivered', index: 4),
                  const SizedBox(width: 8),
                  buildTabButton('Completed', index: 5),
                  const SizedBox(width: 8),
                  buildTabButton('Cancelled', index: 6),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Conditionally render card based on _selectedIndex
            if (_selectedIndex == 1)
              const OrderCard()
            else if (_selectedIndex == 2)
              const PreparingOrderCard()
            else if (_selectedIndex == 3)
              const PickedOrderCard()
            else if (_selectedIndex == 4)
              const DeliveredOrderCard()
            else if (_selectedIndex == 5)
              const CompletedOrderCard()
            else if (_selectedIndex == 6)
              const CancelledOrderItem()
          ],
        ),
      ),
    );
  }

  Widget buildTabButton(String label, {required int index}) {
    final bool isActive = _selectedIndex == index;
    context.read<OrderBloc>().add(FetchCanteenOrders());
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isActive ? Colors.red : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  const OrderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderBloc, OrderState>(builder: (context, state) {
      if (state is OrdersFetching) {
        return Column(
          children: List.generate(
            3,
            (index) => const Column(
              children: [
                OrderItemShimmer(),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      } else if (state is OrdersFetched) {
        if (state.orders.isEmpty) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Text(
                "No orders yet",
                style: CustomTextStyle.size16Weight400Text(),
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: state.orders.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final order = state.orders[index];

            print(order.status); // debug print

            if (order.status == OrderStatus.pending) {
              print("Rendering pending order");
              return Column(
                children: [
                  CanteenOrderItem(order: order),
                  const SizedBox(height: 20),
                ],
              );
            }
            if (order.status != OrderStatus.pending) {
              return const SizedBox.shrink();
            }

            return Column(
              children: [
                CanteenOrderItem(
                  order: state.orders[index],
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        );
      } else if (state is OrderFetchingError) {
        return ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Center(
              child: Text(
                state.message,
                style: CustomTextStyle.size16Weight400Text(
                  AppColors.errorColor,
                ),
              ),
            ),
          ],
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}

class PreparingOrderCard extends StatelessWidget {
  const PreparingOrderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<OrderBloc>().add(FetchCanteenOrders());
      },
      child: BlocBuilder<OrderBloc, OrderState>(builder: (context, state) {
        if (state is OrdersFetching) {
          return Column(
            children: List.generate(
              3,
              (index) => const Column(
                children: [
                  OrderItemShimmer(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          );
        } else if (state is OrdersFetched) {
          if (state.orders.isEmpty) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(
                child: Text(
                  "No orders yet",
                  style: CustomTextStyle.size16Weight400Text(),
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: state.orders.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final order = state.orders[index];

              if (kDebugMode) {
                print(order.status);
              } // debug print
              if (order.status != OrderStatus.preparing) {
                return const SizedBox.shrink();
              }

              return Column(
                children: [
                  CanteenOrderItem(
                    order: state.orders[index],
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          );
        } else if (state is OrderFetchingError) {
          return ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Center(
                child: Text(
                  state.message,
                  style: CustomTextStyle.size16Weight400Text(
                    AppColors.errorColor,
                  ),
                ),
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      }),
    );
  }
}

class PickedOrderCard extends StatelessWidget {
  const PickedOrderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<OrderBloc>().add(FetchCanteenOrders());
      },
      child: BlocBuilder<OrderBloc, OrderState>(builder: (context, state) {
        if (state is OrdersFetching) {
          return Column(
            children: List.generate(
              3,
              (index) => const Column(
                children: [
                  OrderItemShimmer(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          );
        } else if (state is OrdersFetched) {
          if (state.orders.isEmpty) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(
                child: Text(
                  "No orders yet",
                  style: CustomTextStyle.size16Weight400Text(),
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: state.orders.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final order = state.orders[index];

              print(order.status); // debug print
              if (order.status != OrderStatus.ready) {
                return const SizedBox.shrink();
              }

              return Column(
                children: [
                  CanteenOrderItem(
                    order: state.orders[index],
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          );
        } else if (state is OrderFetchingError) {
          return ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Center(
                child: Text(
                  state.message,
                  style: CustomTextStyle.size16Weight400Text(
                    AppColors.errorColor,
                  ),
                ),
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      }),
    );
  }
}

class DeliveredOrderCard extends StatelessWidget {
  const DeliveredOrderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<OrderBloc>().add(FetchCanteenOrders());
      },
      child: BlocBuilder<OrderBloc, OrderState>(builder: (context, state) {
        if (state is OrdersFetching) {
          return Column(
            children: List.generate(
              3,
              (index) => const Column(
                children: [
                  OrderItemShimmer(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          );
        } else if (state is OrdersFetched) {
          if (state.orders.isEmpty) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(
                child: Text(
                  "No orders yet",
                  style: CustomTextStyle.size16Weight400Text(),
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: state.orders.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final order = state.orders[index];

              if (kDebugMode) {
                print(order.status);
              } // debug print
              if (order.status != OrderStatus.pickedUp) {
                return const SizedBox.shrink();
              }

              return Column(
                children: [
                  CanteenOrderItem(
                    order: state.orders[index],
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          );
        } else if (state is OrderFetchingError) {
          return ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Center(
                child: Text(
                  state.message,
                  style: CustomTextStyle.size16Weight400Text(
                    AppColors.errorColor,
                  ),
                ),
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      }),
    );
  }
}

class CompletedOrderCard extends StatelessWidget {
  const CompletedOrderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<OrderBloc>().add(FetchCanteenOrders());
      },
      child: BlocBuilder<OrderBloc, OrderState>(builder: (context, state) {
        if (state is OrdersFetching) {
          return Column(
            children: List.generate(
              3,
              (index) => const Column(
                children: [
                  OrderItemShimmer(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          );
        } else if (state is OrdersFetched) {
          if (state.orders.isEmpty) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(
                child: Text(
                  "No orders yet",
                  style: CustomTextStyle.size16Weight400Text(),
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: state.orders.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final order = state.orders[index];

              if (kDebugMode) {
                print(order.status);
              } // debug print
              if (order.status != OrderStatus.delivered) {
                return const SizedBox.shrink();
              }

              return Column(
                children: [
                  CanteenOrderItem(
                    order: state.orders[index],
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          );
        } else if (state is OrderFetchingError) {
          return ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Center(
                child: Text(
                  state.message,
                  style: CustomTextStyle.size16Weight400Text(
                    AppColors.errorColor,
                  ),
                ),
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      }),
    );
  }
}

class CancelledOrderItem extends StatelessWidget {
  const CancelledOrderItem({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<OrderBloc>().add(FetchCanteenOrders());
      },
      child: BlocBuilder<OrderBloc, OrderState>(builder: (context, state) {
        if (state is OrdersFetching) {
          return Column(
            children: List.generate(
              3,
              (index) => const Column(
                children: [
                  OrderItemShimmer(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          );
        } else if (state is OrdersFetched) {
          if (state.orders.isEmpty) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(
                child: Text(
                  "No orders yet",
                  style: CustomTextStyle.size16Weight400Text(),
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: state.orders.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final order = state.orders[index];

              if (kDebugMode) {
                print(order.status);
              } // debug print
              if (order.status != OrderStatus.canceled) {
                return const SizedBox.shrink();
              }

              return Column(
                children: [
                  CanteenOrderItem(
                    order: state.orders[index],
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          );
        } else if (state is OrderFetchingError) {
          return ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Center(
                child: Text(
                  state.message,
                  style: CustomTextStyle.size16Weight400Text(
                    AppColors.errorColor,
                  ),
                ),
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      }),
    );
  }
}

class CanteenOrderItem extends StatelessWidget {
  final Order order;
  const CanteenOrderItem({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // OrderStatus orderStatus = order.status;

    // if (order.status == OrderStatus.pending) {
    //   orderStatus = OrderStatus.pending;
    // }
    // else if (order.status == OrderStatus.preparing) {
    //   orderStatus = OrderStatus.preparing;
    // }
    // else if (order.status == OrderStatus.preparing) {
    //   orderStatus = OrderStatus.pending;
    // }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        elevation: 4,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Order #${order.id!.substring(0, 10)}...",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    DateFormat('hh:mm a').format(order.createdAt),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                order.userEmail,
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.cart.length,
                itemBuilder: (context, index) {
                  var item = order.cart[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${item.quantity} x ${item.name}'),
                        Text('₹${item.price * item.quantity}'),
                      ],
                    ),
                  );
                },
              ),

              // const Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text('1 x Butter Chicken'),
              //     Text('₹ 410'),
              //   ],
              // ),

              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total bill:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "₹${order.total.toString()}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildOrderActions(context, order),
              // Row(
              //   children: [
              //     // Flexible(
              //     //   child: InkWell(
              //     //     onTap: () {
              //     //       context.read<OrderBloc>().add(
              //     //             UpdateStatus(
              //     //                 orderId: order.id!,
              //     //                 newStatus: OrderStatus.preparing),
              //     //           );
              //     //     },
              //     //     child: Container(
              //     //       height: 40,
              //     //       padding: const EdgeInsets.symmetric(vertical: 10),
              //     //       decoration: BoxDecoration(
              //     //         color: Colors.blue,
              //     //         borderRadius: BorderRadius.circular(8),
              //     //       ),
              //     //       alignment: Alignment.center,
              //     //       child: const Text(
              //     //         'ACCEPT ORDER',
              //     //         style: TextStyle(
              //     //             color: Colors.white, fontWeight: FontWeight.bold),
              //     //       ),
              //     //     ),
              //     //   ),
              //     // ),
              //     // SizedBox(
              //     //   width: 10,
              //     // ),
              //     // Flexible(
              //     //   child: InkWell(
              //     //     onTap: () {
              //     //       context.read<OrderBloc>().add(
              //     //             UpdateStatus(
              //     //                 orderId: order.id!,
              //     //                 newStatus: OrderStatus.canceled),
              //     //           );
              //     //     },
              //     //     child: Container(
              //     //       height: 40,
              //     //       padding: const EdgeInsets.symmetric(vertical: 10),
              //     //       decoration: BoxDecoration(
              //     //         color: AppColors.kMain,
              //     //         borderRadius: BorderRadius.circular(8),
              //     //       ),
              //     //       alignment: Alignment.center,
              //     //       child: const Text(
              //     //         'REJECT ORDER',
              //     //         style: TextStyle(
              //     //             color: Colors.white, fontWeight: FontWeight.bold),
              //     //       ),
              //     //     ),
              //     //   ),
              //     // ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderActions(BuildContext context, Order order) {
    final status = order.status;

    if (status == OrderStatus.pending) {
      // Show Accept and Reject buttons
      return Row(
        children: [
          Flexible(
            child: InkWell(
              onTap: () {
                context.read<OrderBloc>().add(
                      UpdateStatus(
                          orderId: order.id!, newStatus: OrderStatus.preparing),
                    );
              },
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'ACCEPT ORDER',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: InkWell(
              onTap: () {
                context.read<OrderBloc>().add(
                      UpdateStatus(
                          orderId: order.id!, newStatus: OrderStatus.canceled),
                    );
              },
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.kMain,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'REJECT ORDER',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (status == OrderStatus.preparing) {
      return Row(
        children: [
          Flexible(
            child: InkWell(
              onTap: () {
                context.read<OrderBloc>().add(
                      UpdateStatus(
                          orderId: order.id!, newStatus: OrderStatus.ready),
                    );
              },
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Order is Ready',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (status == OrderStatus.ready) {
      return Row(
        children: [
          Flexible(
            child: InkWell(
              onTap: () {
                context.read<OrderBloc>().add(
                      UpdateStatus(
                          orderId: order.id!, newStatus: OrderStatus.pickedUp),
                    );
              },
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Order is Picked Up',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (status == OrderStatus.pickedUp) {
      return Row(
        children: [
          Flexible(
            child: InkWell(
              onTap: () {
                // context.read<OrderBloc>().add(
                //       UpdateStatus(
                //           orderId: order.id!, newStatus: OrderStatus.ready),
                //     );
              },
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Order on the Way...',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (status == OrderStatus.delivered) {
      return Row(
        children: [
          Flexible(
            child: InkWell(
              onTap: () {
                // context.read<OrderBloc>().add(
                //       UpdateStatus(
                //           orderId: order.id!, newStatus: OrderStatus.ready),
                //     );
              },
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Order Completed',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (status == OrderStatus.canceled) {
      return Row(
        children: [
          Flexible(
            child: InkWell(
              onTap: () {
                // context.read<OrderBloc>().add(
                //       UpdateStatus(
                //           orderId: order.id!, newStatus: OrderStatus.ready),
                //     );
              },
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Order Cancelled',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink(); // show nothing
    }
  }
}




// ListView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: state.orders.length,
//           itemBuilder: (context, index) {
//             return Column(
//               children: [
//                 OrderItem(
//                   order: state.orders[index],
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             );
//           },
//         );