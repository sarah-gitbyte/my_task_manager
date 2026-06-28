import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;

  void _submitData() async {
    final enteredTitle = _titleController.text.trim();
    final enteredDesc = _descController.text.trim();
    final currentUser = FirebaseAuth.instance.currentUser;

    if (enteredTitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sila isi tajuk tugasan!')),
      );
      return;
    }

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ralat: Sesi pengguna tidak ditemui. Sila log masuk semula!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
     await FirebaseFirestore.instance.collection('tasks').add({
        'userId': currentUser.uid,
        'title': enteredTitle,
        'description': enteredDesc,
        'isCompleted': false,
        'createdAt': Timestamp.now(),
      });

      if (mounted) {
        Navigator.of(context).pop(); 
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Ralat Firestore Web'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Ok'),
              )
            ],
          ),
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
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: const Text('Tambah Tugasan Baru 🌸'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Tajuk Tugasan'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Deskripsi / Nota'),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.pink))
                : ElevatedButton(
                    onPressed: _submitData,
                    child: const Text('Simpan Tugasan'),
                  ),
          ],
        ),
      ),
    );
  }
}