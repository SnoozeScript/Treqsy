import 'package:flutter/material.dart';

class StreamOverviewScreen extends StatelessWidget {
  const StreamOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Video player section
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.black,
              child: const Center(
                child: Icon(Icons.videocam, color: Colors.white, size: 100),
              ),
            ),
          ),
          // Chat section
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[200],
              child: Column(
                children: [
                  const Expanded(
                    child: Center(
                      child: Text('Chat messages will appear here.'),
                    ),
                  ),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Send a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 