import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:food_ninja/src/bloc/Canteen/login/canteen_login_bloc.dart';
import 'package:food_ninja/src/presentation/Canteen/home/home.dart';
import 'package:food_ninja/src/presentation/widgets/buttons/primary_button.dart';
import 'package:food_ninja/src/presentation/widgets/loading_indicator.dart';
import 'package:food_ninja/src/presentation/utils/app_colors.dart';
import 'package:food_ninja/src/presentation/utils/app_styles.dart';
import 'package:food_ninja/src/presentation/utils/custom_text_style.dart';

class CanteenLoginScreen extends StatefulWidget {
  const CanteenLoginScreen({super.key});

  @override
  State<CanteenLoginScreen> createState() => _CanteenLoginScreenState();
}

class _CanteenLoginScreenState extends State<CanteenLoginScreen> {
  bool hidePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<CanteenLoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            Navigator.pop(context);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => CanteenHomeScreen()),
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
                            height: MediaQuery.of(context).padding.top + 50,
                          ),
                          Image.asset(
                            "assets/png/logo.png",
                            width: 200,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Canteen Management Login',
                            style: CustomTextStyle.size22Weight600Text(),
                          ),
                          const SizedBox(height: 10),
                          Icon(
                            Icons.restaurant,
                            color: Colors.orange,
                            size: 50,
                          ),
                          const SizedBox(height: 20),
                          Form(
                            child: Column(
                              children: [
                                Container(
                                  height: AppStyles.defaultTextFieldHeight,
                                  decoration: BoxDecoration(
                                    boxShadow: [AppStyles.boxShadow7],
                                  ),
                                  child: TextFormField(
                                    controller: _emailController,
                                    decoration: InputDecoration(
                                      fillColor: AppColors().cardColor,
                                      filled: true,
                                      hintText: "Email",
                                      hintStyle:
                                          CustomTextStyle.size14Weight400Text(
                                        AppColors().secondaryTextColor,
                                      ),
                                      enabledBorder:
                                          AppStyles().defaultEnabledBorder,
                                      focusedBorder:
                                          AppStyles.defaultFocusedBorder(),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  height: AppStyles.defaultTextFieldHeight,
                                  decoration: BoxDecoration(
                                    boxShadow: [AppStyles.boxShadow7],
                                  ),
                                  child: TextFormField(
                                    controller: _passwordController,
                                    obscureText: hidePassword,
                                    decoration: InputDecoration(
                                      fillColor: AppColors().cardColor,
                                      filled: true,
                                      hintText: "Password",
                                      hintStyle:
                                          CustomTextStyle.size14Weight400Text(
                                        AppColors().secondaryTextColor,
                                      ),
                                      enabledBorder:
                                          AppStyles().defaultEnabledBorder,
                                      focusedBorder:
                                          AppStyles.defaultFocusedBorder(),
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            hidePassword = !hidePassword;
                                          });
                                        },
                                        child: Icon(
                                          hidePassword
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                "/login/forgot-password",
                              );
                            },
                            child: ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: AppColors.primaryGradient,
                              ).createShader(bounds),
                              blendMode: BlendMode.srcIn,
                              child: Text(
                                "Forgot Password?",
                                style: CustomTextStyle.size14Weight400Text()
                                    .copyWith(
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 60),
                            child: PrimaryButton(
                              text: "Login",
                              onTap: () {
                                if (_emailController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: AppColors.errorColor,
                                      content: Text("Email is required"),
                                    ),
                                  );
                                  return;
                                }
                                if (_passwordController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: AppColors.errorColor,
                                      content: Text("Password is required"),
                                    ),
                                  );
                                  return;
                                }
                                debugPrint(_emailController.text.trim());
                                debugPrint(_passwordController.text);
                                BlocProvider.of<CanteenLoginBloc>(context).add(
                                  LoginSubmitted(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text,
                                  ),
                                );
                              },
                            ),
                          ),
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
}
