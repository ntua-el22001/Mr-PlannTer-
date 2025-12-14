import 'package:flutter/material.dart';

class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _frequencyController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  
  // State variables για το scheduling
  DateTime? _planDate;
  TimeOfDay? _planTime;
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _frequencyController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _planDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _planDate) {
      setState(() {
        _planDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _planTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _planTime) {
      setState(() {
        _planTime = picked;
      });
    }
  }
  
  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      debugPrint('New Task Saved!');
      debugPrint('Title: ${_titleController.text}');
      debugPrint('Frequency: ${_frequencyController.text}');
      debugPrint('Duration: ${_durationController.text} minutes');
      
      Navigator.pop(context); // Επιστροφή
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.lightBlue.shade200, 
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 80, left: 20, right: 20, bottom: 100),
              child: Container(
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
                      const Text('New Task', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),

                      // Title Field
                      _buildTextField(_titleController, 'Title', isRequired: true),
                      // Description Field
                      _buildTextField(_descriptionController, 'Description', maxLines: 3),

                      const SizedBox(height: 15),

                      // Frequency & Duration
                      _buildRowFields(
                        _frequencyController, 'Frequency (days/week)', 
                        _durationController, 'Duration (minutes)',
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Plan task (Date/Time)
                      const Text('Plan your task:', style: TextStyle(fontWeight: FontWeight.bold)),
                      _buildDateTimeRow('Date', 
                        _planDate == null ? 'Select Date' : '${_planDate!.day}/${_planDate!.month}/${_planDate!.year}',
                        Icons.calendar_today, () => _selectDate(context)),
                      
                      _buildDateTimeRow('Time', 
                        _planTime == null ? 'Select Time' : _planTime!.format(context),
                        Icons.access_time, () => _selectTime(context)),
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
                onPressed: _saveTask,
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
  
  // Βοηθητικό Widget για Row Fields (Frequency & Duration)
  Widget _buildRowFields(TextEditingController freqController, String freqLabel, TextEditingController durController, String durLabel) {
    return Row(
      children: [
        Expanded(child: _buildTextField(freqController, freqLabel)),
        const SizedBox(width: 10),
        Expanded(child: _buildTextField(durController, durLabel, isRequired: true)),
      ],
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
}