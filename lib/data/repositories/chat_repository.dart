import '../services/api_service.dart';
import '../models/chat_model.dart';
import '../../core/network/api_response.dart';

class ChatRepository {
  final ApiService _apiService;

  ChatRepository(this._apiService);

  Future<List<ChatModel>> getChats() async {
    final response = await _apiService.getChats();
    
    if (response.success && response.data != null) {
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => ChatModel.fromJson(json)).toList();
    } else {
      throw Exception(response.message ?? 'Failed to load chats');
    }
  }

  Future<List<MessageModel>> getChatHistory(String chatId, int page) async {
    final response = await _apiService.getChatHistory(chatId, page);
    
    if (response.success && response.data != null) {
      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => MessageModel.fromJson(json)).toList();
    } else {
      throw Exception(response.message ?? 'Failed to load chat history');
    }
  }

  Future<MessageModel> sendMessage(Map<String, dynamic> data) async {
    final response = await _apiService.sendMessage(data);
    
    if (response.success && response.data != null) {
      return MessageModel.fromJson(response.data);
    } else {
      throw Exception(response.message ?? 'Failed to send message');
    }
  }
}