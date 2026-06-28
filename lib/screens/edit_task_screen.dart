import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditTaskScreen extends StatefulWidget {
  final String taskId;
  final String currentTitle;
  final String currentDescription;

  const EditTaskScreen({
    super.key,
    required this.taskId,
    required this.currentTitle,
    required this.currentDescription,
  });

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _firestore = FirebaseFirestore.instance;
  late TextEditingController _titleController;
  late TextEditingController _descController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.currentTitle);
    _descController = TextEditingController(text: widget.currentDescription);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _updateTask() async {
    final enteredTitle = _titleController.text.trim();
    final enteredDesc = _descController.text.trim();

    if (enteredTitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tajuk tidak boleh kosong!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore.collection('tasks').doc(widget.taskId).update({
        'title': enteredTitle,
        'description': enteredDesc,
      });

      if (mounted) {
        Navigator.of(context).pop(); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Kemaskini Tugasan ✏️',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Tajuk Tugasan',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Deskripsi / Nota',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _updateTask,
                    child: const Text(
                      'Kemaskini Tugasan ✨',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}