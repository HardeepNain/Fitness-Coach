import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/fitness_model.dart';
import '../services/api_service.dart';
import '../widgets/nav_drawer.dart';
import 'fitness_chat_screen.dart';
import 'fitness_edit_screen.dart';
import 'fitness_entry_screen.dart';
import 'view_fitness_screen.dart';

class FitnessListScreen extends StatefulWidget {
  const FitnessListScreen({super.key});

  @override
  State<FitnessListScreen> createState() => _FitnessListScreenState();
}

class _FitnessListScreenState extends State<FitnessListScreen> {
  final List<FitnessModel> _fitnessEntries = [];
  late final String userId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  _checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId').toString();
    await _loadFitnessList();
  }

  Future<void> _loadFitnessList() async {
    setState(() {
      _isLoading = true;
    });
    var apiResponse = await ApiService.get('fitnesses/$userId');
    if (apiResponse.statusCode >= 200 && apiResponse.statusCode < 300) {
      final responseData = jsonDecode(apiResponse.body);
      setState(() {
        _fitnessEntries.clear();
        for (var fitness in responseData) {
          if (fitness['message'] == null) {
            _fitnessEntries.add(FitnessModel.fromJson(fitness));
          }
        }
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      final responseData = jsonDecode(apiResponse.body);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(responseData["message"])));
    }
  }

  Future<void> _deleteFitness(String fitnessId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await ApiService.delete('fitness/$fitnessId');
      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Fitness plan deleted successfully: $fitnessId');
        }
        setState(() {
          _isLoading = false;
        });
        _loadFitnessList();
      } else {
        throw Exception('Failed to delete fitness plan');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting fitness plan: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete fitness plan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => FitnessChatScreen()),
              );
            },
          ),
        ],

        title: const Text('Fitness Plans'),
      ),
      drawer: const NavDrawer(selectedIndex: 2),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: _fitnessEntries.length,
                itemBuilder: (context, index) {
                  final fitness = _fitnessEntries[index];
                  DateTime dateTime =
                      DateTime.parse(fitness.createdAt).toLocal();
                  var format = DateFormat('dd MMM, yyyy hh:MM a');
                  String formattedDate = format.format(
                    dateTime.toUtc().add(const Duration(hours: -8)),
                  );
                  return ListTile(
                    title: Text(fitness.title),
                    subtitle: Text(formattedDate),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) => ViewFitnessScreen(
                                title: fitness.title,
                                fitnessEntry: fitness.fitnessEntry,
                                date: formattedDate,
                              ),
                        ),
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            // Handle edit action
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => FitnessEditScreen(
                                      fitnessId: fitness.fitnessId,
                                      title: fitness.title,
                                      fitnessEntry: fitness.fitnessEntry,
                                    ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _deleteFitness(fitness.fitnessId);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const FitnessEntryScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}