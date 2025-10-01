import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:food_ninja/src/bloc/login/login_bloc.dart';
import 'package:food_ninja/src/presentation/Canteen/auth/login_canteen_sceen.dart';

import 'package:food_ninja/src/presentation/screens/auth/register_screen.dart';

import 'package:food_ninja/src/presentation/widgets/buttons/roleButton.dart';
import 'package:food_ninja/src/presentation/widgets/loading_indicator.dart';
import 'package:food_ninja/src/presentation/utils/app_colors.dart';

import 'package:food_ninja/src/presentation/utils/custom_text_style.dart';

class OnboardingLoginScreen extends StatefulWidget {
  const OnboardingLoginScreen({super.key});

  @override
  State<OnboardingLoginScreen> createState() => _OnboardingLoginScreenState();
}

class _OnboardingLoginScreenState extends State<OnboardingLoginScreen> {
  bool hidePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            Navigator.pop(context);
            Navigator.pushNamedAndRemoveUntil(
              context,
              "/home",
              (route) => false,
            );
          }

          if (state is LoginError) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.errorColor,
                content: Text(state.error),
              ),
            );
          }

          if (state is LoginLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return const LoadingIndicator();
              },
            );
          }
        },
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Colors.transparent],
                ).createShader(bounds),
                blendMode: BlendMode.dstIn,
                child: SvgPicture.asset(
                  "assets/svg/pattern-big.svg",
                ),
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).padding.top + 30,
                          ),
                          Image.asset(
                            "assets/png/logo.png",
                            width: 200,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Welcome to Hostel Bites',
                            style: CustomTextStyle.size25Weight600Text()
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'How would you like to use the app?',
                            style: CustomTextStyle.size16Weight500Text(),
                          ),
                          const SizedBox(height: 30),
                          RoleButton(
                              icon: Icons.person,
                              label: "Continue as User",
                              description:
                                  "Order food and get it delivered to your hostel",
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            RegisterScreen()));
                              }),
                          SizedBox(
                            height: 13,
                          ),
                          RoleButton(
                              icon: Icons.run_circle,
                              label: "Continue as Delivery Partner",
                              description:
                                  "Deliver food and earn coins you can redeem at the canteen",
                              onTap: () {}),
                          SizedBox(
                            height: 13,
                          ),
                          RoleButton(
                              icon: Icons.restaurant,
                              label: "Continue as Canteen Staff",
                              description:
                                  "Manage orders and menu items from the kitchen",
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            CanteenLoginScreen()));
                              })
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget customButtom(
      {required VoidCallback ontap,
      required String title,
      required String subtitle}) {
    return InkWell(
      onTap: ontap,
      child: Card(
        elevation: 10,
        child: Container(
          padding: EdgeInsets.only(top: 15, bottom: 15, right: 5, left: 5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                  colors: [
                    Color.fromARGB(255, 247, 18, 37),
                    const Color.fromARGB(255, 215, 76, 88),
                  ]),
              border: Border.all(color: Colors.redAccent.withOpacity(0.5))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: CustomTextStyle.size18Weight600Text().copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    subtitle,
                    style: CustomTextStyle.size14Weight400Text()
                        .copyWith(fontSize: 12, color: Colors.white),
                  )
                ],
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
              )
            ],
          ),
        ),
      ),
    );
  }
}
