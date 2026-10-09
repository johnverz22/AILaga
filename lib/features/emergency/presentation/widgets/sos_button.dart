import 'package:flutter/material.dart';
class SosButton extends StatelessWidget {
  const SosButton({super.key});
  @override
  Widget build(BuildContext context) => ElevatedButton(
    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
    onPressed: () {},
    child: const Text('SOS', style: TextStyle(color: Colors.white)),
  );
}
