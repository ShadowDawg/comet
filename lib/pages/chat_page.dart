import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:chatview/chatview.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:test1/backend/firebase_tools.dart';
import 'package:test1/colors.dart';
import 'package:test1/initializer_widget.dart';
import 'package:test1/models/user_and_astro_data.dart';
// import 'package:chatview/chatview.dart';
// import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
// import 'package:flutter_chat_ui/flutter_chat_ui.dart';

// For the testing purposes, you should probably use https://pub.dev/packages/uuid.
String randomString() {
  final random = Random.secure();
  final values = List<int>.generate(16, (i) => random.nextInt(255));
  return base64UrlEncode(values);
}

class ChatPage extends StatefulWidget {
  final UserAndAstroData userData;

  const ChatPage({Key? key, required this.userData}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late Future<UserAndAstroData> matchData;

  late DatabaseReference messagesRef;

  // Stream subscription for Firebase updates
  StreamSubscription<DatabaseEvent>? _messageSubscription;

  // ========= Chat stuff===========

  List<Message> messageList = [
    // Message(
    //   id: '1',
    //   message: "Hi",
    //   createdAt: DateTime(2017, 9, 7, 17, 30),
    //   sendBy: "1",
    // ),
    // Message(
    //   id: '2',
    //   message: "Hello",
    //   createdAt: DateTime(2017, 9, 7, 17, 30),
    //   sendBy: "2",
    // ),
  ];

  // late final _chatController = ChatController(
  //   initialMessageList: messageList,
  //   scrollController: ScrollController(),
  //   chatUsers: [ChatUser(id: '2', name: '')],
  // );
  late ChatController _chatController;

  void _onSendTap(
    String message,
    ReplyMessage replyMessage,
    MessageType messageType,
  ) {
    print(messageType);

    // Push locally [ONLY PUSH TO DB, NOT LOCAL, Implications??]
    //_chatController.addMessage(userMessageLocal);

    // change userMessage sendBy to currentUser.uid before pushing to FB!!!
    // TODO: ONLY SENDING TO DATABASE CURRENTLY, NOT LOCALLY, see notion.
    // pushing to FB

    var editedReplyMessage = ReplyMessage(
      replyBy: (replyMessage.replyBy == '1')
          ? widget.userData.user.uid
          : widget.userData.astroData.matchUid,
      replyTo: (replyMessage.replyTo == '1')
          ? widget.userData.user.uid
          : widget.userData.astroData.matchUid,
      messageId: replyMessage.messageId,
      messageType: replyMessage.messageType,
      voiceMessageDuration: replyMessage.voiceMessageDuration,
      message: replyMessage.message,
    );

    var key = messagesRef.push().key;

    // editing replied by info to reflect uid's correctly

    print(editedReplyMessage.toJson());
    var userMessageDatabaseJson = {
      "id": DateTime.now().toString(),
      "message": message,
      "createdAt": DateTime.now().toString(),
      "sendBy": widget.userData.user.uid,
      "replyMessage": editedReplyMessage.toFirebaseJson(),
      "messageType": messageType.toString(),
    };

    // crashes while sending, doesnt send
    // var userMessageDatabaseJson = userMessageDatabase.toJson();

    print(message);
    messagesRef.child(key!).set(userMessageDatabaseJson);

    // Future.delayed(const Duration(milliseconds: 300), () {
    //   _chatController.initialMessageList.last.setStatus =
    //       MessageStatus.undelivered;
    // });
    // Future.delayed(const Duration(seconds: 1), () {
    //   _chatController.initialMessageList.last.setStatus = MessageStatus.read;
    // });
  }

  // Not being used
  Future<void> loadInitialMessages() async {
    DatabaseEvent snapshot = await messagesRef.orderByChild('createdAt').once();
    final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;
    print(data);
    var initialMessages = <Message>[];
    if (data != null) {
      initialMessages = data.entries
          .map((e) => Message(
                id: "e.key",
                message: e.value['message'],
                createdAt: DateTime.parse(e.value['createdAt']),
                sendBy:
                    (e.value['sendBy'] == widget.userData.user.uid) ? '1' : '2',
              ))
          .toList();
    }
    if (mounted) {
      setState(() {
        messageList = initialMessages;
        print(messageList[0].sendBy);
        _chatController = ChatController(
          initialMessageList: messageList,
          scrollController: ScrollController(),
          chatUsers: [ChatUser(id: '2', name: '')],
        );
      });
    }
  }

  void listenForMessages() {
    // Attach a listener for child added events on the messages reference
    _messageSubscription = messagesRef
        .orderByChild('createdAt')
        .onChildAdded
        .listen((DatabaseEvent event) {
      // This will be triggered for each individual message as it is added
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      if (data != null) {
        Message newMessage = Message(
            //id: event.snapshot.key!,
            id: data['id'],
            message: data['message'],
            createdAt: DateTime.parse(data['createdAt']),
            sendBy: (data['sendBy'] == widget.userData.user.uid) ? '1' : '2',
            messageType: getMessageTypeFromJson(data['messageType']),
            //replyMessage: ReplyMessage.fromJson(data['replyMessage']),
            replyMessage: ReplyMessage(
              messageId: data['replyMessage']['id'],
              message: data['replyMessage']['message'],
              messageType: getMessageTypeFromJson(data[
                  'messageType']), // TODO: ASSUMING ONLY TEXT REPLIES!! HOW TO INFER MessageType from json?? if-else??
              replyBy:
                  (data['replyMessage']['replyBy'] == widget.userData.user.uid)
                      ? "1"
                      : "2",
              replyTo:
                  (data['replyMessage']['replyTo'] == widget.userData.user.uid)
                      ? "1"
                      : "2",
            ));

        // TODO: Image reply is kinda messed

        if (mounted) {
          setState(() {
            // Add the new message to the message list
            messageList.add(newMessage);
            print("-----ADDING NEW MESSAGE----");
            print(newMessage.message);
            // Update the chat controller with the new message
            // This avoids reinitializing the controller and only appends the new message
            //_chatController.addMessage(newMessage);
          });
        }
      }
    }, onError: (error) {
      // Handle any errors that occur during the subscription
      print("Firebase subscription error: $error");
    });
  }

  MessageType getMessageTypeFromJson(String messageType) {
    if (messageType == "MessageType.text") {
      return MessageType.text;
    } else if (messageType == "MessageType.image") {
      return MessageType.image;
    } else {
      // should never happen but do custom???
      return MessageType.custom;
    }
  }

// ========= Chat stuff===========

  @override
  void initState() {
    super.initState();
    matchData =
        backendFirebaseGetUserAndAstroData(widget.userData.astroData.matchUid);
    // ========= Chat stuff===========
    _chatController = ChatController(
      initialMessageList: messageList,
      scrollController: ScrollController(),
      chatUsers: [ChatUser(id: '2', name: '')],
    );
    messagesRef = FirebaseDatabase.instance
        .ref('chats/${widget.userData.astroData.chatRoomId}/messages');

    //listenForMessages();
    // Load initial messages once
    //loadInitialMessages();
    // loadInitialMessages().then((_) {
    //   // After initial messages are loaded and processed
    //   listenForMessages(); // Start listening for new messages
    // });
    listenForMessages();
    // ========= Chat stuff===========
    // _chatController.setTypingIndicator = true; // for showing indicator
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigate to HomePage when back button is pressed
        // Navigate back to MainNavigation and set the index to 0 (HomePage)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const NavigationHome(
              initialIndex: 0,
            ),
          ),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize:
              const Size.fromHeight(kToolbarHeight + 10), // Increased height
          child: SafeArea(
            child: FutureBuilder<UserAndAstroData>(
              future: matchData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return AppBar(
                    backgroundColor: tile_color,
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: yelloww,
                      ),
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const NavigationHome(
                              initialIndex: 0,
                            ),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                    title: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Scaffold.of(context).openDrawer();
                          },
                          child: CircleAvatar(
                            radius: 20, // Increased from 16 to 20
                            backgroundImage:
                                NetworkImage(snapshot.data!.user.photoUrl),
                          ),
                        ),
                        const SizedBox(width: 12), // Increased from 8 to 12
                        Expanded(
                          child: Text(
                            snapshot.data!.user.name,
                            style: const TextStyle(
                              fontSize: 18,
                              color: yelloww,
                            ), // Increased from 16 to 18
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    toolbarHeight: kToolbarHeight + 10, // Increased height
                  );
                } else {
                  return AppBar(
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const NavigationHome(
                              initialIndex: 0,
                            ),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                    title: const Text("Loading..."),
                    toolbarHeight: kToolbarHeight + 10, // Increased height
                  );
                }
              },
            ),
          ),
        ),
        drawer: FutureBuilder<UserAndAstroData>(
          future: matchData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage:
                                NetworkImage(snapshot.data!.user.photoUrl),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            snapshot.data!.user.name,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.cake),
                      title:
                          Text("Birthday: ${snapshot.data!.user.dateOfBirth}"),
                    ),
                    ListTile(
                      leading: const Icon(Icons.star),
                      title: Text(
                          "Zodiac: ${snapshot.data!.astroData.planetSigns["sun"]}"),
                    ),
                    ListTile(
                      leading: const Icon(Icons.location_on),
                      title:
                          Text("Location: ${snapshot.data!.user.placeOfBirth}"),
                    ),
                    // Add more details as needed
                  ],
                ),
              );
            } else {
              return const Drawer(
                child: Center(child: CircularProgressIndicator()),
              );
            }
          },
        ),
        body: Center(
          child: FutureBuilder<UserAndAstroData>(
            future: matchData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  //return Text("Chatting with ${snapshot.data!.name}");
                  return ChatView(
                    currentUser: ChatUser(id: '1', name: 'Flutter'),
                    chatController: _chatController,
                    onSendTap: _onSendTap,
                    chatViewState: ChatViewState
                        .hasMessages, // Add this state once data is available.
                    featureActiveConfig: const FeatureActiveConfig(
                      enableSwipeToSeeTime: true,
                    ),
                    chatBackgroundConfig: const ChatBackgroundConfiguration(
                      backgroundColor: bgcolor,
                    ),
                    repliedMessageConfig: const RepliedMessageConfiguration(
                      repliedMsgAutoScrollConfig: RepliedMsgAutoScrollConfig(
                        enableHighlightRepliedMsg: true,
                        highlightColor: Colors.grey,
                        highlightScale: 1.1,
                      ),
                    ),
                    sendMessageConfig: SendMessageConfiguration(
                        textFieldBackgroundColor: tile_color,
                        sendButtonIcon: const Icon(
                          Icons.send,
                          color: yelloww,
                        )),
                    chatBubbleConfig: ChatBubbleConfiguration(
                      // outgoingChatBubbleConfig: ChatBubble(
                      //   color: yelloww,
                      //   textStyle: TextStyle(
                      //     color: bgcolor,
                      //   ),
                      // ),
                      // inComingChatBubbleConfig: ChatBubble(
                      //   color: tile_color,
                      // ),
                      inComingChatBubbleConfig: const ChatBubble(
                        color: yelloww,
                        textStyle: TextStyle(
                          color: bgcolor,
                        ),
                      ),
                      outgoingChatBubbleConfig: ChatBubble(
                        color: tile_color,
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Text("Failed to get match details");
                }
              }
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose the stream subscription when the state is disposed
    _messageSubscription?.cancel();
    super.dispose();
  }
}
