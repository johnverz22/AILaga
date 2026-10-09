import 'package:flutter/material.dart';

class MedicationDetailScreen extends StatelessWidget {
  final String medicationId;
  const MedicationDetailScreen({super.key, required this.medicationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MedicationDetailScreen')),
      body: Center(
        child: Text('TODO: Implement for \$medicationId'),
      ),
    );
  }
}
