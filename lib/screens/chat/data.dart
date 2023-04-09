import '../../packages/chat/models/message.dart';
import '../../packages/chat/models/reaction.dart';
import '../../packages/chat/models/reply_message.dart';
import '../../packages/chat/values/enumaration.dart';

class Data {
  static const profileImage =
      "https://cdn3.vectorstock.com/i/1000x1000/30/97/flat-business-man-user-profile-avatar-icon-vector-4333097.jpg";
  static final messageList = [
    Message(
      id: '1',
      message: "Hi!",
      createdAt: DateTime.now(),
      sendBy: '1', // userId of who sends the message
      status: Status.delivered,
    ),
    Message(
      id: '2',
      message: "Hi!",
      createdAt: DateTime.now(),
      sendBy: '2',
      status: Status.delivered,
    ),
    Message(
      id: '3',
      message: "We can meet?I am free",
      createdAt: DateTime.now(),
      sendBy: '1',
      status: Status.delivered,
    ),
    Message(
      id: '4',
      message: "Can you write the time and place of the meeting?",
      createdAt: DateTime.now(),
      sendBy: '1',
      status: Status.delivered,
    ),
    Message(
      id: '5',
      message: "That's fine",
      createdAt: DateTime.now(),
      sendBy: '2',
      reaction: Reaction(reactions: ['\u{2764}'], reactedUserIds: ['1']),
      status: Status.delivered,
    ),
    Message(
      id: '6',
      message: "When to go ?",
      createdAt: DateTime.now(),
      sendBy: '3',
      status: Status.delivered,
    ),
    Message(
      id: '7',
      message: "I guess ameen will reply",
      createdAt: DateTime.now(),
      sendBy: '4',
      status: Status.delivered,
    ),
    Message(
      id: '8',
      message: "https://bit.ly/3JHS2Wl",
      createdAt: DateTime.now(),
      sendBy: '2',
      reaction: Reaction(
        reactions: ['\u{2764}', '\u{1F44D}', '\u{1F44D}'],
        reactedUserIds: ['2', '3', '4'],
      ),
      replyMessage: const ReplyMessage(
        message: "Can you write the time and place of the meeting?",
        replyTo: '1',
        replyBy: '2',
        messageId: '4',
      ),
      status: Status.delivered,
    ),
    Message(
      id: '9',
      message: "Done",
      createdAt: DateTime.now(),
      sendBy: '1',
      reaction: Reaction(
        reactions: [
          '\u{2764}',
          '\u{2764}',
          '\u{2764}',
        ],
        reactedUserIds: ['2', '3', '4'],
      ),
      status: Status.delivered,
    ),
    Message(
      id: '10',
      message: "Thank you!!",
      createdAt: DateTime.now(),
      sendBy: '1',
      reaction: Reaction(
        reactions: ['\u{2764}', '\u{2764}', '\u{2764}', '\u{2764}'],
        reactedUserIds: ['2', '4', '3', '1'],
      ),
      status: Status.seen,
    ),
    Message(
      id: '11',
      message: "https://miro.medium.com/max/1000/0*s7of7kWnf9fDg4XM.jpeg",
      createdAt: DateTime.now(),
      messageType: MessageType.image,
      sendBy: '1',
      reaction: Reaction(reactions: ['\u{2764}'], reactedUserIds: ['2']),
      status: Status.delivered,
    ),
    Message(
      id: '12',
      message: "🤩🤩",
      createdAt: DateTime.now(),
      sendBy: '2',
      status: Status.delivered,
    ),
  ];
}
