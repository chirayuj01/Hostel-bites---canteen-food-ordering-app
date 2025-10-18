import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:food_ninja/src/presentation/widgets/items/food_item.dart';

import '../../../bloc/food/food_bloc.dart';
import '../../../data/models/food.dart';
import '../../utils/app_colors.dart';
import '../../utils/custom_text_style.dart';
import '../../widgets/buttons/back_button.dart';
import '../../widgets/search_filter_widget.dart';
import 'add_menu_item_screen.dart';

class CanteenMenu extends StatefulWidget {
  const CanteenMenu({super.key});

  @override
  State<CanteenMenu> createState() => _CanteenMenuState();
}

class _CanteenMenuState extends State<CanteenMenu> {
  final ScrollController _scrollController = ScrollController();
  DocumentSnapshot? _lastDocument;

  final List<Food> _foods = [];
  List<Food> _filteredFoods = [];

  final TextEditingController _searchController = TextEditingController();
  final int _foodLimit = 10;

  @override
  void initState() {
    BlocProvider.of<FoodBloc>(context).add(
      LoadFoods(
        limit: _foodLimit,
        lastDocument: null,
      ),
    );
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        BlocProvider.of<FoodBloc>(context).add(
          FetchMoreFoods(
            limit: _foodLimit,
            lastDocument: _lastDocument,
          ),
        );
      }
    });

    super.initState();
  }

  void _refreshMenu() {
    // Clear existing data and reload
    _foods.clear();
    _filteredFoods.clear();
    _lastDocument = null;
    BlocProvider.of<FoodBloc>(context).add(
      LoadFoods(
        limit: _foodLimit,
        lastDocument: null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FoodBloc, FoodState>(
      listener: (context, state) {
        if (state is FoodError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        }
        if (state is FoodMoreFetched) {
          _lastDocument = state.lastDocument;
          for (var food in state.foods) {
            if (!_foods.contains(food)) {
              _foods.add(food);
            }
          }
          _filteredFoods = _foods;
        }
        if (state is FoodFetched) {
          _lastDocument = state.lastDocument;
          for (var food in state.foods) {
            if (!_foods.contains(food)) {
              _foods.add(food);
            }
          }
          _filteredFoods = _foods;
        }
      },
      child: GestureDetector(
        onTap: () {
          // close keyboard
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          body: Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: SvgPicture.asset(
                  "assets/svg/pattern-small.svg",
                ),
              ),
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CustomBackButton(),
                            const SizedBox(height: 20),
                            Text(
                              "Menu",
                              style: CustomTextStyle.size25Weight600Text(),
                            ),
                            const SizedBox(height: 20),
                            SearchFilterWidget(
                              searchController: _searchController,
                              onChanged: (value) {
                                _filteredFoods = _foods
                                    .where((restaurant) => restaurant.name
                                        .toLowerCase()
                                        .contains(value.toLowerCase()))
                                    .toList();

                                BlocProvider.of<FoodBloc>(context).add(
                                  QueryFoods(),
                                );
                              },
                              onTap: () {},
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                        BlocBuilder<FoodBloc, FoodState>(
                          builder: (context, state) {
                            return ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: _filteredFoods.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: FoodItem(food: _filteredFoods[index]),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddMenuItemScreen(),
                ),
              );

              // Refresh menu if item was added successfully
              if (result == true) {
                _refreshMenu();
              }
            },
            backgroundColor: AppColors.primaryColor,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Add Item',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
