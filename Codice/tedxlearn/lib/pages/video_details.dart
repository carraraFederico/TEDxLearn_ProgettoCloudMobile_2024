import 'package:flutter/material.dart';
import 'package:tedxlearn/models/talk.dart';
import 'package:tedxlearn/utils/bottom_bar.dart';

class VideoDetails extends StatelessWidget {
  final Talk talk;
  final TextEditingController notesController = TextEditingController();

  VideoDetails({super.key, required this.talk});

  void saveNotes() {
    //String notes = notesController.text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(talk.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                talk.title,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                height: 220,
                color: Colors.black,
                child: const Center(
                  child: Text(
                    'Video Player Placeholder',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Speaker: ${talk.mainSpeaker}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(7.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextField(
                  controller: notesController,
                  maxLines: 12,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Inserisci le tue note qui...',
                    labelText: 'Note',
                    labelStyle: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: saveNotes,
                  child: const Text(
                    'Salva Note',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomBar(
        onHomePressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        onLeaderboardPressed: () {},
        onAccountPressed: () {},
      ),
      resizeToAvoidBottomInset: true,
    );
  }
}
