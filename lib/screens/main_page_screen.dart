import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


import 'settings_screen.dart';
import 'plants_album_screen.dart';
import 'plant_interaction_screen.dart';
import 'timer_wrapper_screen.dart';

class MainPageScreen extends StatefulWidget {
  const MainPageScreen({super.key});

  @override
  State<MainPageScreen> createState() => _MainPageScreenState();
}

class _MainPageScreenState extends State<MainPageScreen> with TickerProviderStateMixin {
  late AnimationController _cloudController;
  late Animation<Alignment> _cloudAnimation;
  late AnimationController _blinkController; 

  // PATHS ASSETS
  final String _plantImagePath = 'assets/images/plant_level6.svg';
  final String _albumImagePath = 'assets/images/plants_calendar_album.svg';
  final String _potImagePath = 'assets/images/happy_pot.svg';
  final String _wateringCanPath = 'assets/images/watering_can_default.svg';
  final String _grassImagePath = 'assets/images/grass.svg';

  @override
  void initState() {
    super.initState();

    //  Animation για τα σύννεφα στο background
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat(reverse: true);

    _cloudAnimation = Tween<Alignment>(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(CurvedAnimation(parent: _cloudController, curve: Curves.linear));

    //  Animation για το αναβόσβημα (Begging state)
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Ρυθμίζουμε την ταχύτητα 
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cloudController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  //  Interaction Methods
  void _onPotTapped(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (c) => const PlantInteractionScreen()));
  }

  void _onWateringCanTapped(BuildContext context) {
    // Το πάτημα στο ποτιστήρι ανοίγει το Timer Setup
    Navigator.push(context, MaterialPageRoute(builder: (c) => const TimerWrapperScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      // Συνδυάζουμε τα animations για να ανανεώνεται το UI
      animation: Listenable.merge([_cloudAnimation, _blinkController]),
      builder: (context, child) {
        return Scaffold(
          body: Container(
            // Background με κινούμενα σύννεφα
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.lightBlue.shade200, Colors.lightBlue.shade50],
                stops: [0.0, _cloudAnimation.value.y.clamp(0.0, 1.0)],
              ),
            ),
            child: Stack(
              children: [
                //  HEADER (Settings & Album Icons)
                Positioned(
                  top: 50,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.settings, size: 40, color: Colors.black),
                        onPressed: () {
                           Navigator.push(context, MaterialPageRoute(builder: (c) => const SettingsScreen()));
                        },
                      ),
                      GestureDetector(
                        onTap: () {
                           Navigator.push(context, MaterialPageRoute(builder: (c) => const PlantsAlbumScreen()));
                        },
                        child: SvgPicture.asset(
                          _albumImagePath,
                          height: 50,
                          width: 50,
                          errorBuilder: (c, e, s) => const Icon(Icons.book, size: 40, color: Colors.brown),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. ΓΡΑΣΙΔΙ 
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  // Χρησιμοποιούμε fitWidth για να μην παραμορφώνεται και να πιάνει όλο το πλάτος
                  child: SvgPicture.asset(
                    _grassImagePath,
                    fit: BoxFit.fitWidth, 
                  ),
                ),

                // 3. ΦΥΤΟ 
                Positioned(
                  bottom: 145, // Τοποθέτηση ώστε να "μπαίνει" στη γλάστρα
                  left: MediaQuery.of(context).size.width * 0.1, // Κεντράρισμα σχετικά με τη γλάστρα
                  child: SvgPicture.asset(
                    _plantImagePath,
                    height: 380, // Ρύθμιση ύψους
                  ),
                ),

                // 4. ΓΛΑΣΤΡΑ
                Positioned(
                  bottom: 40, // Πάνω στο γρασίδι
                  left: MediaQuery.of(context).size.width * 0.1 + 25, // Ευθυγράμμιση με το φυτό
                  child: GestureDetector(
                    onTap: () => _onPotTapped(context),
                    child: SvgPicture.asset(
                      _potImagePath,
                      height: 130, // Μεγαλύτερη γλάστρα
                    ),
                  ),
                ),


                // Ποτιστήρι 
                Positioned(
                  bottom: 50,
                  right: 30,
                  child: FadeTransition(
                    opacity: _blinkController,
                    child: GestureDetector(
                      onTap: () => _onWateringCanTapped(context),
                      child: SvgPicture.asset(
                        _wateringCanPath,
                        height: 110,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}