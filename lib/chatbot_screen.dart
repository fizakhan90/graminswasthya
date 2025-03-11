import 'package:flutter/material.dart';
import 'dart:async';

class ChatbotScreen extends StatefulWidget {
  final String patientName;
  final String patientLanguage;

  const ChatbotScreen({
    Key? key,
    required this.patientName,
    required this.patientLanguage,
  }) : super(key: key);

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isRecording = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addBotMessage("Hi ${widget.patientName}, how can I help you today? I'll respond in ${widget.patientLanguage}.");
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUserMessage: false,
          timestamp: DateTime.now(),
        ),
      );
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUserMessage: true,
          timestamp: DateTime.now(),
        ),
      );
    });
    _messageController.clear();
    _scrollToBottom();

    setState(() {
      _isLoading = true;
    });

    Timer(const Duration(seconds: 1), () {
      _processUserMessage(text);
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    });
  }

  void _processUserMessage(String message) {
    String lowerMessage = message.toLowerCase();
    String response = "";

    if (lowerMessage.contains("hello") || lowerMessage.contains("hi")) {
      response = "Hello there! How are you feeling today?";
    } else if (lowerMessage.contains("pain") || lowerMessage.contains("hurt")) {
      response = "I'm sorry to hear you're in pain. Could you tell me more about where it hurts and when it started?";
    } else if (lowerMessage.contains("fever") || lowerMessage.contains("temperature")) {
      response = "Fever can be a sign of infection. Have you taken your temperature? Any other symptoms like headache or body aches?";
    } else if (lowerMessage.contains("medicine") || lowerMessage.contains("medication")) {
      response = "Are you currently taking any medications? It's important that I know to avoid any potential interactions.";
    } else if (lowerMessage.contains("thank")) {
      response = "You're welcome! Is there anything else I can help you with?";
    } else {
      response = "I understand. Could you provide more details so I can better assist you?";
    }

    if (widget.patientLanguage != "English") {
      response += "\n\n(This would be translated to ${widget.patientLanguage} in a production environment)";
    }

    _addBotMessage(response);
  }

  void _handleVoiceInput() {
    if (_isRecording) {
      setState(() {
        _isRecording = false;
      });
      _addUserMessage("This is a simulated voice message.");
    } else {
      setState(() {
        _isRecording = true;
      });

      Timer(const Duration(seconds: 3), () {
        if (_isRecording) {
          _handleVoiceInput(); // Simulate voice stop after 3s
        }
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Timer(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: message.isUserMessage ? Colors.teal[100] : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: message.isUserMessage ? const Radius.circular(16) : const Radius.circular(0),
            bottomRight: message.isUserMessage ? const Radius.circular(0) : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              "${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}",
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.patientName, style: const TextStyle(fontSize: 18)),
            Text("Language: ${widget.patientLanguage}", style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("About This Chatbot"),
                  content: Text(
                    "This medical assistant chatbot can understand and respond in ${widget.patientLanguage}. "
                    "You can type messages or use voice input to communicate.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text("Start your conversation", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
                  ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.teal[300]),
                  ),
                  const SizedBox(width: 16),
                  Text("Processing...", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                ],
              ),
            ),
          if (_isRecording)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.red.shade50,
              child: Row(
                children: [
                  Icon(Icons.mic, color: Colors.red[400], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text("Recording... Speak now", style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.w500)),
                  ),
                  Text("Tap mic to stop", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(_isRecording ? Icons.stop : Icons.mic, color: _isRecording ? Colors.red : Colors.grey[700]),
                    onPressed: _handleVoiceInput,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (value) => _addUserMessage(value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _addUserMessage(_messageController.text),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(Icons.send, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUserMessage;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUserMessage,
    required this.timestamp,
  });
}
