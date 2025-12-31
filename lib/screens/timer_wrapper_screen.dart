import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:async';
import '../data/database_helper.dart'; // Για αποθήκευση στο τέλος

// Καταστάσεις του Timer
enum TimerPhase { setup, studying, breaking }

class TimerWrapperScreen extends StatefulWidget {
  const TimerWrapperScreen({super.key});

  @override
  State<TimerWrapperScreen> createState() => _TimerWrapperScreenState();
}

class _TimerWrapperScreenState extends State<TimerWrapperScreen> with TickerProviderStateMixin {
  final TextEditingController _studyMinController = TextEditingController(text: '25');
  final TextEditingController _breakMinController = TextEditingController(text: '05');
  final TextEditingController _sessionsController = TextEditingController(text: '4');

  // Timer State 
  TimerPhase _phase = TimerPhase.setup;
  Timer? _timer;
  bool _isRunning = false;
  
  int _secondsRemaining = 0;
  int _totalSessions = 4;
  int _currentSession = 1;
  int _studyTimeMinutes = 25;
  int _breakTimeMinutes = 5;

  // Gamification State 
  int _currentPlantState = 0; // 0 έως 6
  double _secondsPerGrowthStage = 0;

  // Animation 
  late AnimationController _cloudController;
  late Animation<Alignment> _cloudAnimation;

  // Assets Paths 
  final List<String> _plantStages = [
    'assets/images/plant_level0.svg',
    'assets/images/plant_level1.svg',
    'assets/images/plant_level2.svg',
    'assets/images/plant_level3.svg',
    'assets/images/plant_level4.svg',
    'assets/images/plant_level5.svg',
    'assets/images/plant_level6.svg',
  ];
  final String _potPath = 'assets/images/happy_pot.svg';
  final String _grassPath = 'assets/images/grass.svg';
  

  final String _wateringModePath = 'assets/images/watering_mode.svg'; // Ποτιστήρι που ποτίζει
  final String _fillingModePath = 'assets/images/watering_can_default.svg'; // Ποτιστήρι που γεμίζει (με βρύση)

  @override
  void initState() {
    super.initState();
    // Background Animation (ίδιο με Main Page)
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat(reverse: true);

    _cloudAnimation = Tween<Alignment>(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(CurvedAnimation(parent: _cloudController, curve: Curves.linear));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cloudController.dispose();
    _studyMinController.dispose();
    _breakMinController.dispose();
    _sessionsController.dispose();
    super.dispose();
  }

  // Logic 

  void _startTimerLogic() {
    // Διαβάζουμε τις τιμές από τα TextFields (Manual Input)
    setState(() {
      _studyTimeMinutes = int.tryParse(_studyMinController.text) ?? 25;
      _breakTimeMinutes = int.tryParse(_breakMinController.text) ?? 5;
      _totalSessions = int.tryParse(_sessionsController.text) ?? 4;
      
      // Αρχικοποίηση χρόνου
      _secondsRemaining = _studyTimeMinutes * 60;
      _phase = TimerPhase.studying;
      _currentSession = 1;
      _isRunning = true;
      _currentPlantState = 0; // Ξεκινάμε από σπόρο
      
      // Υπολογισμός ρυθμού ανάπτυξης 
      _secondsPerGrowthStage = (_studyTimeMinutes * 60) / 6;
    });

    _startTicker();
  }

  void _startTicker() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
          
          // Λογική ανάπτυξης φυτού (μόνο στο Studying phase)
          if (_phase == TimerPhase.studying) {
            double elapsed = (_studyTimeMinutes * 60) - _secondsRemaining.toDouble();
            int stage = (elapsed / _secondsPerGrowthStage).floor();
            _currentPlantState = stage.clamp(0, 6);
          }
        } else {
          _handlePhaseEnd();
        }
      });
    });
  }

  void _handlePhaseEnd() async {
    _timer?.cancel();
    
    // ΤΕΛΟΣ ΔΙΑΒΑΣΜΑΤΟΣ
    if (_phase == TimerPhase.studying) {
      
      // Αν υπάρχουν κι άλλα sessions 
      if (_currentSession < _totalSessions) {
        setState(() {
          _phase = TimerPhase.breaking; // ΑΛΛΑΓΗ ΦΑΣΗΣ ΣΕ ΔΙΑΛΕΙΜΜΑ
          _secondsRemaining = _breakTimeMinutes * 60; // ΧΡΟΝΟΣ ΔΙΑΛΕΙΜΜΑΤΟΣ
        });
        _startTicker(); // Αυτόματη έναρξη του διαλείμματος
      } 
      // Αν ήταν το τελευταίο session
      else {
        // Αποθήκευση στη βάση
        final db = DatabaseHelper();
        await db.updatePlantState(6, _totalSessions * _studyTimeMinutes);
        
        // Αποθήκευση στο Album
        await db.addCompletedPlant(
            'assets/images/plant_level6.svg', 
            'Sunflower #${DateTime.now().day}/${DateTime.now().month}'
        );

        if(mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Session Complete! Great job!")));
            Navigator.pop(context); // ΕΠΙΣΤΡΟΦΗ ΣΤΗΝ ΑΡΧΙΚΗ ΟΘΟΝΗ
        }
      }
    } 
    // ΤΕΛΟΣ ΔΙΑΛΕΙΜΜΑΤΟΣ (BREAKING)
    else if (_phase == TimerPhase.breaking) {
      // Τέλος Διαλείμματος -> Πάμε στο επόμενο session διαβάσματος
      setState(() {
        _currentSession++; // Αυξάνουμε τον αριθμό του session
        _phase = TimerPhase.studying; // ΕΠΙΣΤΡΟΦΗ ΣΕ ΔΙΑΒΑΣΜΑ
        _secondsRemaining = _studyTimeMinutes * 60; // ΧΡΟΝΟΣ ΜΕΛΕΤΗΣ
      });
      _startTicker(); // Αυτόματη έναρξη
    }
  }

  void _togglePause() {
    setState(() {
      if (_isRunning) {
        _timer?.cancel();
      } else {
        _startTicker();
      }
      _isRunning = !_isRunning;
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _phase = TimerPhase.setup;
      _isRunning = false;
    });
  }

  // UI Helpers 
  String get _timerString {
    int min = _secondsRemaining ~/ 60;
    int sec = _secondsRemaining % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _cloudAnimation,
      builder: (context, child) {
        return Scaffold(
          // Το ίδιο background με Main Page
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.lightBlue.shade200, Colors.lightBlue.shade50],
                stops: [0.0, _cloudAnimation.value.y.clamp(0.0, 1.0)],
              ),
            ),
            child: _phase == TimerPhase.setup 
                ? _buildSetupView() 
                : _buildActiveTimerView(),
          ),
        );
      }
    );
  }

  // VIEW 1: SETUP 
  Widget _buildSetupView() {
    return Stack(
      children: [
        // Close Button
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.cancel_outlined, size: 50, color: Colors.black87),
            ),
          ),
        ),
        
        // Κεντρικό Κίτρινο Πλαίσιο
        Center(
          child: Container(
            width: 300,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD54F), // Amber/Yellow
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.purple.shade200, width: 1), 
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInputRow("Studying time", _studyMinController),
                const SizedBox(height: 15),
                _buildInputRow("Break time", _breakMinController),
                const SizedBox(height: 15),
                // Sessions (Μονό κουτί)
                const Text("Sessions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                const SizedBox(height: 5),
                Container(
                  width: 60,
                  height: 50,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: TextField(
                    controller: _sessionsController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Play Button 
        Positioned(
          bottom: 150,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _startTimerLogic,
              child: const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.black,
                child: Icon(Icons.play_arrow, color: Colors.white, size: 40),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildInputRow(String label, TextEditingController controller) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Container για λεπτά (Λευκό κουτί)
            Container(
              width: 120, 
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
                      decoration: const InputDecoration(border: InputBorder.none, hintText: "00"),
                    ),
                  ),
                  const Text("min", style: TextStyle(color: Colors.grey)),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // VIEW 2 & 3: ACTIVE TIMER (Studying / Break) 
  Widget _buildActiveTimerView() {
    bool isStudying = _phase == TimerPhase.studying;
    
    return Stack(
      children: [
        // Header (Settings Icon)
        Positioned(
          top: 50, left: 20,
          child: const Icon(Icons.settings, size: 40),
        ),

        // Τίτλος & Χρονόμετρο 
        Positioned(
          top: 100, left: 0, right: 0,
          child: Column(
            children: [
              Text(
                isStudying ? "Studying left:" : "Break left:",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)),
              ),
              const SizedBox(height: 10),
              // Χρονόμετρο
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blue, // Χρώμα του Timer Bubble
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(color: Colors.blue.shade300, borderRadius: BorderRadius.circular(10)),
                      child: Text("Session: $_currentSession", style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _timerString, // MM:SS
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
                    ),
                  ],
                ),
              ),
              
              // Controls (Play/Pause/Stop) κάτω από το χρόνο
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                    iconSize: 30,
                    onPressed: _togglePause,
                  ),
                  IconButton(
                    icon: const Icon(Icons.stop),
                    iconSize: 30,
                    onPressed: _stopTimer,
                  ),
                ],
              )
            ],
          ),
        ),

        // Γραφικά (Φυτό & Ποτιστήρι) 
        
        // Γρασίδι
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: SvgPicture.asset(_grassPath, fit: BoxFit.fitWidth),
        ),

        // Φυτό (Μεγαλώνει στο Studying, Στατικό στο Break)
        Positioned(
          bottom: 120, 
          left: 40,
          child: SvgPicture.asset(
            _plantStages[_currentPlantState], // Δείχνει το στάδιο ανάπτυξης
            height: 350,
          ),
        ),

        // Γλάστρα
        Positioned(
          bottom: 40, left: 50,
          child: SvgPicture.asset(_potPath, height: 100),
        ),

        // Ποτιστήρι / Βρύση
        Positioned(
          bottom: 50, 
          right: 20,
          child: isStudying 
            ? SvgPicture.asset(
                _wateringModePath, // Ποτιστήρι που γέρνει
                height: 120,
                placeholderBuilder: (c) => Transform.rotate(
                  angle: -0.5, 
                  child: SvgPicture.asset('assets/images/watering_can_default.svg', height: 120)
                ),
              )
            : SvgPicture.asset(
                _fillingModePath, // Ποτιστήρι κάτω από βρύση
                height: 180, 
                placeholderBuilder: (c) => Column(
                  children: [
                    SvgPicture.asset('assets/images/tap_begging.svg', height: 60),
                    SvgPicture.asset('assets/images/watering_can_default.svg', height: 100),
                  ],
                ),
              ),
        ),
      ],
    );
  }
}