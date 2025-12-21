import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }
  
  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }
  
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM d, y \'at\' h:mm a').format(date);
  }
  
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} mins ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return formatDate(date);
    }
  }
  
  static DateTime? parseISOString(String? isoString) {
    if (isoString == null) return null;
    try {
      return DateTime.parse(isoString);
    } catch (e) {
      return null;
    }
  }
}
