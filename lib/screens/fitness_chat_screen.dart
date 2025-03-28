import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import 'fitness_list_screen.dart';

class FitnessChatScreen extends StatefulWidget {
  const FitnessChatScreen({super.key});

  @override
  State<FitnessChatScreen> createState() => _FitnessChatScreenState();
}

class _FitnessChatScreenState extends State<FitnessChatScreen> {
  final apiKey = dotenv.env['GEMINI_API_KEY'];
  bool _isLoading = false;
  bool _isAtBottom = true; // Tracks if user is at the bottom
  Timer? _scrollDebounceTimer;

  late final GenerativeModel model;
  late final String userId;
  late String chatName;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _checkLogin();

    _scrollController.addListener(() {
      if (_scrollDebounceTimer?.isActive ?? false) {
        _scrollDebounceTimer!.cancel();
      }
      _scrollDebounceTimer = Timer(const Duration(milliseconds: 100), () {
        final atBottom =
            _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 10;
        if (atBottom != _isAtBottom) {
          setState(() {
            _isAtBottom = atBottom;
          });
        }
      });
    });
    if (apiKey != null) {
      model = GenerativeModel(
        model: 'gemini-2.0-flash-lite',
        apiKey: apiKey!,
        generationConfig: GenerationConfig(
          temperature: 1,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 8192,
          responseMimeType: 'application/json',
          responseSchema: Schema(
            SchemaType.object,
            requiredProperties: ["fitness", "response", "is_fitness"],
            properties: {
              "fitness": Schema(
                SchemaType.object,
                requiredProperties: ["title", "fitness entry"],
                properties: {
                  "title": Schema(SchemaType.string),
                  "fitness entry": Schema(SchemaType.string),
                },
              ),
              "response": Schema(SchemaType.string),
              "is_fitness": Schema(SchemaType.boolean),
            },
          ),
        ),
        systemInstruction: Content.system(
          ' "You are a highly knowledgeable and empathetic AI fitness expert. Your primary goal is to create personalized workout plans for users based on their individual goals, current fitness levels, and any relevant health considerations. You will engage in a conversational manner, asking targeted questions to gather the necessary information. You will focus solely on fitness-related discussions. If a user deviates from fitness topics, gently redirect them back to the workout planning process. \\n\\nYour interactions follow this specific structure:\\n\\n*   **Conversation Phase:** Engage in a question-and-answer dialogue to understand the user\'s needs. Ask clear and concise questions about their goals, experience, current fitness level, any existing medical conditions or limitations, and available equipment. Focus on eliciting information that will inform the workout plan.\\n*   **Plan Generation Phase:** Once sufficient information is gathered, you will generate a structured workout plan.  This plan will be represented as a JSON object with the following properties:\\n    *   `fitness`: An object that contains:\\n        *   `title`: A descriptive title for the workout plan (e.g., \\"Beginner Full Body Workout\\", \\"Intermediate Strength Training\\").\\n        *   `fitness entry`: A detailed description of the workout plan, including:\\n            *   Exercise name.\\n            *   Detailed instructions on how to perform each exercise correctly.\\n            *   The muscle groups targeted by each exercise.\\n            *   The number of sets and repetitions for each exercise.\\n            *   The recommended rest time between sets.\\n            *   The frequency of the workout (e.g., \\"3 times per week\\").\\n            *   Approximate workout duration.\\n            *   Any specific notes or modifications based on the user\'s needs.\\n    *   `response`: A conversational response to the user. Thank them for the information, summarize the plan, and provide any further advice or encouragement.  This is the \'friendly\' part of the response.\\n    *   `is_fitness`: A boolean value indicating whether the response is related to fitness planning. Set this to `true` when generating a workout plan or asking fitness-related questions. Set to `false` if the user asks a non-fitness-related question and you are redirecting them.\\n\\n*   **Output Format:**  Always respond in valid JSON format, following the schema provided. Do NOT include extraneous text outside of the JSON block. Do not include example responses. Always end the conversation with a valid JSON response.\\n\\n**Your conversational style should be:**\\n\\n*   **Friendly and encouraging:** Use positive language to motivate the user.\\n*   **Patient and understanding:** Be prepared to reiterate questions or provide clarification as needed.\\n*   **Informative and accurate:** Base your advice on established fitness principles.\\n*   **Concise:** Get straight to the point while being thorough in your questioning.\\n\\n**Example Interaction (Illustrative, do NOT include in actual responses):**\\n\\nUser: \\"I want to lose weight and get in shape.\\" \\nAI: (Asks questions about activity level, diet, and goals) \\nUser: \\"I can work out 3 times a week. I have dumbbells.\\"\\nAI: (Generates a workout plan and provides encouragement)\\n\\n**Initial Questions to Ask:**\\n\\n1.  \\"Hello! I\'m excited to help you create a personalized workout plan. To get started, what are your primary fitness goals? (e.g., weight loss, muscle gain, improved endurance, general fitness, etc.)\\"\\n2.  \\"Could you describe your current activity level? (e.g., sedentary, lightly active, moderately active, very active)\\"\\n3.  \\"Do you have any existing medical conditions, injuries, or physical limitations that I should be aware of? Please provide details.\\"\\n4.  \\"What equipment do you have access to? (e.g., gym, dumbbells, resistance bands, bodyweight only)\\"\\n5. \\"How many days a week can you dedicate to working out?\\"\\n\\n**Important Considerations:**\\n\\n*   If the user provides information suggesting medical concerns, strongly encourage them to consult a physician before starting any new exercise program. Note this in the workout plan.\\n*   Adapt the intensity and complexity of the workouts based on the user\'s experience level.\\n*   Prioritize proper form over heavy weights, especially for beginners.\\n*   Incorporate warm-up and cool-down exercises into the workout plans.\\n*   Remind users of the importance of proper nutrition and adequate rest.\\n\\nBegin by greeting the user and asking your initial question.  Always adhere to the defined JSON output format.\\n"\n}',
        ),
      );
    } else {
      log('GEMINI_API_KEY is not set in .env');
    }
  }

  _checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId').toString();
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();

  Future<void> _saveFitnessEntry(String title, String fitnessEntry) async {
    setState(() {
      _isLoading = true;
    });
    var apiResponse = await ApiService.post('fitness', {
      'userId': userId,
      'title': title,
      'fitness_entry': fitnessEntry,
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

  Future<void> _handleSubmitted(String text) async {
    _textController.clear();

    List<Content> chatHistory = [];
    for (var message in _messages) {
      chatHistory.add(Content(message.sender, [TextPart(message.text)]));
    }

    setState(() {
      _messages.add(ChatMessage(text: text, sender: "user"));
      _isLoading = true;
    });
    if (_isAtBottom) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
    await Future.delayed(Duration(seconds: 1));

    final chat = model.startChat(
      history:
          _messages.map((m) => Content(m.sender, [TextPart(m.text)])).toList(),
    );
    final content = Content.text(text);
    final response = await chat.sendMessage(content);

    if (response.text != null) {
      print(response.text);
      final Map<String, dynamic> data = jsonDecode(response.text!);

      // Check the 'is_fitness' field.
      if (data['is_fitness'] == true) {
        // Parse the fitness object.
        final Map<String, dynamic> fitness = data['fitness'];
        final String fitnessEntry = fitness['fitness entry'];
        final String title = fitness['title'];

        // Display the parsed fitness fields along with the response.
        if (kDebugMode) {
          print('Fitness Entry: $fitnessEntry');
          print('Title: $title');
          print('Response: ${data['response']}');
        }

        final modelMessage =
            '${data['response']}\n\nFitness Plan: \n\n Title: $title\n Fitness Plan: $fitnessEntry';
        setState(() {
          _isLoading = false;
          _messages.add(ChatMessage(text: modelMessage, sender: "model"));
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Add Fitness Plan'),
              content: SingleChildScrollView(child: Text(modelMessage)),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Add'),
                  onPressed: () {
                    _saveFitnessEntry(title, fitnessEntry);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        // Only display the response.
        if (kDebugMode) {
          print('Response: ${data['response']}');
        }
        setState(() {
          _isLoading = false;
          _messages.add(ChatMessage(text: data['response'], sender: "model"));
        });
      }
    }

    setState(() {});
    if (_isAtBottom) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
    await Future.delayed(Duration(seconds: 1));

    if (_isAtBottom) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
    await Future.delayed(Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fitness Planning Chat')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                color: Theme.of(context).colorScheme.surface,
                child: Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          ListView.builder(
                            controller: _scrollController,
                            itemCount: _messages.length,
                            itemBuilder:
                                (context, index) =>
                                    ChatBubble(message: _messages[index]),
                          ),
                          if (!_isAtBottom)
                            Positioned(
                              bottom: 10,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: FloatingActionButton(
                                  onPressed: _scrollToBottom,
                                  mini: true,
                                  child: const Icon(Icons.arrow_downward),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    _buildTextComposer(),
                  ],
                ),
              ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.onSurface,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          Flexible(
            child: TextField(
              controller: _textController,
              onSubmitted: _handleSubmitted,
              decoration: const InputDecoration.collapsed(
                hintText: 'Send a message',
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
              icon: const Icon(Icons.send),
              onPressed: () => _handleSubmitted(_textController.text),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollDebounceTimer?.cancel();
    _textController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final String sender;
  ChatMessage({required this.text, required this.sender});
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({super.key, required this.message});

  void _copyToClipboard(BuildContext context, String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Copied to clipboard")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to copy: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == "user";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color:
                        isUser
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: SelectableText(message.text),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () => _copyToClipboard(context, message.text),
                  tooltip: "Copy",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}