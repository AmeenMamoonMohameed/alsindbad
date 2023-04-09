import 'package:akarak/packages/chat/chatview.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:akarak/blocs/app_bloc.dart';
import 'package:akarak/configs/config.dart';
import 'package:akarak/models/model.dart';
import 'package:akarak/widgets/app_placeholder.dart';

import '../packages/chat/models/message.dart';
import '../utils/translate.dart';

enum UserViewType {
  basic,
  information,
  qrcode,
  chat,
  company,
  office,
  informationAdv
}

class AppUserInfo extends StatelessWidget {
  final UserModel? user;
  final ChatUserModel? chatUser;
  final VoidCallback? onPressed;
  final UserViewType type;

  const AppUserInfo({
    Key? key,
    this.user,
    this.chatUser,
    this.onPressed,
    this.type = UserViewType.basic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case UserViewType.information:
        if (user == null) {
          return AppPlaceholder(
            child: Row(
              children: <Widget>[
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 10,
                        width: 100,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 10,
                        width: 100,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 10,
                        width: 150,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return InkWell(
          onTap: onPressed,
          child: Row(
            children: <Widget>[
              if (user?.profilePictureDataUrl.isEmpty ?? true)
                Image.asset(
                  Images.user,
                  height: 60,
                  width: 100,
                ),
              if (user?.profilePictureDataUrl.isNotEmpty ?? false)
                CachedNetworkImage(
                  imageUrl: user!.getProfileImage(),
                  imageBuilder: (context, imageProvider) {
                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color:
                              Theme.of(context).dividerColor.withOpacity(0.05),
                        ),
                      ),
                    );
                  },
                  placeholder: (context, url) {
                    return AppPlaceholder(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    );
                  },
                  errorWidget: (context, url, error) {
                    return AppPlaceholder(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(Icons.error),
                      ),
                    );
                  },
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      user!.membershipNo.toString(),
                      maxLines: 1,
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                    // const SizedBox(height: 4),
                    // Text(
                    //   "${user!.countryCode.replaceAll("+", "00")}-${user!.phoneNumber}",
                    //   maxLines: 3,
                    //   style: Theme.of(context).textTheme.caption,
                    // ),
                    const SizedBox(height: 4),
                    Text(
                      user!.accountName,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ],
                ),
              ),
              RotatedBox(
                quarterTurns: AppLanguage.isRTL() ? 2 : 0,
                child: const Icon(
                  Icons.keyboard_arrow_right,
                  textDirection: TextDirection.ltr,
                ),
              )
            ],
          ),
        );

      case UserViewType.company:
        if (user == null) {
          return AppPlaceholder(
            child: Row(
              children: <Widget>[
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 10,
                        width: 100,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 10,
                        width: 100,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 10,
                        width: 150,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return InkWell(
            onTap: onPressed,
            child: user?.profilePictureDataUrl.isEmpty ?? true
                ? Image.asset(
                    Images.user,
                    height: 60,
                    width: 100,
                  )
                : CachedNetworkImage(
                    colorBlendMode: BlendMode.color,
                    color: Theme.of(context).primaryColor,
                    imageUrl: user!.getProfileImage(),
                    placeholder: (context, url) {
                      return AppPlaceholder(
                        child: Container(
                          width: 60,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Color(0xFFFFFFFF),
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      );
                    },
                    errorWidget: (context, url, error) {
                      return AppPlaceholder(
                        child: Container(
                          width: 60,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Icon(Icons.error),
                        ),
                      );
                    },
                    imageBuilder: (context, imageProvider) {
                      return Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: const Color(0xff000000),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Text(
                                    user!.accountName,
                                    maxLines: 1,
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2
                                        ?.copyWith(color: Colors.white),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${user!.countryCode.replaceAll('+', '00')}-${user!.phoneNumber}',
                                    maxLines: 1,
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        ?.copyWith(color: Colors.white),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user!.description,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .caption
                                        ?.copyWith(color: Colors.white),
                                  ),
                                  const SizedBox(height: 8),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    }));

      case UserViewType.informationAdv:
        if (user == null) {
          return AppPlaceholder(
            child: Row(
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 10,
                      width: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 10,
                      width: 150,
                      color: Colors.white,
                    ),
                  ],
                )
              ],
            ),
          );
        }
        return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              const SizedBox(height: 4),
              InkWell(
                onTap: onPressed,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      if (user?.profilePictureDataUrl.isEmpty ?? true)
                        Image.asset(
                          Images.user,
                          height: 60,
                          width: 100,
                        ),
                      if (user?.profilePictureDataUrl.isNotEmpty ?? false)
                        CachedNetworkImage(
                          imageUrl: user!.getProfileImage(),
                          placeholder: (context, url) {
                            return AppPlaceholder(
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                ),
                              ),
                            );
                          },
                          imageBuilder: (context, imageProvider) {
                            return Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                                shape: BoxShape.rectangle,
                              ),
                            );
                          },
                          errorWidget: (context, url, error) {
                            return AppPlaceholder(
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                ),
                                child: const Icon(Icons.error),
                              ),
                            );
                          },
                        ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            user!.accountName,
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "${user!.countryCode}-${user!.phoneNumber}",
                            style: Theme.of(context).textTheme.caption,
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 50),
                  color: Theme.of(context).colorScheme.onTertiary,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(user?.description ?? ""),
                  )),
            ]);

      case UserViewType.qrcode:
        return Container();

      case UserViewType.chat:
        if (chatUser == null) {
          return AppPlaceholder(
            child: Row(
              children: <Widget>[
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 10,
                        width: 100,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 10,
                        width: 100,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 10,
                        width: 150,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        Widget content = Container();
        if (chatUser!.lastMessage != null) {
          content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (chatUser!.lastMessage?.type == MessageType.voice)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.mic,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 2),
                            if (chatUser!.lastMessage?.voiceMessageDuration !=
                                null)
                              Text(
                                chatUser!.lastMessage!.voiceMessageDuration!
                                    .toHHMMSS(),
                                style: Theme.of(context).textTheme.caption,
                              ),
                          ],
                        )
                      else if (chatUser!.lastMessage?.type == MessageType.image)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.photo,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 2),
                            if (chatUser!.lastMessage?.voiceMessageDuration !=
                                null)
                              Text(
                                Translate.of(context).translate('photo'),
                                style: Theme.of(context).textTheme.caption,
                              ),
                          ],
                        )
                      else if (chatUser!.lastMessage?.type == MessageType.map)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_pin,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 2),
                            if (chatUser!.lastMessage?.voiceMessageDuration !=
                                null)
                              Text(
                                Translate.of(context).translate('location'),
                                style: Theme.of(context).textTheme.caption,
                              ),
                          ],
                        )
                      else
                        Text(
                          chatUser!.lastMessage?.message ??
                              Translate.of(context).translate("no_messages"),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.caption,
                        ),
                    ],
                  )),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 5,
                    child: VerticalDivider(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Text(
                          chatUser!.lastMessageTimeElapsed?.toString() ?? "",
                          maxLines: 2,
                          style: Theme.of(context).textTheme.labelSmall,
                          overflow: TextOverflow.visible,
                        ),
                        if (chatUser!.lastMessage!.fromUserId !=
                                AppBloc.userCubit.state!.userId &&
                            chatUser!.lastMessage!.status != Status.seen)
                          Text(
                            Translate.of(context).translate("new"),
                            maxLines: 1,
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                    color: Theme.of(context).primaryColor),
                            overflow: TextOverflow.visible,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        }
        return InkWell(
          onTap: onPressed,
          child: Column(children: [
            Row(
              children: <Widget>[
                if (chatUser!.profilePictureDataUrl.isEmpty)
                  SizedBox(
                    height: 64,
                    width: 64,
                    child: Image.asset(
                      Images.user,
                      height: 60,
                      width: 100,
                    ),
                  )
                else
                  CachedNetworkImage(
                    imageUrl: Application.domain +
                        chatUser!.profilePictureDataUrl
                            .replaceAll("\\", "/")
                            .replaceAll("TYPE", "thumb"),
                    imageBuilder: (context, imageProvider) {
                      return Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Theme.of(context)
                                .dividerColor
                                .withOpacity(0.05),
                          ),
                        ),
                      );
                    },
                    placeholder: (context, url) {
                      return AppPlaceholder(
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      );
                    },
                    errorWidget: (context, url, error) {
                      return AppPlaceholder(
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Icon(Icons.error),
                        ),
                      );
                    },
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        chatUser!.accountName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                color: Theme.of(context).colorScheme.secondary),
                      ),
                      content,
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 8),
            // SizedBox(
            //   height: 2,
            //   child: Divider(
            //     color: Theme.of(context).dividerColor,
            //   ),
            // ),
            // const SizedBox(height: 8),
          ]),
        );

      default:
        if (user == null) {
          return AppPlaceholder(
            child: Row(
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 10,
                      width: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 10,
                      width: 150,
                      color: Colors.white,
                    ),
                  ],
                )
              ],
            ),
          );
        }
        return InkWell(
          onTap: onPressed,
          child: Row(
            children: <Widget>[
              if (user?.profilePictureDataUrl.isEmpty ?? true)
                Image.asset(
                  Images.user,
                  height: 60,
                  width: 100,
                ),
              if (user?.profilePictureDataUrl.isNotEmpty ?? false)
                CachedNetworkImage(
                  imageUrl: user!.getProfileImage(),
                  placeholder: (context, url) {
                    return AppPlaceholder(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                  imageBuilder: (context, imageProvider) {
                    return Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                  errorWidget: (context, url, error) {
                    return AppPlaceholder(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.error),
                      ),
                    );
                  },
                ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    user!.accountName,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${user!.countryCode}-${user!.phoneNumber}",
                    style: Theme.of(context).textTheme.caption,
                  )
                ],
              )
            ],
          ),
        );
    }
  }
}
