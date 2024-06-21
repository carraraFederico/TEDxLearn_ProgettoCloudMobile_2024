class Tag {
  final String nome;

  Tag({required this.nome});

  factory Tag.fromJSON(Map<String, dynamic> json) {
    return Tag(nome: json['_id']);
  }
}
