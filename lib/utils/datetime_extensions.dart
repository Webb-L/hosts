/// DateTime 扩展方法
extension DateTimeExtensions on DateTime {
  /// 格式化最后见到时间
  String formatLastSeen() {
    final now = DateTime.now();
    final difference = now.difference(this);
    
    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '$month/$day';
    }
  }
}