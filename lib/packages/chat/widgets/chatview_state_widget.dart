import 'package:akarak/packages/chat/extensions/extensions.dart';
import 'package:flutter/material.dart';

import '../models/chat_view_states_configuration.dart';
import '../values/enumaration.dart';
import '../values/typedefs.dart';

class ChatViewStateWidget extends StatelessWidget {
  const ChatViewStateWidget({
    Key? key,
    this.chatViewStateWidgetConfig,
    required this.chatViewState,
    this.onReloadButtonTap,
  }) : super(key: key);
  final ChatViewStateWidgetConfiguration? chatViewStateWidgetConfig;
  final ChatViewState chatViewState;
  final VoidCallBack? onReloadButtonTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: chatViewStateWidgetConfig?.widget ??
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                (chatViewStateWidgetConfig?.title
                    ?.getChatViewStateTitle(chatViewState))!,
                style: chatViewStateWidgetConfig?.titleTextStyle ??
                    const TextStyle(
                      fontSize: 22,
                    ),
              ),
              if (chatViewStateWidgetConfig?.subTitle != null)
                Text(
                  (chatViewStateWidgetConfig?.subTitle)!,
                  style: chatViewStateWidgetConfig?.subTitleTextStyle,
                ),
              if (chatViewState.isLoading)
                CircularProgressIndicator(
                  color: chatViewStateWidgetConfig?.loadingIndicatorColor,
                ),
              if (chatViewStateWidgetConfig?.imageWidget != null)
                (chatViewStateWidgetConfig?.imageWidget)!,
              if (chatViewStateWidgetConfig?.reloadButton != null)
                (chatViewStateWidgetConfig?.reloadButton)!,
              if (chatViewStateWidgetConfig != null &&
                  (chatViewStateWidgetConfig?.showDefaultReloadButton)! &&
                  chatViewStateWidgetConfig?.reloadButton == null &&
                  (chatViewState.isError || chatViewState.noMessages)) ...[
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: onReloadButtonTap,
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  child: const Text('Reload'),
                )
              ]
            ],
          ),
    );
  }
}
