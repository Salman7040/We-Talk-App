class Message {
  Message({
    required this.msg,
    required this.fromId,
    required this.read,
    required this.toId,
    required this.type,
    required this.sent,
  });
  late String msg;
  late String fromId;
  late String read;
  late String toId;
  late Type type;
  late String sent;

  Message.fromJson(Map<String, dynamic> json){
    msg = json['msg'].toString();
    fromId = json['from_Id'].toString();
    read = json['read'].toString();
    toId = json['to_Id'].toString();
    type = json['type'].toString() == Type.image.name? Type.image : Type.text;
    sent = json['sent'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['msg'] = msg;
    data['from_Id'] = fromId;
    data['read'] = read;
    data['to_Id'] = toId;
    data['type'] = type.name;
    data['sent'] = sent;
    return data;
  }
}

enum Type{text,image}