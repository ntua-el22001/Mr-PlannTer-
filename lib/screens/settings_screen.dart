import 'package:flutter/material.dart';
import '../services/google_calendar_service.dart';
import '../data/local_storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // State
  bool _isGoogleSyncEnabled = false;
  bool _soundEnabled = true;
  String _selectedSong = 'Choose a song';
  String? _connectedDevice;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    await LocalStorageService().init();
    final storage = LocalStorageService();
    setState(() {
      _selectedSong = storage.getSelectedSong() ?? 'Choose a song';
      _connectedDevice = storage.getConnectedDevice();
      _isGoogleSyncEnabled = storage.isGoogleSyncEnabled;
      _soundEnabled = storage.isSoundEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.lightBlue.shade200, // Φόντο Ουρανού
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Γρανάζι 
            Positioned(
              top: 50,
              left: 20,
              child: Icon(Icons.settings, size: 40, color: Colors.brown.shade900),
            ),

            // Σύννεφα 
            Positioned(
              top: 150,
              left: -50,
              child: Container(
                width: 150, height: 150,
                decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255, 0.5), shape: BoxShape.circle),
              ),
            ),
            Positioned(
              bottom: 100,
              right: -50,
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255, 0.5), shape: BoxShape.circle),
              ),
            ),

            // ΚΟΥΜΠΙ ΚΛΕΙΣΙΜΑΤΟΣ (X)
            Positioned(
              top: 200, 
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 3),
                  ),
                  child: const Icon(Icons.close, size: 40, color: Colors.black),
                ),
              ),
            ),

            // Κεντρικό Κίτρινο Πλαίσιο (Sound, Music, Bluetooth)
            Positioned(
              top: 280,
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD54F), 
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sound Column
                    _buildSettingsItem(
                      icon: _soundEnabled ? Icons.volume_up_outlined : Icons.volume_off_outlined,
                      label: 'Sound',
                      value: _soundEnabled ? 'On' : 'Off',
                      onTap: () {
                        setState(() => _soundEnabled = !_soundEnabled);
                        LocalStorageService().setSoundEnabled(_soundEnabled);
                      },
                    ),
                    
                    // Music Column
                    _buildSettingsItem(
                      icon: Icons.music_note,
                      label: 'Music',
                      value: _selectedSong == 'Choose a song' ? 'Choose\na song' : 'Change\nSong',
                      onTap: () => _showSongsList(context),
                    ),

                    // Bluetooth Column
                    _buildSettingsItem(
                      icon: Icons.bluetooth,
                      label: 'Bluetooth',
                      value: _connectedDevice != null ? 'Connected' : 'Connect\nto\nDevice',
                      onTap: () => _showDeviceList(context),
                    ),
                  ],
                ),
              ),
            ),
            
            // Google Sync (Optional)
            Positioned(
              bottom: 50,
              child: Opacity(
                opacity: 0.8,
                child: ElevatedButton.icon(
                  onPressed: () => _handleGoogleSync(context),
                  icon: Icon(_isGoogleSyncEnabled ? Icons.sync : Icons.sync_disabled),
                  label: Text(_isGoogleSyncEnabled ? 'Google Sync: ON' : 'Enable Google Sync'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper για τα εικονίδια στο κίτρινο κουτί
  Widget _buildSettingsItem({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0D47A1))), // Dark Blue Text
          const SizedBox(height: 10),
          Icon(icon, size: 40, color: Colors.black),
          const SizedBox(height: 10),
          Text(
            value, 
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0D47A1)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGoogleSync(BuildContext context) async {
    // Toggle logic
    bool newState = !_isGoogleSyncEnabled;
    setState(() => _isGoogleSyncEnabled = newState);
    await LocalStorageService().setGoogleSyncEnabled(newState);
    
    if (newState) {
      // Trigger authentication if enabling
      final api = await GoogleCalendarService().authenticate();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar( // ignore: use_build_context_synchronously
        content: Text(api != null ? 'Connected to Google Calendar!' : 'Connection Failed'),
      ));
    }
  }

  void _showDeviceList(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (c) => PlaceholderDeviceScreen(
      onSelectDevice: (device) {
        setState(() => _connectedDevice = device);
        LocalStorageService().setConnectedDevice(device);
      },
      currentDevice: _connectedDevice,
    )));
  }

  void _showSongsList(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (c) => PlaceholderSongsScreen(
      onSelectSong: (song) {
        setState(() => _selectedSong = song);
        LocalStorageService().setSelectedSong(song);
      },
      currentSong: _selectedSong,
    )));
  }
}


class PlaceholderDeviceScreen extends StatelessWidget {
  final Function(String) onSelectDevice;
  final String? currentDevice;
  const PlaceholderDeviceScreen({super.key, required this.onSelectDevice, required this.currentDevice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade200, // Φόντο Ουρανού
      body: Center(
        child: Container(
          width: 300,
          height: 400,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD54F), 
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
                  const Text('Available devices', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF0D47A1))),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _buildItem('Connected device\'s name', true),
                    _buildItem('Available device\'s name 1', false),
                    _buildItem('Available device\'s name 2', false),
                    _buildItem('Available device\'s name 3', false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(String name, bool isConnected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: GestureDetector(
        onTap: () => onSelectDevice(name),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isConnected ? Colors.green : Colors.transparent,
            border: Border.all(color: const Color(0xFF0D47A1)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              name, 
              style: TextStyle(
                color: isConnected ? Colors.white : const Color(0xFF0D47A1), 
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PlaceholderSongsScreen extends StatelessWidget {
  final Function(String) onSelectSong;
  final String currentSong;
  const PlaceholderSongsScreen({super.key, required this.onSelectSong, required this.currentSong});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade200,
      body: Center(
        child: Container(
          width: 300,
          height: 500,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD54F),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
                  const Text('Songs List', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF0D47A1))),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _buildItem('No song'),
                    _buildItem('Selected song\'s name'),
                    _buildItem('Available song\'s name'),
                    _buildItem('Import a new song'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(String name) {
    bool isSelected = name == currentSong || (name == 'Selected song\'s name' && currentSong != 'Choose a song');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: GestureDetector(
        onTap: () => onSelectSong(name),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green : Colors.transparent,
            border: Border.all(color: const Color(0xFF0D47A1)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              name, 
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF0D47A1), 
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ),
      ),
    );
  }
}