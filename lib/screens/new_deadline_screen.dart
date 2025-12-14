import 'package:flutter/material.dart';

class NewDeadlineScreen extends StatefulWidget {
  const NewDeadlineScreen({super.key});

  @override
  State<NewDeadlineScreen> createState() => _NewDeadlineScreenState();
}

class _NewDeadlineScreenState extends State<NewDeadlineScreen> {
  final _formKey = GlobalKey<FormState>(); 
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  // State variables για την επιλογή ημερομηνίας/ώρας
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _importanceLevel = 1; 

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Μέθοδος για την επιλογή ημερομηνίας
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Μέθοδος για την επιλογή ώρας
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }
  
  // Μέθοδος Αποθήκευσης
  void _saveDeadline() {
    if (_formKey.currentState!.validate()) {
      debugPrint('New Deadline Saved!');
      debugPrint('Title: ${_titleController.text}');
      debugPrint('Date: $_selectedDate');
      debugPrint('Importance: $_importanceLevel');
      
      Navigator.pop(context); // Επιστροφή στην προηγούμενη οθόνη
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Χρησιμοποιούμε το 'X' για να κλείσουμε τη φόρμα 
      body: Container(
        color: Colors.lightBlue.shade200, 
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 100),
              child: Container(
                // Το κίτρινο πλαίσιο της φόρμας
                decoration: BoxDecoration(
                  color: Colors.yellow.shade300,
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('New Deadline', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),

                      // Title Field
                      _buildTextField(_titleController, 'Title', isRequired: true),
                      // Description Field
                      _buildTextField(_descriptionController, 'Description', maxLines: 3),

                      const SizedBox(height: 15),

                      // Date Input
                      _buildDateTimeRow('Date', 
                        _selectedDate == null ? 'Select Date' : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        Icons.calendar_today, () => _selectDate(context)),
                      
                      // Time Input
                      _buildDateTimeRow('Time', 
                        _selectedTime == null ? 'Select Time' : _selectedTime!.format(context),
                        Icons.access_time, () => _selectTime(context)),
                      
                      const SizedBox(height: 20),
                      
                      // Importance Level 
                      const Text('Importance:', style: TextStyle(fontWeight: FontWeight.bold)),
                      _buildImportanceSelector(),
                    ],
                  ),
                ),
              ),
            ),
            
            // X-Button (Κλείσιμο)
            Positioned(
              top: 40,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.close, size: 40, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            
            // Checkmark Button 
            Positioned(
              bottom: 30,
              right: 20,
              child: FloatingActionButton(
                onPressed: _saveDeadline,
                backgroundColor: Colors.lightGreen,
                child: const Icon(Icons.check, size: 30, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Βοηθητικό Widget για TextField
  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1, bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          fillColor: Colors.white,
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  // Βοηθητικό Widget για Date/Time Input
  Widget _buildDateTimeRow(String label, String value, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: onTap,
            child: Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(value, style: const TextStyle(decoration: TextDecoration.underline, color: Colors.blue)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Βοηθητικό Widget για την επιλογή Importance
  Widget _buildImportanceSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(5, (index) {
        final level = index + 1;
        return GestureDetector(
          onTap: () {
            setState(() {
              _importanceLevel = level;
            });
          },
          child: Icon(
            _importanceLevel >= level ? Icons.circle : Icons.circle_outlined,
            color: Colors.red,
            size: 24,
          ),
        );
      }),
    );
  }
}