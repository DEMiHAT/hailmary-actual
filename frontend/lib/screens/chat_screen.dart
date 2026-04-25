import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import 'emergency_screen.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String type; // 'text', 'data', 'action'

  ChatMessage({required this.text, required this.isUser, this.type = 'text'});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hello! I am HailMary, your personal medical assistant. I can answer FAQs, check your TPS score, monitor your medications, or trigger emergency protocols.",
      isUser: false,
    ),
  ];
  bool _isTyping = false;

  void _sendMessage(String userText) async {
    setState(() {
      _messages.add(ChatMessage(text: userText, isUser: true));
      _isTyping = true;
    });
    
    _scrollToBottom();

    // Call Backend API
    try {
      // NOTE: Use 10.0.2.2 for Android Emulator connecting to localhost backend
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/chat/message'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"message": userText, "user_id": "patient_001"}),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _handleBotResponse(data['type'], data['content']);
      } else {
        _fallbackMatch(userText);
      }
    } catch (e) {
      // Fallback for demo if backend is offline
      _fallbackMatch(userText);
    }
  }

  void _handleBotResponse(String type, String content) {
    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(text: content, isUser: false, type: type));
    });
    _scrollToBottom();

    if (type == 'action') {
      // Handle explicit triggers via UI
      Future.delayed(const Duration(milliseconds: 800), () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyScreen()));
      });
    }
  }

  // Purely rule-based fallback if the python server is offline
  void _fallbackMatch(String text) {
    text = text.toLowerCase();
    String type = 'text';
    String reply = "I'm offline from my main brain. But I can tell you missed a dose yesterday.";
    
    if (text.contains('emergency') || text.contains('panic') || text.contains('help')) {
      reply = "EMERGENCY INITIATED. Local authorities alerted.";
      type = 'action';
    } else if (text.contains('tps') || text.contains('score')) {
      reply = "Your current Treatment Progress Score (TPS) is 85%. Keep it up!";
      type = 'data';
    } else if (text.contains('worker') || text.contains('asha')) {
      reply = "Your ASHA worker is Lakshmi Devi covering Bangalore South.";
      type = 'data';
    } else if (text.contains('tb') || text.contains('tuberculosis')) {
      reply = "Tuberculosis is completely curable if you follow the 6-9 month strict medicine track.";
    }

    _handleBotResponse(type, reply);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppColors.info.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(Icons.smart_toy_rounded, color: AppColors.info, size: 20),
            ),
            const SizedBox(width: 12),
            Text('Ask HailMary', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 80), // Padding for nav
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    return _buildTypingIndicator();
                  }
                  return _buildMessage(_messages[index]);
                },
              ),
            ),
            _buildQuickActionMenu(),
            const SizedBox(height: 100), // Avoid CustomBottomNav overlap
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    bool isDanger = message.type == 'action';
    bool isData = message.type == 'data';
    
    Color bubbleColor = message.isUser ? AppColors.textPrimary : Colors.white;
    if (!message.isUser && isDanger) bubbleColor = AppColors.emergency.withOpacity(0.15);
    if (!message.isUser && isData) bubbleColor = AppColors.safe.withOpacity(0.15);
    
    Color textColor = message.isUser ? Colors.white : AppColors.textSecondary;
    if (!message.isUser && isDanger) textColor = AppColors.emergency;
    if (!message.isUser && isData) textColor = AppColors.safe;

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(message.isUser ? 20 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 20),
          ),
          boxShadow: !message.isUser ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, spreadRadius: 1)] : [],
        ),
        child: Text(
          message.text,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: !message.isUser ? FontWeight.w500 : FontWeight.w400,
            color: textColor,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomRight: Radius.circular(20), bottomLeft: Radius.circular(4),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dot(), const SizedBox(width: 4), _dot(), const SizedBox(width: 4), _dot()
          ],
        ),
      ),
    );
  }

  Widget _dot() {
    return Container(width: 6, height: 6, decoration: BoxDecoration(color: AppColors.divider, shape: BoxShape.circle));
  }

  Widget _buildQuickActionMenu() {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text('Quick Actions', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.textTertiary)),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _actionChip(Icons.speed_rounded, 'Check TPS Score', 'what is my tps score', AppColors.safe),
                _actionChip(Icons.medical_services_rounded, 'Emergency Alert', 'trigger emergency', AppColors.emergency),
                _actionChip(Icons.person_search_rounded, 'Find ASHA Worker', 'who is my asha worker', AppColors.info),
                _actionChip(Icons.medication_rounded, 'Medication Check', 'did i miss my pills', AppColors.warning),
                _actionChip(Icons.help_outline_rounded, 'What is TB?', 'what is tb', AppColors.textPrimary),
                _actionChip(Icons.restaurant_rounded, 'Dietary Help', 'what should i eat', AppColors.textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionChip(IconData icon, String label, String query, Color color) {
    return GestureDetector(
      onTap: () => _sendMessage(query),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}
