import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:food_ninja/src/data/services/firestore_db.dart';
import 'package:food_ninja/src/presentation/screens/set_location_map_screen.dart';
import 'package:food_ninja/src/presentation/widgets/buttons/back_button.dart';
import 'package:food_ninja/src/presentation/widgets/buttons/default_button.dart';
import 'package:food_ninja/src/presentation/widgets/buttons/primary_button.dart';
import 'package:food_ninja/src/data/models/user.dart';
import 'package:food_ninja/src/presentation/widgets/loading_indicator.dart';
import 'package:food_ninja/src/presentation/utils/app_colors.dart';
import 'package:food_ninja/src/presentation/utils/app_styles.dart';
import 'package:food_ninja/src/presentation/utils/custom_text_style.dart';
import 'package:hive/hive.dart';

class SetLocationScreen extends StatefulWidget {
  const SetLocationScreen({super.key});

  @override
  State<SetLocationScreen> createState() => _SetLocationScreenState();
}

class _SetLocationScreenState extends State<SetLocationScreen> {
  var box = Hive.box('myBox');
  String locationText = Hive.box('myBox').get('location') ?? "Your location";

  final TextEditingController _hostelController = TextEditingController();
  final TextEditingController _roomNoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: SvgPicture.asset(
              "assets/svg/pattern-small.svg",
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: PrimaryButton(
                text: "Next",
                onTap: () async {
                  if (_hostelController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AppColors.errorColor,
                        content: Text("Hostel name is required"),
                      ),
                    );
                    return;
                  }
                  if (_roomNoController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AppColors.errorColor,
                        content: Text("Room Number is required"),
                      ),
                    );
                    return;
                  }

                  if (box.get('location') == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please set your location"),
                        backgroundColor: AppColors.errorColor,
                      ),
                    );
                    return;
                  }
                  final String location = box.get('location');
                  final String placeName =
                      "${_hostelController.text.trim()}, ${_roomNoController.text.trim()}, IIIT Kota $location";
                  print(placeName);
                  Hive.box('myBox').put('location', placeName);

                  box.put('isRegistered', true);

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const LoadingIndicator(),
                  );

                  FirestoreDatabase db = FirestoreDatabase();
                  await db.addDocument(
                    'users',
                    User.fromHive().toMap(),
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/register/success');
                  }
                },
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).padding.top + 40,
                  ),
                  const CustomBackButton(),
                  const SizedBox(height: 20),
                  Text(
                    "Set Your Location",
                    style: CustomTextStyle.size25Weight600Text(),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "This data will be displayed in your account \nprofile for security",
                    style: CustomTextStyle.size14Weight400Text(),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.fromLTRB(
                      10,
                      30,
                      10,
                      30,
                    ),
                    decoration: BoxDecoration(
                        color: AppColors().cardColor,
                        boxShadow: [AppStyles.boxShadow7],
                        borderRadius: AppStyles.largeBorderRadius,
                        border: Border.all(
                            color: AppColors.kMain.withOpacity(0.2))),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              "assets/svg/map-pin.svg",
                              width: 33,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                locationText,
                                style: CustomTextStyle.size16Weight400Text(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 27),
                        SizedBox(
                          width: double.infinity,
                          child: DefaultButton(
                            text: "Set Location",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const SetLocationMapScreen(),
                                ),
                              ).then((value) {
                                setState(() {
                                  locationText = box.get('location');
                                });
                              });
                            },
                            backgroundColor: AppColors.grayLightColor,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Form(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 3),
                                child: Text(
                                  "Enter Hostel and Room No",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Container(
                                height: AppStyles.defaultTextFieldHeight,
                                decoration: BoxDecoration(
                                  boxShadow: [AppStyles.boxShadow7],
                                ),
                                child: TextFormField(
                                  controller: _hostelController,
                                  decoration: InputDecoration(
                                    fillColor: AppColors().cardColor,
                                    filled: true,
                                    hintText: "Boys Hostel / Girls Hostel",
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
                              const SizedBox(height: 10),
                              Container(
                                height: AppStyles.defaultTextFieldHeight,
                                decoration: BoxDecoration(
                                  boxShadow: [AppStyles.boxShadow7],
                                ),
                                child: TextFormField(
                                  controller: _roomNoController,
                                  decoration: InputDecoration(
                                    fillColor: AppColors().cardColor,
                                    filled: true,
                                    hintText: "A133",
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
                            ],
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
    );
  }
}
