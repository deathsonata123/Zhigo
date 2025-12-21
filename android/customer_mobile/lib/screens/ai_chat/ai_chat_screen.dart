import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/minimalist_restaurant_card.dart';
import '../../data/dummy_data.dart';
import '../restaurant/restaurant_details_screen.dart';

/// AI Chat Screen - Conversational interface like ChatGPT
/// Simple white background with message bubbles
class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    // Welcome message
    _messages.add(ChatMessage(
      text: 'Hi! What are you craving today? 🍕',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Add user message
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });

    _messageController.clear();
    _scrollToBottom();

    // Simulate AI response with restaurant suggestion
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _messages.add(ChatMessage(
          text: 'I\'ve found a few great options for you:',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        
        // Add restaurant cards as AI response
        _messages.add(ChatMessage(
          text: '',
          isUser: false,
          timestamp: DateTime.now(),
          hasRestaurants: true,
          restaurants: DummyData.dummyRestaurants.take(3).toList(),
        ));
      });
      _scrollToBottom();
    });
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
      backgroundColor: AppColors.baseWhite,
      appBar: AppBar(
        backgroundColor: AppColors.baseWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
          color: AppColors.textPrimary,
        ),
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981), // Green dot
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'AI Assistant',
              style: AppTextStyles.bodyEmphasized.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSpacing.sm),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          
          // Input Field
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: const BoxDecoration(
              color: AppColors.baseWhite,
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'What are you craving?',
                        hintStyle: AppTextStyles.bodyPrimary.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: AppColors.accent, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: AppColors.baseWhite,
                        size: 20,
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
    if (message.hasRestaurants) {
      return _buildRestaurantCarousel(message.restaurants!);
    }

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.accent : AppColors.baseOffWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: AppTextStyles.bodyPrimary.copyWith(
            color: message.isUser ? AppColors.baseWhite : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantCarousel(List<Map<String, dynamic>> restaurants) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: restaurants.length,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        itemBuilder: (context, index) {
          final restaurant = restaurants[index];
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: AppSpacing.sm),
            child: MinimalistRestaurantCard(
              restaurant: restaurant,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => RestaurantDetailsFullScreen(
                      restaurantId: restaurant['id'].toString(),
                      restaurant: restaurant,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool hasRestaurants;
  final List<Map<String, dynamic>>? restaurants;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.hasRestaurants = false,
    this.restaurants,
  });
}
