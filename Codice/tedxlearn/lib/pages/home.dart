import 'package:flutter/material.dart';
import 'package:tedxlearn/models/tag.dart';
import 'package:tedxlearn/pages/visual_talks_by_tag.dart';
import 'package:tedxlearn/repository/tag_repository.dart';
import 'package:tedxlearn/utils/bottom_bar.dart';
import 'package:tedxlearn/repository/talk_repository.dart';
import 'package:tedxlearn/models/talk.dart';

class Home extends StatefulWidget {
  const Home({super.key, this.title = 'TEDxLearn'});

  final String title;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  List<Tag> listaTag = [];
  final List<Talk> listaTalk = [];
  int pageTag = 1;
  int pageTalks = 1;
  bool init = true;
  bool altriTag = false;

  @override
  void initState() {
    super.initState();
    _loadInitialTags();
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (scrollController.position.extentAfter < 500 && !altriTag) {
      _loadMoreTags();
    }
  }

  Future<void> _loadInitialTags() async {
    try {
      List<Tag> tags = await getAllTags(pageTag);
      setState(() {
        listaTag.addAll(tags);
        pageTag++;
      });
    } catch (error) {
      throw Exception('Failed to load tags');
    }
  }

  Future<void> _loadMoreTags() async {
    setState(() {
      altriTag = true;
    });

    try {
      List<Tag> tags = await getAllTags(pageTag);
      setState(() {
        listaTag.addAll(tags);
        pageTag++;
      });
    } catch (error) {
      throw Exception('Failed to load tags');
    } finally {
      setState(() {
        altriTag = false;
      });
    }
  }

  Future<void> _getTalksByTag({bool loadMore = false}) async {
    if (!loadMore) {
      listaTalk.clear();
      pageTalks = 1;
    }

    List<Talk> talks = await getTalksByTag(textController.text, pageTalks);

    setState(() {
      listaTalk.addAll(talks);
      init = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TEDxLearn'),
        backgroundColor: const Color.fromARGB(255, 148, 206, 253),
      ),
      body: init
          ? _buildInitialContent()
          : VisualTalks(
              listaTalk: listaTalk,
              tag: textController.text,
            ),
      bottomNavigationBar: BottomBar(
        onHomePressed: () {
          setState(() {
            init = true;
            textController.clear();
          });
        },
        onLeaderboardPressed: () {
          // Azione per il pulsante classifica
        },
        onAccountPressed: () {
          // Azione per il pulsante account
        },
      ),
    );
  }

  Widget _buildInitialContent() {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      hintText: 'Inserisci la categoria',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Ricerca',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => _getTalksByTag(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: listaTag.length + (altriTag ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == listaTag.length && altriTag) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return GestureDetector(
                  onTap: () {
                    textController.text = listaTag[index].nome;
                    _getTalksByTag();
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.label, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          listaTag[index].nome,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
