import 'dart:math';

import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/material.dart';
import 'package:html_to_text/html_to_text.dart';
import 'package:xdnmb_api/xdnmb_api.dart';

import '../data/services/settings.dart';
import '../utils/extensions.dart';
import '../utils/theme.dart';
import '../utils/time.dart';
import 'content.dart';
import 'forum_name.dart';
import 'image.dart';
import 'scroll.dart';
import 'tooltip.dart';

typedef PostGestureCallback = void Function(PostBase post);

class _PostUser extends StatelessWidget {
  final String userHash;

  final bool isAdmin;

  final bool isPo;

  final TextStyle textStyle;

  const _PostUser(
      // ignore: unused_element
      {super.key,
      required this.userHash,
      this.isAdmin = false,
      this.isPo = false,
      required this.textStyle});

  @override
  Widget build(BuildContext context) {
    final style = textStyle.merge(
      TextStyle(
        color: isAdmin ? Colors.red : (isPo ? Colors.cyan.shade700 : null),
        fontWeight: isPo ? FontWeight.bold : null,
      ),
    );

    return htmlToRichText(
      context,
      userHash,
      textStyle: style,
      strutStyle: StrutStyle.fromTextStyle(style),
    );
  }
}

class _PostTime extends StatelessWidget {
  final DateTime postTime;

  final bool showFullTime;

  final TextStyle textStyle;

  const _PostTime(
      // ignore: unused_element
      {super.key,
      required this.postTime,
      this.showFullTime = true,
      required this.textStyle});

  @override
  Widget build(BuildContext context) => Text(
        showFullTime ? fullFormatTime(postTime) : formatTime(postTime),
        style: textStyle,
        strutStyle: StrutStyle.fromTextStyle(textStyle),
      );
}

typedef OnPostIdCallback = void Function(int postId);

class _PostId extends StatelessWidget {
  final int postId;

  final OnPostIdCallback? onPostIdTap;

  final TextStyle textStyle;

  const _PostId(
      // ignore: unused_element
      {super.key,
      required this.postId,
      this.onPostIdTap,
      required this.textStyle});

  @override
  Widget build(BuildContext context) {
    final text = Text(postId.toPostNumber(),
        style: textStyle, strutStyle: StrutStyle.fromTextStyle(textStyle));

    return onPostIdTap != null
        ? MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onPostIdTap!(postId),
              child: text,
            ),
          )
        : text;
  }
}

class _PostReplyCount extends StatelessWidget {
  final int replyCount;

  final TextStyle textStyle;

  const _PostReplyCount(
      // ignore: unused_element
      {super.key,
      required this.replyCount,
      required this.textStyle});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
              padding: const EdgeInsets.only(top: 2.0, right: 2.0),
              child: Icon(
                Icons.mode_comment_outlined,
                size: textStyle.fontSize != null
                    ? (textStyle.fontSize! + 2.0)
                    : 16.0,
                color: AppTheme.headerColor,
              )),
          Text(
            '$replyCount',
            style: textStyle,
            strutStyle: StrutStyle.fromTextStyle(textStyle),
          ),
        ],
      );
}

class _PostTitle extends StatelessWidget {
  final String title;

  final TextStyle textStyle;

  // ignore: unused_element
  const _PostTitle({super.key, required this.title, required this.textStyle});

  @override
  Widget build(BuildContext context) {
    final spanTextStyle =
        textStyle.merge(const TextStyle(fontWeight: FontWeight.bold));

    return RichText(
      text: TextSpan(
        text: '标题：',
        children: [
          htmlToTextSpan(
            context,
            title,
            textStyle: spanTextStyle,
          ),
        ],
        style: textStyle.merge(
          const TextStyle(
            color: AppTheme.headerColor,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      strutStyle: StrutStyle.fromTextStyle(spanTextStyle),
    );
  }
}

class _PostName extends StatelessWidget {
  final String name;

  final TextStyle textStyle;

  // ignore: unused_element
  const _PostName({super.key, required this.name, required this.textStyle});

  @override
  Widget build(BuildContext context) {
    final spanTextStyle =
        textStyle.merge(const TextStyle(fontWeight: FontWeight.bold));

    return RichText(
      text: TextSpan(
        text: '名称：',
        children: [
          htmlToTextSpan(
            context,
            name,
            textStyle: spanTextStyle,
          ),
        ],
        style: textStyle.merge(
          const TextStyle(
            color: AppTheme.headerColor,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      strutStyle: StrutStyle.fromTextStyle(spanTextStyle),
    );
  }
}

class _PostSage extends StatelessWidget {
  final TextStyle textStyle;

  // ignore: unused_element
  const _PostSage({super.key, required this.textStyle});

  @override
  Widget build(BuildContext context) {
    final fontSize = textStyle.fontSize;

    return Row(
      children: [
        Flexible(
            child: Text('本串已经被SAGE', style: textStyle.merge(AppTheme.boldRed))),
        const SizedBox(width: 5.0),
        QuestionTooltip(
          message: '被SAGE的串不会因为新回复而被顶上来，且一定时间后无法回复',
          size: fontSize != null ? (fontSize - 2.0) : null,
        ),
      ],
    );
  }
}

class PostDraft extends StatelessWidget {
  final String? title;

  final String? name;

  final String? content;

  final int? contentMaxLines;

  final TextStyle textStyle;

  PostDraft(
      {super.key,
      this.title,
      this.name,
      this.content,
      this.contentMaxLines,
      TextStyle? textStyle})
      : assert((title?.isNotEmpty ?? false) ||
            (name?.isNotEmpty ?? false) ||
            (content?.isNotEmpty ?? false)),
        textStyle = SettingsService.to.postContentTextStyle(textStyle);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title?.isNotEmpty ?? false)
              _PostTitle(title: title!, textStyle: textStyle),
            if (name?.isNotEmpty ?? false)
              _PostName(name: name!, textStyle: textStyle),
            if (content?.isNotEmpty ?? false)
              contentMaxLines != null
                  ? ExpandableText(
                      content!,
                      expandText: '展开',
                      collapseText: '收起',
                      linkColor: AppTheme.highlightColor,
                      maxLines: contentMaxLines!,
                      style: textStyle,
                    )
                  : Text(
                      content!,
                      style: textStyle,
                      strutStyle: StrutStyle.fromTextStyle(textStyle),
                    ),
          ],
        ),
      );
}

class PostContent extends StatelessWidget {
  late final Content content;

  final bool showFullTime;

  final bool showPostId;

  final bool showForumName;

  final bool showReplyCount;

  final double? headerHeight;

  final double? contentMaxHeight;

  final OnPostIdCallback? onPostIdTap;

  late final TextStyle headerTextStyle;

  PostBase get post => content.post;

  String? get poUserHash => content.poUserHash;

  TextStyle get contentTextStyle => content.textStyle!;

  PostContent(
      {super.key,
      required PostBase post,
      String? poUserHash,
      int? contentMaxLines,
      OnLinkTapCallback? onLinkTap,
      ImageDataCallback? onImagePainted,
      bool displayImage = true,
      bool canReturnImageData = false,
      bool canTapHiddenText = false,
      Color? hiddenTextColor,
      TextStyle? contentTextStyle,
      this.showFullTime = true,
      this.showPostId = true,
      this.showForumName = true,
      this.showReplyCount = true,
      this.headerHeight,
      this.contentMaxHeight,
      this.onPostIdTap,
      TextStyle? headerTextStyle}) {
    final settings = SettingsService.to;

    this.headerTextStyle = settings
        .postHeaderTextStyle(headerTextStyle)
        .apply(color: AppTheme.headerColor);

    content = Content(
        post: post,
        poUserHash: poUserHash,
        maxLines: contentMaxLines,
        onLinkTap: onLinkTap,
        onImagePainted: onImagePainted,
        displayImage: displayImage,
        canReturnImageData: canReturnImageData,
        canTapHiddenText: canTapHiddenText,
        hiddenTextColor: hiddenTextColor,
        textStyle: settings.postContentTextStyle(contentTextStyle));
  }

  @override
  Widget build(BuildContext context) {
    final forumId = post.forumId;
    final replyCount = post.replyCount;
    final isSage = post.isSage;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post is Tip)
            Text(
              '来自X岛匿名版官方的内容',
              style: headerTextStyle,
              strutStyle: StrutStyle.fromTextStyle(headerTextStyle),
            ),
          PostHeader(
            fontSize: headerTextStyle.fontSize,
            height: headerHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: _PostUser(
                    userHash: post.userHash,
                    isAdmin: post.isAdmin,
                    isPo: post.userHash == poUserHash,
                    textStyle: headerTextStyle,
                  ),
                ),
                Flexible(
                  child: _PostTime(
                    postTime: post.postTime,
                    showFullTime: showFullTime,
                    textStyle: headerTextStyle,
                  ),
                ),
                if (showPostId)
                  _PostId(
                    postId: post.id,
                    onPostIdTap: onPostIdTap,
                    textStyle: headerTextStyle,
                  ),
                if (showForumName && forumId != null)
                  Flexible(
                    child: ForumName(
                      forumId: forumId,
                      maxLines: 1,
                      textStyle: headerTextStyle,
                    ),
                  ),
                if (showReplyCount && replyCount != null)
                  _PostReplyCount(
                    replyCount: replyCount,
                    textStyle: headerTextStyle,
                  ),
              ],
            ),
          ),
          if (post.title.isNotEmpty && post.title != '无标题')
            _PostTitle(title: post.title, textStyle: contentTextStyle),
          if (post.name.isNotEmpty && post.name != '无名氏')
            _PostName(name: post.name, textStyle: contentTextStyle),
          if (isSage != null && isSage) _PostSage(textStyle: contentTextStyle),
          if (contentMaxHeight != null)
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: contentMaxHeight!),
              child: SingleChildScrollViewWithScrollbar(child: content),
            )
          else
            content,
        ].withSpaceBetween(height: 5.0),
      ),
    );
  }
}

class PostInkWell extends StatelessWidget {
  final PostContent content;

  final PostGestureCallback? onTap;

  final PostGestureCallback? onLongPress;

  final MouseCursor? mouseCursor;

  final Color? hoverColor;

  PostBase get post => content.post;

  PostInkWell(
      {super.key,
      required PostBase post,
      String? poUserHash,
      int? contentMaxLines,
      OnLinkTapCallback? onLinkTap,
      ImageDataCallback? onImagePainted,
      bool displayImage = true,
      bool canReturnImageData = false,
      bool canTapHiddenText = false,
      Color? hiddenTextColor,
      TextStyle? contentTextStyle,
      bool showFullTime = true,
      bool showPostId = true,
      bool showForumName = true,
      bool showReplyCount = true,
      double? headerHeight,
      double? contentMaxHeight,
      OnPostIdCallback? onPostIdTap,
      TextStyle? headerTextStyle,
      this.onTap,
      this.onLongPress,
      this.mouseCursor,
      this.hoverColor})
      : content = PostContent(
            post: post,
            poUserHash: poUserHash,
            contentMaxLines: contentMaxLines,
            onLinkTap: onLinkTap,
            onImagePainted: onImagePainted,
            displayImage: displayImage,
            canReturnImageData: canReturnImageData,
            canTapHiddenText: canTapHiddenText,
            hiddenTextColor: hiddenTextColor,
            contentTextStyle: contentTextStyle,
            showFullTime: showFullTime,
            showPostId: showPostId,
            showForumName: showForumName,
            showReplyCount: showReplyCount,
            headerHeight: headerHeight,
            contentMaxHeight: contentMaxHeight,
            onPostIdTap: onPostIdTap,
            headerTextStyle: headerTextStyle);

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap != null ? () => onTap!(post) : null,
        onLongPress: onLongPress != null ? () => onLongPress!(post) : null,
        mouseCursor: mouseCursor,
        hoverColor: hoverColor,
        child: content,
      );
}

class PostCard extends StatelessWidget {
  final Widget child;

  const PostCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        elevation: 2.0,
        child: child,
      );
}

class PostHeader extends StatelessWidget {
  final double? fontSize;

  final double? height;

  final Widget child;

  const PostHeader(
      // ignore: unused_element
      {super.key,
      this.fontSize,
      this.height,
      required this.child});

  @override
  Widget build(BuildContext context) => fontSize != null
      ? Padding(
          padding: EdgeInsets.symmetric(
              vertical: fontSize! *
                  max(
                      (height ?? SettingsService.to.postHeaderLineHeight) -
                          SettingsService.defaultLineHeight,
                      0.0) *
                  0.5),
          child: child)
      : child;
}
