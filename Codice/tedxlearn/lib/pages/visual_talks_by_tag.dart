import 'package:flutter/material.dart';
import 'package:tedxlearn/models/talk.dart';
import 'package:tedxlearn/pages/video_details.dart';
import 'package:tedxlearn/repository/talk_repository.dart';
import 'package:tedxlearn/styles/stile.dart';

class VisualTalks extends StatefulWidget {
  final List<Talk> listaTalk;
  final String tag;

  const VisualTalks({
    super.key,
    required this.listaTalk,
    required this.tag,
  });

  @override
  State<StatefulWidget> createState() => _VisualTalksState();
}

class _VisualTalksState extends State<VisualTalks> {
  final ScrollController scrollController = ScrollController();
  bool altriTalk = false;
  List<Talk> listaTalk = [];
  int paginaCaricamento = 2;

  @override
  void initState() {
    super.initState();
    listaTalk = widget.listaTalk;
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (scrollController.position.extentAfter < 500 && !altriTalk) {
      _loadMoreTalks();
    }
  }

  Future<void> _loadMoreTalks() async {
    setState(() {
      altriTalk = true;
    });

    try {
      List<Talk> talks = await getTalksByTag(widget.tag, paginaCaricamento);
      setState(() {
        listaTalk.addAll(talks);
        paginaCaricamento++;
      });
    } catch (error) {
      throw Exception('Failed to load talks');
    } finally {
      setState(() {
        altriTalk = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      itemCount: listaTalk.length + (altriTalk ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == listaTalk.length) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 70, 168, 255).withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: const Icon(Icons.play_circle_fill, color: Colors.red, size: DimApp.dimIcon),
            title: Text(
              listaTalk[index].title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Text(
              listaTalk[index].mainSpeaker,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => VideoDetails(talk: listaTalk[index]),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
