class Talk {
  final String id;
  final String title;
  final String details;
  final String mainSpeaker;
  final String url;

  Talk.fromJSON(Map<String, dynamic> jsonMap) :
    id = jsonMap['_id'],
    title = jsonMap['title'],
    details = jsonMap['description'],
    mainSpeaker = (jsonMap['speakers'] ?? ""),
    url = (jsonMap['url'] ?? "");
}