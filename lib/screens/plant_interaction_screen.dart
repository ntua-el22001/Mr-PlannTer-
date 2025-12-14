import 'package:flutter/material.dart';

class PlantInteractionScreen extends StatelessWidget {
  const PlantInteractionScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54, 
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Plant Status:', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 20),
              // Εδώ θα εμφανίζονται τα status του φυτού 
              const Text('Current Growth Stage: 3/6'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}