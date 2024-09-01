import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:chatview/chatview.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:test1/backend/firebase_tools.dart';
import 'package:test1/colors.dart';
import 'package:test1/initializer_widget.dart';
import 'package:test1/models/user.dart';
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
  final UserModel userData;

  const ChatPage({Key? key, required this.userData}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late Future<UserModel> matchData;

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
          ? widget.userData.uid
          : widget.userData.astroData.matchUid,
      replyTo: (replyMessage.replyTo == '1')
          ? widget.userData.uid
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
      "sendBy": widget.userData.uid,
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
                sendBy: (e.value['sendBy'] == widget.userData.uid) ? '1' : '2',
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
      // print(data['replyMessage']['message_type']);
      if (data['replyMessage']['message_type'] == "MessageType.image") {
        data['replyMessage']['message'] = "Photo ";
      }
      // print(data);
      if (data != null) {
        Message newMessage = Message(
          //id: event.snapshot.key!,
          id: data['id'],
          message: data['message'],
          createdAt: DateTime.parse(data['createdAt']),
          sendBy: (data['sendBy'] == widget.userData.uid) ? '1' : '2',
          messageType: getMessageTypeFromJson(data['messageType']),
          //replyMessage: ReplyMessage.fromJson(data['replyMessage']),
          replyMessage: ReplyMessage(
            messageId: data['replyMessage']['id'],
            message: data['replyMessage']['message'],
            messageType: getMessageTypeFromJson(data[
                'messageType']), // TODO: ASSUMING ONLY TEXT REPLIES!! HOW TO INFER MessageType from json?? if-else??
            replyBy: (data['replyMessage']['replyBy'] == widget.userData.uid)
                ? "1"
                : "2",
            replyTo: (data['replyMessage']['replyTo'] == widget.userData.uid)
                ? "1"
                : "2",
          ),
          status: MessageStatus.delivered,
        );

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
    matchData = backendFirebaseGetUserData(widget.userData.astroData.matchUid);
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
        backgroundColor: bgcolor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 10),
          child: SafeArea(
            child: FutureBuilder<UserModel>(
              future: matchData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return AppBar(
                    backgroundColor: Colors.transparent,
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: yelloww.withOpacity(0.5),
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
                    title: GestureDetector(
                      onTap: () {
                        _showUserInfoBottomSheet(context, snapshot.data!);
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage:
                                NetworkImage(snapshot.data!.photoUrl),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  snapshot.data!.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: yelloww,
                                    fontFamily: "Manrope",
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '@${snapshot.data!.handle}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: greyy.withOpacity(0.7),
                                    fontFamily: "Manrope",
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(2.0),
                      child: Container(
                        color: yelloww,
                        height: 2.0,
                      ),
                    ),
                    toolbarHeight: kToolbarHeight + 20,
                  );
                } else {
                  return AppBar(
                    backgroundColor: bgcolor,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: yelloww),
                      onPressed: () {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) =>
                                const NavigationHome(initialIndex: 0),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                    title: const Text(
                      "",
                      style: TextStyle(color: yelloww, fontFamily: 'Manrope'),
                    ),
                    toolbarHeight: kToolbarHeight + 10,
                  );
                }
              },
            ),
          ),
        ),
        body: Center(
          child: FutureBuilder<UserModel>(
            future: matchData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  //return Text("Chatting with ${snapshot.data!.name}");
                  return ChatView(
                    currentUser: ChatUser(
                      id: '1',
                      name: 'Flutter',
                      //profilePhoto: snapshot.data!.photoUrl,
                    ),
                    chatController: _chatController,
                    onSendTap: _onSendTap,
                    chatViewState: ChatViewState
                        .hasMessages, // Add this state once data is available.
                    featureActiveConfig: const FeatureActiveConfig(
                      enableSwipeToSeeTime: true,
                    ),
                    chatBackgroundConfig: const ChatBackgroundConfiguration(
                      backgroundColor: bgcolor,
                      // backgroundColor: whitee, // light
                      messageTimeTextStyle: TextStyle(
                        color: yelloww,
                      ),
                    ),
                    profileCircleConfig: const ProfileCircleConfiguration(
                      // profileImageUrl: snapshot.data!.photoUrl,
                      circleRadius: 0.0,
                      bottomPadding: 0.0,
                    ),
                    repliedMessageConfig: RepliedMessageConfiguration(
                      repliedMsgAutoScrollConfig:
                          const RepliedMsgAutoScrollConfig(
                        enableHighlightRepliedMsg: true,
                        highlightColor: yelloww,
                        highlightScale: 1.1,
                      ),
                      verticalBarColor: yelloww,
                      backgroundColor: yelloww.withOpacity(0.7),
                    ),
                    sendMessageConfig: const SendMessageConfiguration(
                      textFieldBackgroundColor: tile_color,
                      // textFieldBackgroundColor: bgcolor, // light
                      textFieldConfig: TextFieldConfiguration(
                        hintText: 'Go for it',
                        hintStyle: TextStyle(
                          fontFamily: 'Manrope',
                          color: Colors.grey,
                        ),
                        textStyle: TextStyle(
                          fontFamily: 'Manrope',
                          color: whitee,
                        ),
                      ),
                      sendButtonIcon: Icon(
                        Icons.send,
                        color: yelloww,
                      ),
                      allowRecordingVoice: false,
                      imagePickerIconsConfig: ImagePickerIconsConfiguration(
                        cameraIconColor: yelloww,
                        galleryIconColor: yelloww,
                      ),
                    ),
                    chatBubbleConfig: const ChatBubbleConfiguration(
                      // margin: EdgeInsets.all(0),
                      inComingChatBubbleConfig: ChatBubble(
                        color: yelloww,
                        // color: bgcolor, // light
                        textStyle: TextStyle(
                          color: bgcolor,
                          // color: whitee, // light
                          fontFamily: 'Manrope',
                        ),
                        // margin: EdgeInsets.all(0),
                      ),
                      outgoingChatBubbleConfig: ChatBubble(
                        color: tile_color,
                        // color: bgcolor, // light
                        textStyle: TextStyle(
                          color: whitee,
                          // color: whitee, // light
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    replyPopupConfig: const ReplyPopupConfiguration(
                      buttonTextStyle: TextStyle(
                        color: yelloww,
                      ),
                      backgroundColor: yelloww,
                    ),
                    reactionPopupConfig: null,
                    // messageConfig: MessageConfiguration(),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "The stars say you're never gonna find love. Just kidding, check your internet connection lmao.",
                      style: TextStyle(color: whitee, fontFamily: 'Manrope'),
                    ),
                  );
                }
              }
              return LoadingWidget();
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

  void _showUserInfoBottomSheet(BuildContext context, UserModel userData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: offwhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                controller: controller,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Text(
                      "The stars have spoken",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Playwrite_HU',
                        color: bgcolor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(userData.photoUrl),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userData.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Manrope',
                        color: bgcolor,
                      ),
                    ),
                    Text(
                      "@${userData.handle}",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Manrope',
                        color: bgcolor.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Divider(color: bgcolor.withOpacity(0.2), thickness: 1),
                    const SizedBox(height: 24),
                    _buildInfoRow(Icons.cake, "Birthday",
                        _formatDate(userData.dateOfBirth)),
                    _buildInfoRowWithZodiac(Icons.wb_sunny, "Sun Sign",
                        userData.astroData.planetSigns["sun"] ?? "Unknown"),
                    _buildInfoRowWithZodiac(Icons.nightlight_round, "Moon Sign",
                        userData.astroData.planetSigns["moon"] ?? "Unknown"),
                    _buildInfoRowWithZodiac(
                        Icons.arrow_upward,
                        "Ascendant",
                        userData.astroData.planetSigns["ascendant"] ??
                            "Unknown"),
                    _buildInfoRow(
                        Icons.location_on, "Born in", userData.placeOfBirth),
                    // Add more details as needed
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: bgcolor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    color: bgcolor.withOpacity(0.8),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 16,
                    color: bgcolor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowWithZodiac(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          Icon(icon, color: bgcolor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    color: bgcolor.withOpacity(0.8),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        color: bgcolor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Image.asset(
                      'assets/icons/${value.toLowerCase()}-icon.png',
                      width: 20,
                      height: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildInfoRow(IconData icon, String label, String value) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 10),
  //     child: Row(
  //       children: [
  //         Icon(icon, color: bgcolor, size: 24),
  //         SizedBox(width: 16),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 label,
  //                 style: TextStyle(
  //                   fontWeight: FontWeight.bold,
  //                   fontFamily: 'Manrope',
  //                   fontSize: 14,
  //                   color: bgcolor.withOpacity(0.8),
  //                 ),
  //               ),
  //               Text(
  //                 value,
  //                 style: TextStyle(
  //                   fontFamily: 'Manrope',
  //                   fontSize: 16,
  //                   color: bgcolor,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return "${date.day} ${_getMonthName(date.month)} ${date.year}";
  }

  String _getMonthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[month - 1];
  }
}

class LoadingWidget extends StatefulWidget {
  @override
  _LoadingWidgetState createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget> {
  bool _showConnectivityWarning = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showConnectivityWarning = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgcolor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: whitee),
            const SizedBox(height: 20),
            Text(
              _showConnectivityWarning
                  ? "Yo check yo wifi"
                  : "Listening to the stars...",
              style: const TextStyle(
                color: whitee,
                fontSize: 18,
                fontFamily: 'Manrope',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
