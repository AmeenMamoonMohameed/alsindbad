import 'package:flutter/material.dart';


import '../models/message.dart';
import '../utils/constants.dart';
import 'chat_view_inherited_widget.dart';
import 'vertical_line.dart';

class QuestionMessageWidget extends StatelessWidget {
  const QuestionMessageWidget({
    Key? key,
    required this.isSender,
    required this.message,
    this.onTap,
  }) : super(key: key);

  final bool isSender;
  final Message message;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final currentUser = ChatViewInheritedWidget.of(context)?.currentUser;
    final textTheme = Theme.of(context).textTheme;
    final questionMessage = message.attachmentMessage;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(
          right: horizontalPadding,
          left: horizontalPadding,
          bottom: 4,
        ),
        constraints: const BoxConstraints(maxWidth: 280),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 6),
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Opacity(
                      opacity: 0.8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  questionMessage!.name,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.25,
                                  ),
                                ),
                                if (questionMessage.description.isNotEmpty)
                                  Text(
                                    questionMessage.description,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      letterSpacing: 0.25,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            height: 100,
                            width: 80,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(questionMessage.image),
                                fit: BoxFit.fill,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const VerticalLine(
                    verticalBarWidth: 2,
                    verticalBarColor: Colors.white,
                    leftPadding: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
