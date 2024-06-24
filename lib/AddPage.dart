import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddPage extends StatefulWidget {
  final DateTime date;
  const AddPage({super.key, required this.date});

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  TextEditingController _textController = TextEditingController();
  double _happinessLevel = 50; // Default happiness level set to 50%

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy.MM.dd EEE').format(widget.date);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              _showConfirmationDialog(context);
            },
          ),
        ],
        title: Text(formattedDate),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Write your happiness for the day',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Write your content',
                filled: true,
                fillColor: Colors.grey,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              maxLines: 10,
            ),
            const SizedBox(height: 20),
            Text(
              'Rate your happiness today: ${_happinessLevel.round()}%',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Slider(
              value: _happinessLevel,
              min: 0,
              max: 100,
              divisions: 100,
              label: _happinessLevel.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _happinessLevel = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Want to save your happiness?'),
          content: const Text('Happiness can be written once per day. You cannot edit it once added.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                String formattedDate = DateFormat('yyyy.MM.dd').format(widget.date);
                String content = _textController.text;
                int happiness = _happinessLevel.round();
                // Save the data to Firestore
                await FirebaseFirestore.instance.collection('memo').add({
                  'date': formattedDate,
                  'content': content,
                  'happiness': happiness,  // Storing happiness level
                });
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Close AddPage after saving
              },
            ),
          ],
        );
      },
    );
  }
}

