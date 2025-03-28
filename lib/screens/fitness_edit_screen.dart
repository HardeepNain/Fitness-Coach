import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import 'fitness_list_screen.dart';

class FitnessEditScreen extends StatefulWidget {
  final String fitnessId;
  final String title;
  final String fitnessEntry;

  const FitnessEditScreen({
    super.key,
    required this.fitnessId,
    required this.title,
    required this.fitnessEntry,
  });

  @override
  State<FitnessEditScreen> createState() => _FitnessEditScreenState();
}

class _FitnessEditScreenState extends State<FitnessEditScreen> {
  late String title;
  late String nutritionEntry;
  late String date;

  final TextEditingController _bodyTextEditingController =
      TextEditingController();
  final TextEditingController _titleTextEditingController =
      TextEditingController();
  late final String userId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    title = widget.title;
    nutritionEntry = widget.fitnessEntry;

    _bodyTextEditingController.text = nutritionEntry;
    _titleTextEditingController.text = title;

    _checkLogin();
  }

  _checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId').toString();
  }

  @override
  void dispose() {
    _bodyTextEditingController.dispose();
    _titleTextEditingController.dispose();
    super.dispose();
  }

  Future<void> _saveFitnessEntry() async {
    final title = _titleTextEditingController.text;
    final body = _bodyTextEditingController.text;
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title and body')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    var apiResponse = await ApiService.put('fitness/${widget.fitnessId}', {
      'userId': userId,
      'title': title,
      'fitness_entry': body,
    });
    if (apiResponse.statusCode >= 200 && apiResponse.statusCode < 300) {
      setState(() {
        _isLoading = false;
      });
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const FitnessListScreen()),
        (Route<dynamic> route) => false, // This removes all previous routes
      );
    } else {
      final responseData = jsonDecode(apiResponse.body);
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(responseData["message"])));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _saveFitnessEntry();
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleTextEditingController,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        hintText: 'Title',
                        border: InputBorder.none,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _bodyTextEditingController,
                        maxLines: null,
                        expands: true,
                        decoration: const InputDecoration(
                          hintText: 'Start making your fitness plan...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}