import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class Alarm {
  final TimeOfDay time;
  final String label;
  final List<String> notes;
  final bool enabled;

  Alarm({required this.time, required this.label, required this.notes, this.enabled = true});
}

class Note {
  final String title;
  final String content;

  Note({required this.title, required this.content});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alarm + Notes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AlarmNotesScreen(),
    );
  }
}

class AlarmNotesScreen extends StatefulWidget {
  @override
  _AlarmNotesScreenState createState() => _AlarmNotesScreenState();
}

class _AlarmNotesScreenState extends State<AlarmNotesScreen> {
  List<Alarm> alarms = [];
  List<Note> notes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alarm + Notes'),
      ),
      body: ListView.builder(
        itemCount: alarms.length + notes.length,
        itemBuilder: (context, index) {
          if (index < alarms.length) {
            var alarm = alarms[index];
            return ListTile(
              title: Text(alarm.label),
              subtitle: Text('Time: ${alarm.time.format(context)}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AlarmDetailScreen(alarm: alarm),
                  ),
                );
              },
            );
          } else {
            var note = notes[index - alarms.length];
            return ListTile(
              title: Text(note.title),
              subtitle: Text(note.content),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddItemScreen(
                addAlarm: (time, label, notes) {
                  setState(() {
                    alarms.add(Alarm(time: time, label: label, notes: notes));
                  });
                },
                addNote: (title, content) {
                  setState(() {
                    notes.add(Note(title: title, content: content));
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class AddItemScreen extends StatefulWidget {
  final Function(TimeOfDay time, String label, List<String> notes) addAlarm;
  final Function(String title, String content) addNote;

  AddItemScreen({required this.addAlarm, required this.addNote});

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  TimeOfDay selectedTime = TimeOfDay.now();
  String label = '';
  List<String> notes = [];
  bool isAlarm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Item'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: isAlarm ? Colors.blue : Colors.grey,
                      onPrimary: isAlarm ? Colors.white : Colors.black,
                    ),
                    child: Text('Alarm'),
                    onPressed: () {
                      setState(() {
                        isAlarm = true;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: !isAlarm ? Colors.blue : Colors.grey,
                      onPrimary: !isAlarm ? Colors.white : Colors.black,
                    ),
                    child: Text('Note'),
                    onPressed: () {
                      setState(() {
                        isAlarm = false;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            if (isAlarm) ...[
              ElevatedButton(
                child: Text('Select Time'),
                onPressed: () async {
                  final TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (time != null) {
                    setState(() {
                      selectedTime = time;
                    });
                  }
                },
              ),
              SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Label',
                ),
                onChanged: (value) {
                  setState(() {
                    label = value;
                  });
                },
              ),
            ] else ...[
              TextField(
                decoration: InputDecoration(
                  labelText: 'Title',
                ),
                onChanged: (value) {
                  setState(() {
                    label = value;
                  });
                },
              ),
              SizedBox(height: 16.0),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Content',
                ),
                onChanged: (value) {
                  setState(() {
                    notes = value.split('\n');
                  });
                },
                maxLines: null,
              ),
            ],
            SizedBox(height: 16.0),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                if (isAlarm) {
                  widget.addAlarm(selectedTime, label, notes);
                } else {
                  widget.addNote(label, notes.isNotEmpty ? notes.first : '');
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AlarmDetailScreen extends StatelessWidget {
  final Alarm alarm;

  AlarmDetailScreen({required this.alarm});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alarm Detail'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Label: ${alarm.label}'),
                SizedBox(height: 8.0),
                Text('Time: ${alarm.time.format(context)}'),
                SizedBox(height: 16.0),
                Text(
                  'Notes:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: alarm.notes
                      .map((note) => Text('- $note'))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
