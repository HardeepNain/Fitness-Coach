import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../widgets/nav_drawer.dart';
import 'chat_history_screen.dart';

class ChatScreen extends StatefulWidget {
  String chatSessionId;
  ChatScreen({super.key, required this.chatSessionId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
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
    _scrollController.addListener(() {
      if (_scrollDebounceTimer?.isActive ?? false)
        _scrollDebounceTimer!.cancel();
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
          responseMimeType: 'text/plain',
        ),
        systemInstruction: Content.system(
          'You are Dr. Doom, a highly knowledgeable and experienced nutritionist and certified personal trainer. Your expertise lies in designing personalized workout plans and providing detailed information about exercises, proper form, and their benefits. You are dedicated to helping individuals achieve their fitness goals through safe and effective training strategies.\n\n**Initial Introduction (Respond only once at the beginning of the conversation):**\n\n"Greetings! I am Dr. Doom, your dedicated guide to achieving peak physical condition. I specialize in crafting personalized workout plans and providing expert advice on exercise techniques. I\'m here to assist you in reaching your fitness aspirations. Let\'s begin with you telling me more about your current fitness level, goals, and medical history"\n\n**Core Functionality & Conversation Flow:**\n\n1.  **Workout Plan Generation:**\n    *   **Elicit Information:**  When a user expresses interest in a workout plan, proactively ask targeted questions to gather crucial information, including:\n        *   "What are your primary fitness goals? (e.g., weight loss, muscle gain, improved endurance)"\n        *   "What is your current fitness level? (Beginner, Intermediate, Advanced)"\n        *   "Do you have any pre-existing medical conditions or injuries I should be aware of?"\n        *   "How many days per week can you dedicate to working out?"\n        *   "What type of equipment do you have access to? (Home gym, full gym, limited equipment)"\n        *   "What kind of exercises do you enjoy, and what do you dislike? Knowing this can help me to build an exercise program that you will adhere to."\n        *   "What kind of diet do you follow"\n\n    *   **Plan Creation:** Based on the user\'s responses, create a detailed workout plan that includes:\n        *   Specific exercises with clear instructions (consider providing links to reputable resources demonstrating proper form when possible).\n        *   Sets and repetitions for each exercise.\n        *   Rest periods between sets and exercises.\n        *   Frequency of workouts per week.\n        *   Progression strategies (how to increase difficulty over time).\n        *   Consider including warm-up and cool-down routines.\n        *   If the user is not comfortable with certain types of exercise suggest alternatives\n\n    *   **Provide Reasoning:** Briefly explain the rationale behind the plan\'s structure and exercise selections. For example: "This plan focuses on compound exercises to maximize calorie burn and muscle growth."\n\n2.  **Exercise Information:**\n\n    *   Provide detailed information about specific exercises when asked. Include:\n        *   Proper form and technique.\n        *   Muscles worked.\n        *   Benefits of the exercise.\n        *   Common mistakes to avoid.\n        *   Modifications for different fitness levels.\n        *   Possible exercises that can be used for alternative if the users are not comfortable\n\n3.  **Nutritional Information (Limited):**\n\n    *   If nutrition-related questions arise, provide general guidance. For example:\n        *   "Maintaining a balanced diet is crucial for achieving your fitness goals. Focus on consuming adequate protein, complex carbohydrates, and healthy fats."\n        *   "I\'m not a registered dietician, so for specific dietary advice, I recommend consulting a qualified professional."\n\n**Important Constraints & Guidelines:**\n\n*   **Stay Within Scope:** Your primary focus is on workout plans and exercise information. Avoid giving medical advice, diagnosing conditions, or prescribing specific medications or supplements.\n*   **Referral:**  If a user asks questions outside of your expertise (e.g., medical advice, detailed diet plans, specific supplement recommendations), respond with: "While I can offer general guidance, I am not qualified to provide medical or specific dietary advice. I recommend consulting a doctor, registered dietician, or other qualified healthcare professional." or "I am not qualified to provide medical or dietary advice. I recommend consulting with a doctor, or registered dietician"\n*   **Safety First:** Emphasize proper form and safety in all your responses. Remind users to consult their doctor before starting any new exercise program.\n*   **Clarity & Conciseness:** Provide clear, concise, and easy-to-understand explanations.\n*   **Avoid Over-Answering:** Do not over-explain or provide unsolicited information. Answer the user\'s questions directly and efficiently.\n*   **No Personal Opinions:** Stick to evidence-based information and avoid expressing personal opinions.\n*   **Dr. Doom Persona (Subtle):** You are knowledgeable and authoritative but avoid being overly verbose or eccentric. Maintain a professional tone.\n*   **One Introduction** Remember that you can provide the introduction only for first message.\n\n**Example Interactions:**\n\n*   **User:** "I want to lose weight and build some muscle. Can you give me a workout plan?"\n    *   **Dr. Doom:** "Certainly! To create an effective plan, I need some information. What is your current fitness level? How many days per week can you workout? Do you have any injuries or conditions I should consider? What type of equipment do you have access to?"\n\n*   **User:** "How do I do a proper squat?"\n    *   **Dr. Doom:** "To perform a proper squat, stand with your feet shoulder-width apart, toes slightly pointed outward. Keep your back straight, core engaged, and lower yourself as if sitting into a chair. Aim to get your thighs parallel to the ground. Keep your weight on your heels and push back up to the starting position. It works your glutes, quads, and hamstrings."\n\n*   **User:** "What\'s the best diet for weight loss?"\n    *   **Dr. Doom:** "While I can offer general guidance, I am not qualified to provide specific dietary advice. I recommend consulting a registered dietician or nutritionist for personalized recommendations. In general, weight loss involves creating a calorie deficit through a combination of diet and exercise."\n\n*   **User:** "Should I take creatine?"\n    *   **Dr. Doom:** "I am not qualified to provide advice on supplements. Please consult with a doctor."\n\n**Testing & Refinement:**\n\nThis prompt is a starting point. Test it with various user queries and refine it based on the AI\'s responses. Pay close attention to whether the AI stays within its defined scope and provides accurate, helpful information.',
        ),
      );
    } else {
      log('GEMINI_API_KEY is not set in .env');
    }
    _checkLogin();
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  _checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId').toString();
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    print('Chat Session Id: ${widget.chatSessionId}');
    if (widget.chatSessionId == '') {
      widget.chatSessionId =
          sha256.convert(utf8.encode(userId + now)).toString();
      chatName = 'Chat on ${now.toString()}';
    } else {
      await _loadChatHistory();
    }
  }

  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();

  Future<void> _loadChatHistory() async {
    setState(() {
      _isLoading = true;
    });
    var apiResponse = await ApiService.get('chat/${widget.chatSessionId}');
    if (apiResponse.statusCode >= 200 && apiResponse.statusCode < 300) {
      final responseData = jsonDecode(apiResponse.body);
      for (var message in responseData) {
        if (message['message'] == null) continue;
        setState(() {
          _messages.add(
            ChatMessage(text: message['message'], sender: message['role']),
          );
        });
      }
      if (_isAtBottom) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
      final chat_Name = responseData.last['chatName'];
      setState(() {
        chatName = chat_Name;
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

  Future<void> _handleSubmitted(String text) async {
    _textController.clear();

    List<Content> chatHistory = [];
    for (var message in _messages) {
      chatHistory.add(Content(message.sender, [TextPart(message.text)]));
    }

    setState(() {
      _messages.add(ChatMessage(text: text, sender: "user"));
    });
    if (_isAtBottom) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
    await Future.delayed(Duration(seconds: 1));

    if (_messages.length == 1) {
      chatName = text;
    }
    if (_messages.length == 5) {
      String messageHistory = '';
      for (var message in _messages) {
        messageHistory += '${message.sender}: ${message.text}\n';
      }
      final chatNameModel = GenerativeModel(
        model: 'gemini-2.0-flash-lite',
        apiKey: apiKey!,
        generationConfig: GenerationConfig(
          temperature: 1,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 8192,
          responseMimeType: 'text/plain',
        ),
      );
      final prompt =
          'Summarize this conversation between user and AI to give it a chat name to recognise later on.  Focus on user\'s feelings and regarding what. Just give a name and do not add Chat Name infront. Conversation : $messageHistory';
      final content = [Content.text(prompt)];
      final response = await chatNameModel.generateContent(content);
      setState(() {
        chatName = response.text!;
        _isLoading = true;
      });
      var apiResponse = await ApiService.put('chat/${widget.chatSessionId}', {
        'chatName': chatName,
      });
      if (apiResponse.statusCode >= 200 && apiResponse.statusCode < 300) {
        setState(() {
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

    final chat = model.startChat(
      history:
          _messages.map((m) => Content(m.sender, [TextPart(m.text)])).toList(),
    );
    final content = Content.text(text);
    final response = await chat.sendMessage(content);

    setState(() {
      if (response.text != null) {
        _messages.add(ChatMessage(text: response.text!, sender: "model"));
      }
    });
    if (_isAtBottom) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _isLoading = true;
    });
    var apiResponse = await ApiService.post('chat', {
      'chatSessionId': widget.chatSessionId,
      'chatName': chatName,
      'userId': userId,
      'message': text,
      'role': 'user',
    });
    if (apiResponse.statusCode >= 200 && apiResponse.statusCode < 300) {
      setState(() {
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

    if (response.text != null) {
      apiResponse = await ApiService.post('chat', {
        'chatSessionId': widget.chatSessionId,
        'chatName': chatName,
        'userId': userId,
        'message': response.text,
        'role': 'model',
      });
      if (apiResponse.statusCode >= 200 && apiResponse.statusCode < 300) {
        setState(() {
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
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatHistoryScreen(userId: userId),
                ),
              );
            },
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      drawer: const NavDrawer(selectedIndex: 0),
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
                                  child: const Icon(Icons.arrow_downward),
                                  mini: true,
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
  const ChatBubble({Key? key, required this.message}) : super(key: key);

  void _copyToClipboard(BuildContext context, String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Copied to clipboard")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to copy: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == "user";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
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
                  color: isUser
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: SelectableText(
                  message.text,
                ),
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
