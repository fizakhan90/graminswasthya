import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class ChatbotScreen extends StatefulWidget {
  final String patientName;
  final String patientLanguage;

  const ChatbotScreen({
    super.key,
    required this.patientName,
    required this.patientLanguage,
  });

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isRecording = false;
  bool _isLoading = false;
  
  // Voice related variables
  late FlutterTts _flutterTts;
  late stt.SpeechToText _speech;
  bool _speechEnabled = false;
  String _recognizedText = '';
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _initializeStt();
    _requestPermissions();
    
    // Add first bot message
    _addBotMessage("Hi ${widget.patientName}, how can I help you today? I'll respond in ${widget.patientLanguage}.");
  }
  
  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
  
  Future<String> _translateOffline(String text) async {
  // Map your patient language to ML Kit's TranslateLanguage.
  TranslateLanguage sourceLang;
  switch (widget.patientLanguage) {
    case 'Hindi':
      sourceLang = TranslateLanguage.hindi;
      break;
    case 'Spanish':
      sourceLang = TranslateLanguage.spanish;
      break;
    case 'French':
      sourceLang = TranslateLanguage.french;
      break;
    // Add more cases as needed.
    default:
      sourceLang = TranslateLanguage.english;
  }
  
  // Create the translator with the source language and English as the target.
  final translator = OnDeviceTranslator(
    sourceLanguage: sourceLang,
    targetLanguage: TranslateLanguage.english,
  );
  
  // Ensure the translation model is downloaded.
  //await translator.downloadModelIfNeeded();

  String translatedText = "";
  try {
    translatedText = await translator.translateText(text);
  } catch (e) {
    print("Translation error: $e");
    // Fallback to the original text if translation fails.
    translatedText = text;
  }
  
  // Free up resources.
  translator.close();
  
  return translatedText;
}


  // Initialize Text-to-Speech
  Future<void> _initializeTts() async {
    _flutterTts = FlutterTts();
    
    // Configure TTS settings
    await _flutterTts.setLanguage(_getLanguageCode(widget.patientLanguage));
    await _flutterTts.setSpeechRate(0.5);  // Speed of speech
    await _flutterTts.setVolume(1.0);      // Volume of speech
    await _flutterTts.setPitch(1.0);       // Pitch of speech
    
    // Set callback for speech completion
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
  }
  
  // Initialize Speech-to-Text
  Future<void> _initializeStt() async {
    _speech = stt.SpeechToText();
    _speechEnabled = await _speech.initialize(
      onError: (error) => print('Speech recognition error: $error'),
      onStatus: (status) => print('Speech recognition status: $status'),
    );
  }
  
  // Request necessary permissions
  Future<void> _requestPermissions() async {
    await Permission.microphone.request();
    await Permission.bluetoothConnect.request();
  }
  
  // Convert language name to language code for TTS
  String _getLanguageCode(String language) {
    switch (language) {
      case 'English': return 'en-US';
      case 'Spanish': return 'es-ES';
      case 'French': return 'fr-FR';
      case 'German': return 'de-DE';
      case 'Mandarin': return 'zh-CN';
      case 'Hindi': return 'hi-IN';
      case 'Arabic': return 'ar-SA';
      default: return 'en-US';
    }
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
    
    // Speak the message if it's from the bot
    _speakMessage(text);
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

  // Generate response based on user input
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

  // Translate the response based on patient language
  String translatedResponse = response;
  if (widget.patientLanguage == "Hindi") {
    translatedResponse = _translateToHindi(response);
  } else if (widget.patientLanguage != "English") {
    // For other languages, we'd add more translation methods
    // For now, just add the note for display
    translatedResponse = response;
  }

  // Display translated text with note for non-production environment
  String displayResponse = translatedResponse;
  if (widget.patientLanguage != "English") {
    displayResponse = translatedResponse;
  }

  _addBotMessage(displayResponse);
}

// Simple translation function for demo purposes
// In a real app, you would use a translation API or service
String _translateToHindi(String englishText) {
  // Basic translation map for common phrases
  final Map<String, String> translations = {
    "Hello there! How are you feeling today?": 
      "नमस्ते! आज आप कैसा महसूस कर रहे हैं?",
    
    "I'm sorry to hear you're in pain. Could you tell me more about where it hurts and when it started?": 
      "मुझे दुख है कि आपको दर्द हो रहा है। क्या आप मुझे बता सकते हैं कि यह कहां दर्द होता है और कब शुरू हुआ था?",
    
    "Fever can be a sign of infection. Have you taken your temperature? Any other symptoms like headache or body aches?": 
      "बुखार संक्रमण का संकेत हो सकता है। क्या आपने अपना तापमान लिया है? सिरदर्द या शरीर में दर्द जैसे कोई अन्य लक्षण?",
    
    "Are you currently taking any medications? It's important that I know to avoid any potential interactions.": 
      "क्या आप वर्तमान में कोई दवाएं ले रहे हैं? किसी भी संभावित प्रतिक्रिया से बचने के लिए मेरा जानना जरूरी है।",
    
    "You're welcome! Is there anything else I can help you with?": 
      "आपका स्वागत है! क्या कोई और चीज़ है जिसमें मैं आपकी मदद कर सकता हूँ?",
    
    "I understand. Could you provide more details so I can better assist you?": 
      "मैं समझता हूँ। क्या आप अधिक विवरण प्रदान कर सकते हैं ताकि मैं आपकी बेहतर सहायता कर सकूं?"
  };

  // Return translation if available, otherwise return original text
  return translations[englishText] ?? englishText;
}



  // Text-to-Speech: Convert bot messages to speech
Future<void> _speakMessage(String message) async {
  // Don't speak the translation note
  String textToSpeak = message;
  if (message.contains("\n\n")) {
    textToSpeak = message.split("\n\n")[0]; // Get only the content before the note
  }
  
  // Stop any ongoing speech
  if (_isSpeaking) {
    await _flutterTts.stop();
  }
  
  setState(() {
    _isSpeaking = true;
  });
  
  await _flutterTts.speak(textToSpeak);
}
  
  // Speech-to
  void _handleVoiceInput() async {
  if (_isRecording) {
    _speech.stop();
    setState(() {
      _isRecording = false;
    });
    
    if (_recognizedText.isNotEmpty) {
      String textToProcess = _recognizedText;
      // Only translate if the patient's language isn't already English.
      if (widget.patientLanguage != "English") {
        textToProcess = await _translateOffline(_recognizedText);
      }
      _addUserMessage(textToProcess);
      _recognizedText = '';
    }
  } else {
    if (_speechEnabled) {
      setState(() {
        _isRecording = true;
        _recognizedText = '';
      });
      
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
          });
        },
        listenFor: const Duration(seconds: 30),
        localeId: _getLanguageCode(widget.patientLanguage),
        cancelOnError: true,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition is not available on this device'),
        ),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.patientName,
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              "Language: ${widget.patientLanguage}",
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          // TTS control button
          IconButton(
            icon: Icon(
              _isSpeaking ? Icons.volume_off : Icons.volume_up,
              color: _isSpeaking ? Colors.teal : null,
            ),
            onPressed: () {
              if (_isSpeaking) {
                _flutterTts.stop();
                setState(() {
                  _isSpeaking = false;
                });
              } else if (_messages.isNotEmpty) {
                // Speak the last bot message
                for (int i = _messages.length - 1; i >= 0; i--) {
                  if (!_messages[i].isUserMessage) {
                    _speakMessage(_messages[i].text);
                    break;
                  }
                }
              }
            },
            tooltip: _isSpeaking ? 'Stop speaking' : 'Speak last message',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("About This Chatbot"),
                  content: Text(
                    "This medical assistant chatbot can understand and respond in ${widget.patientLanguage}. "
                    "You can type messages or use voice input to communicate. "
                    "The chatbot can also speak responses aloud.",
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
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Start your conversation",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageBubble(_messages[index]);
                    },
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
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.teal[300],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "Processing...",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          
          if (_isRecording)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.red.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.mic,
                        color: Colors.red[400],
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Recording... Speak now",
                          style: TextStyle(
                            color: Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        "Tap microphone to stop",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (_recognizedText.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 32),
                      child: Text(
                        "\"$_recognizedText\"",
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
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
                    icon: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: _isRecording ? Colors.red : Colors.grey[700],
                    ),
                    onPressed: _handleVoiceInput,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (value) {
                        _addUserMessage(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      _addUserMessage(_messageController.text);
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
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

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUserMessage;
    final bubbleColor = isUser ? Colors.teal.shade600 : Colors.grey.shade200;
    final textColor = isUser ? Colors.white : Colors.black87;
    final alignment = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleBorderRadius = isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isUser) 
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: CircleAvatar(
                    backgroundColor: Colors.teal.shade100,
                    radius: 16,
                    child: Icon(
                      Icons.medical_services,
                      size: 16,
                      color: Colors.teal.shade700,
                    ),
                  ),
                ),
              Flexible(
                child: GestureDetector(
                  onTap: !isUser ? () {
                    // Speak the message when tapped (only for bot messages)
                    _speakMessage(message.text);
                  } : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    margin: EdgeInsets.only(
                      left: isUser ? 60 : 0,
                      right: isUser ? 0 : 60,
                    ),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: bubbleBorderRadius,
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
              if (isUser)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: CircleAvatar(
                    backgroundColor: Colors.teal.shade700,
                    radius: 16,
                    child: const Icon(
                      Icons.person,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
            child: Text(
              _formatTimestamp(message.timestamp),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
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