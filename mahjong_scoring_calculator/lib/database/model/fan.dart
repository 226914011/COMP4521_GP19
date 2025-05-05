class Fan {
  final int? fanId;
  final String fanName;
  final int fanValue;

  Fan({
    this.fanId,
    required this.fanName,
    required this.fanValue,
  });

  Map<String, dynamic> toMap() => {
    'fan_id': fanId,
    'fan_name': fanName,
    'fan_value': fanValue,
  };

  factory Fan.fromMap(Map<String, dynamic> map) => Fan(
    fanId: map['fan_id'],
    fanName: map['fan_name'],
    fanValue: map['fan_value'],
  );
}