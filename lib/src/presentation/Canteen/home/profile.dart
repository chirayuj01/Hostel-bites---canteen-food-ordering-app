import 'package:flutter/material.dart';

class CanteenProfile extends StatefulWidget {
  const CanteenProfile({super.key});

  @override
  State<CanteenProfile> createState() => _CanteenProfileState();
}

class _CanteenProfileState extends State<CanteenProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("Profile"),
    );
  }
}