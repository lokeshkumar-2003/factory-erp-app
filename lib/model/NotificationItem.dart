class NotificationItem {
  final int id;
  final String title;
  final String message;
  final String createdBy;
  final String date;
  final String status;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.createdBy,
    required this.date,
    required this.status,
  });

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      id: map['ID'] is int
          ? map['ID']
          : int.tryParse(map['ID']?.toString() ?? '0') ?? 0,
      title: map['Title'] ?? '',
      message: map['Message'] ?? '',
      createdBy: map['CreatedBy'] ?? '',
      date: map['CreatedAt']?.toString() ?? '', // Corrected this line
      status: map['Status'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'NotificationID': id,
      'Title': title,
      'Message': message,
      'CreatedBy': createdBy,
      'Date': date,
      'Status': status,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem.fromMap(json);

  @override
  String toString() {
    return 'NotificationItem(id: $id, title: "$title", message: "$message", createdBy: "$createdBy", date: "$date", status: "$status")';
  }
}
