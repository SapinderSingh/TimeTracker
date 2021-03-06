import 'package:flutter/material.dart';

class EmptyContent extends StatelessWidget {
  final String title, message;

  const EmptyContent({
    this.title = 'Nothing here',
    this.message = 'Add a new item to get started',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 32,
              color: Colors.black54,
            ),
          ),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
