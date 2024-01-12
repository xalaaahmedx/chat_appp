import 'package:chat_appp/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});
  

  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('chat')
            .orderBy(
              'createdAt',
              descending: true,
            )
            .snapshots(),
        builder: (ctx, chatSnapshots) {
          if (chatSnapshots.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
            return const Center(
              child: Text('An error occured'),
            );
          }

          if (chatSnapshots.hasError) {
            return const Center(
              child: Text('An error occured'),
            );
          }
          final chatDocs = chatSnapshots.data!.docs;
          return ListView.builder(
              reverse: true,
              padding: EdgeInsets.only(bottom: 40, left: 13, right: 13),
              itemCount: chatDocs.length,
              itemBuilder: (ctx, index) {
                final chat = chatDocs[index].data();

                final nextChatMessage = index + 1 < chatDocs.length
                    ? chatDocs[index + 1].data()
                    : null;
                final currentMessageUsernameId = chat['userId'];
                final nextMessageUsernameId =
                    nextChatMessage != null ? nextChatMessage['userId'] : null;

                final nextUserIsSame =
                    nextMessageUsernameId == currentMessageUsernameId;

                if (nextUserIsSame) {
                  return MessageBubble.next(
                      message: chat['text'],
                      isMe: authUser.uid == currentMessageUsernameId);
                } else {
                  return MessageBubble.first(
                    userImage: chat['userImage'],
                    username: chat['username'],
                    message: chat['text'],
                    isMe: authUser.uid == nextMessageUsernameId,
                  );
                }
              });
        });
  }
}
