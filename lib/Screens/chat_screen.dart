// Suggested code may be subject to a license. Learn more: ~LicenseLog:3303233072.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:1278335913.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:2742272502.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:2841764492.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:2355278934.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:1109935166.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:3472812545.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:3088064105.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:2434993103.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:461673573.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:2353292813.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:2551887391.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:3087415640.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:2494737769.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:2881213710.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:265849441.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:1630646666.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:1943980602.
// Suggested code may be subject to a license. Learn more: ~LicenseLog:2573936407.
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [
    ChatMessage(text: "Hello!", isSender: false),
    ChatMessage(text: "Hi there!", isSender: true),
    ChatMessage(text: "How are you?", isSender: false),
    ChatMessage(text: "I'm doing great, thanks!", isSender: true),
  ];

  final TextEditingController _textController = TextEditingController();

  void _handleSubmitted(String text) {
    _textController.clear();
    setState(() {
      _messages.add(ChatMessage(text: text, isSender: true));
    });
  }

  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
       drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
             DrawerHeader(
              decoration: BoxDecoration(
                 color: Theme.of(context).primaryColor,
              ),
              child: Text(
                'Navigation Drawer',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.fitness_center),
              title: const Text('Workout Tutorial'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.fastfood),
              title: const Text('Diet Plan'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ])),
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(message: _messages[_messages.length - 1 - index]);
              },
            ),
          ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
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
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isSender;

  ChatMessage({required this.text, required this.isSender});
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Row(
        mainAxisAlignment: message.isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: message.isSender ? Colors.blue[100] : Colors.grey[200],
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Text(
              message.text,
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }
}
