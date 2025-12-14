import 'package:flutter/material.dart';

import 'settings_screen.dart'; 
import 'new_task_screen.dart';
import 'new_deadline_screen.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<String> tasks = ['Study Session - Algebra (45m)', 'Review HCI Notes', 'Gym'];
  final List<String> deadlines = ['HCI Project Deadline (23:59)', 'Math Exam (13 Dec)'];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, 
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              //  HEADER (Ρυθμίσεις & AI Planner)
              _buildHeader(context),
              
              // TAB BAR (Tasks / Deadlines)
              _buildTabBar(),
              
              // ΠΕΡΙΕΧΟΜΕΝΟ ΤΩΝ TABS (Το σώμα της λίστας)
              Expanded(
                child: TabBarView(
                  children: [
                    // Tasks List
                    _buildTaskList(tasks),
                    // Deadlines List
                    _buildTaskList(deadlines, isDeadline: true), 
                  ],
                ),
              ),
              
              // AI PLANNER BUTTON 
              _buildAIPlannerButton(),
            ],
          ),
        ),
        
        // Προσθήκη Νέας Εργασίας
        floatingActionButton: FloatingActionButton(
          heroTag: "todo_add_btn", 
          onPressed: () {
            _showAddTaskDialog(context);
          },
          backgroundColor: Colors.pink, 
          child: const Icon(Icons.add, color: Colors.white),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start, // Αλλάζουμε σε Start
        children: [
          // Κουμπί Ρυθμίσεων
          IconButton(
            icon: const Icon(Icons.settings, size: 30),
            onPressed: () {
              // Πλοήγηση στα Settings
              Navigator.push(context, MaterialPageRoute(builder: (c) => const SettingsScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.yellow.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const TabBar(
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black54,
          indicator: BoxDecoration(
            color: Colors.orange, 
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          tabs: [
            Tab(text: 'Tasks'),
            Tab(text: 'Deadlines'),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(List<String> items, {bool isDeadline = false}) {
    // Εμφάνιση της λίστας εργασιών/προθεσμιών
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _buildTaskItem(context, items[index], isDeadline);
      },
    );
  }

  Widget _buildTaskItem(BuildContext context, String title, bool isDeadline) {
    // Προσομοίωση κάθε στοιχείου της λίστας (κυκλάκι, κείμενο, προτεραιότητα)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          // Κυκλάκι (Check/Uncheck)
          const Icon(Icons.circle_outlined, size: 18, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(child: Text(title)),
          // Προτεραιότητα (μόνο για Deadlines)
          if (isDeadline) 
            const Text('HIGH PRIORITY', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAIPlannerButton() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      // Τοποθετούμε το κουμπί AI Planner στο κάτω αριστερά 
      child: Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          style: TextButton.styleFrom(
            backgroundColor: Colors.blue.shade100,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          onPressed: () {
            // Εδώ θα εμφανιστεί το AI Planner dialog 
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Calling AI Planner...')),
            );
          },
          icon: const Icon(Icons.psychology, color: Colors.blue),
          label: const Text('AI Planner', style: TextStyle(color: Colors.blue)),
        ),
      ),
    );
  }
  
  // Dialog για επιλογή φόρμας
  void _showAddTaskDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.note_add, color: Colors.green),
              title: const Text('Add New Task'),
              onTap: () {
                Navigator.pop(bc); 
                Navigator.push(context, MaterialPageRoute(builder: (c) => const NewTaskScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.alarm, color: Colors.red),
              title: const Text('Add New Deadline'),
              onTap: () {
                Navigator.pop(bc);
                Navigator.push(context, MaterialPageRoute(builder: (c) => const NewDeadlineScreen()));
              },
            ),
          ],
        );
      },
    );
  }
}
