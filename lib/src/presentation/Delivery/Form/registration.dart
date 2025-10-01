import 'package:flutter/material.dart';
import 'package:food_ninja/src/presentation/utils/custom_text_style.dart';

class RegistrationForDelivery extends StatefulWidget {
  const RegistrationForDelivery({super.key});

  @override
  State<RegistrationForDelivery> createState() =>
      _RegistrationForDeliveryState();
}

class _RegistrationForDeliveryState extends State<RegistrationForDelivery> {
  final _formKey = GlobalKey<FormState>();

  String? fullName;
  String? rollNumber;
  String? hostel;
  String? roomNumber;
  String? phoneNumber;
  bool availableAtNight = false;
  List<String> timeSlots = [];
  List<String> selectedZones = [];
  bool agreedToTerms = false;
  String? emergencyContact;

  List<String> hostels = ['', 'Hostel B', 'Hostel C'];
  List<String> zones = ['Zone 1', 'Zone 2', 'Zone 3'];
  List<String> availableSlots = [
    'Morning (8am–12pm)',
    'Afternoon (12pm–5pm)',
    'Evening (5pm–10pm)',
    'Night (10pm–1am)',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Text(
                  'Earn & Deliver – Registration',
                  style: CustomTextStyle.size22Weight600Text(),
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField('Full Name', (value) => fullName = value),
              _buildTextField('Roll Number', (value) => rollNumber = value),
              _buildDropdown('Hostel', hostels, (value) => hostel = value),
              _buildTextField('Room Number', (value) => roomNumber = value),
              _buildTextField('Phone Number', (value) => phoneNumber = value,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Available for Late-Night Delivery?'),
                  Switch(
                    value: availableAtNight,
                    onChanged: (val) => setState(() => availableAtNight = val),
                  ),
                ],
              ),

              // const SizedBox(height: 16),
              // Text('Usual Availability Time Slots:'),
              // ...availableSlots.map((slot) => CheckboxListTile(
              //       title: Text(slot),
              //       value: timeSlots.contains(slot),
              //       onChanged: (val) {
              //         setState(() {
              //           if (val == true) {
              //             timeSlots.add(slot);
              //           } else {
              //             timeSlots.remove(slot);
              //           }
              //         });
              //       },
              //     )),
              // const SizedBox(height: 16),
              // Text('Preferred Hostel Zones for Delivery:'),
              // ...zones.map((zone) => CheckboxListTile(
              //       title: Text(zone),
              //       value: selectedZones.contains(zone),
              //       onChanged: (val) {
              //         setState(() {
              //           if (val == true) {
              //             selectedZones.add(zone);
              //           } else {
              //             selectedZones.remove(zone);
              //           }
              //         });
              //       },
              //     )),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text(
                    'I agree to deliver orders within 30 minutes and follow canteen delivery policies.'),
                value: agreedToTerms,
                onChanged: (val) =>
                    setState(() => agreedToTerms = val ?? false),
              ),
              _buildTextField('Emergency Contact (optional)',
                  (value) => emergencyContact = value),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate() && agreedToTerms) {
                    _formKey.currentState!.save();
                    // Submit data or navigate to dashboard
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Registration Successful!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Please complete the form and agree to terms.')),
                    );
                  }
                },
                child: const Text('Submit & Start Earning'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, Function(String?) onSaved,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        validator: (value) =>
            (value == null || value.isEmpty) ? 'Please enter $label' : null,
        onSaved: onSaved,
      ),
    );
  }

  Widget _buildDropdown(
      String label, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
        validator: (value) =>
            (value == null || value.isEmpty) ? 'Please select $label' : null,
      ),
    );
  }
}
