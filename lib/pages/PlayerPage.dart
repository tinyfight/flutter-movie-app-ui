import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie/theme/ThemeStyle.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../component/ScoreComponent.dart';
import '../service/serverMethod.dart';
import '../component/RecommendComponent.dart';
import '../component/YouLikesComponent.dart';
import '../model/MovieDetailModel.dart';
import '../model/MovieUrlModel.dart';
import '../model/CommentModel.dart';
import '../config/serviceUrl.dart';
import '../theme/ThemeColors.dart';
import '../theme/ThemeSize.dart';
import '../utils/common.dart';

class PlayerPage extends StatefulWidget {
  final MovieDetailModel movieItem;

  PlayerPage({Key key, this.movieItem}) : super(key: key);

  @override
  _PlayerPageState createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  String url = "";
  int currentIndex = 0;
  List<Widget> playGroupWidget = [];
  bool isFavoriteFlag = false;
  int commentCount = 0;
  bool showComment = false;
  List<CommentModel> commentList = [];
  int pageNum = 1;
  CommentModel replyTopCommentItem;
  CommentModel replyCommentItem;
  bool disabledSend = true;
  TextEditingController keywordController = TextEditingController();
  String hintText = '';

  @override
  void initState() {
    super.initState();
    isFavorite(); //查询电影是否已经收藏过
    savePlayRecordService(widget.movieItem);
    keywordController.addListener(() {
      setState(() {
        disabledSend = keywordController.text == "";
      });
    });
    getCommentCountService(widget.movieItem.movieId).then((res) {
      setState(() {
        commentCount = res["data"];
      });
    });
  }

  void isFavorite() {
    isFavoriteService(widget.movieItem.movieId).then((res) {
      if (res["data"] > 0) {
        setState(() {
          isFavoriteFlag = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.colorBg,
      body: SafeArea(
          top: true,
          child: Stack(
            children: <Widget>[
              ListView(children: <Widget>[
                webViewWidget(),
                Container(
                    padding: ThemeStyle.padding,
                    child: Column(children: <Widget>[
                      handleWidget(),
                      titleWidget(),
                      playUrlWidget(),
                      Column(
                        children: <Widget>[
                          widget.movieItem.label != null
                              ? YouLikesComponent(label: widget.movieItem.label)
                              : SizedBox(),
                          RecommendComponent(
                            classify: widget.movieItem.classify,
                            direction: "horizontal",
                            title: "推荐",
                          )
                        ],
                      )
                    ])),
              ]),
              showComment ? getTopCommentWidget() : SizedBox()
            ],
          )),
    );
  }

  //获取一级评论
  Widget getTopCommentWidget() {
    return Positioned(
        child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Color.fromRGBO(0, 0, 0, 0.5),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.width / 16 * 9,
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                      color: ThemeColors.colorBg,
                      child: Column(children: <Widget>[
                        SizedBox(height: ThemeSize.smallMargin),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(commentCount.toString() + "条评论")
                          ],
                        ),
                        Expanded(
                            flex: 1,
                            child: Padding(
                                padding: EdgeInsets.only(
                                    left: ThemeSize.containerPadding,
                                    right: ThemeSize.containerPadding,
                                    top: 0),
                                child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    itemCount: commentList.length,
                                    itemBuilder: (content, index) {
                                      return Padding(
                                          padding: EdgeInsets.only(
                                              bottom: ThemeSize.smallMargin),
                                          child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                ClipOval(
                                                    child: Image.network(
                                                        serviceUrl +
                                                            commentList[index]
                                                                .avater,
                                                        height:
                                                            ThemeSize.bigIcon,
                                                        width:
                                                            ThemeSize.bigIcon,
                                                        fit: BoxFit.cover)),
                                                SizedBox(
                                                    width:
                                                        ThemeSize.smallMargin),
                                                Expanded(
                                                  flex: 1,
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        InkWell(
                                                            onTap: () {
                                                              setState(() {
                                                                replyCommentItem =
                                                                    replyTopCommentItem =
                                                                        commentList[
                                                                            index];
                                                              });
                                                            },
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  Text(
                                                                      commentList[
                                                                              index]
                                                                          .username,
                                                                      style: TextStyle(
                                                                          color:
                                                                              ThemeColors.subTitle)),
                                                                  SizedBox(
                                                                      height: ThemeSize
                                                                          .miniMargin),
                                                                  Text(commentList[
                                                                          index]
                                                                      .content),
                                                                  SizedBox(
                                                                      height: ThemeSize
                                                                          .miniMargin),
                                                                  Text(
                                                                    formatTime(commentList[index]
                                                                            .createTime) +
                                                                        '  回复',
                                                                    style: TextStyle(
                                                                        color: ThemeColors
                                                                            .subTitle),
                                                                  ),
                                                                ])),
                                                        commentList[index]
                                                                    .replyList
                                                                    .length >
                                                                0
                                                            ? getReplyList(
                                                                commentList[
                                                                        index]
                                                                    .replyList,
                                                                commentList[
                                                                    index])
                                                            : SizedBox(),
                                                        commentList[index]
                                                                        .replyCount >
                                                                    0 &&
                                                                commentList[index]
                                                                            .replyCount -
                                                                        10 *
                                                                            commentList[index]
                                                                                .replyPageNum >
                                                                    0
                                                            ? InkWell(
                                                                child: Padding(
                                                                    padding: EdgeInsets
                                                                        .only(
                                                                            top:
                                                                                5),
                                                                    child: Text(
                                                                        '--展开${commentList[index].replyCount - 10 * commentList[index].replyPageNum}条回复 >',
                                                                        style: TextStyle(
                                                                            color:
                                                                                ThemeColors.subTitle))),
                                                                onTap: () {
                                                                  getReplyCommentListService(
                                                                          commentList[index]
                                                                              .id,
                                                                          10,
                                                                          commentList[index].replyPageNum +
                                                                              1)
                                                                      .then(
                                                                          (value) {
                                                                    setState(
                                                                        () {
                                                                      (value["data"]
                                                                              as List)
                                                                          .cast()
                                                                          .forEach(
                                                                              (element) {
                                                                        commentList[index]
                                                                            .replyList
                                                                            .add(CommentModel.fromJson(element));
                                                                      });
                                                                      commentList[
                                                                              index]
                                                                          .replyPageNum++;
                                                                    });
                                                                  });
                                                                })
                                                            : SizedBox()
                                                      ]),
                                                )
                                              ]));
                                    }))),
                        Padding(
                            padding: ThemeStyle.padding,
                            child: Row(children: <Widget>[
                              Expanded(
                                child: Container(
                                    height: 45,
                                    //修饰黑色背景与圆角
                                    decoration: new BoxDecoration(
                                      //灰色的一层边框
                                      color: ThemeColors.borderColor,
                                      borderRadius: new BorderRadius.all(
                                          new Radius.circular(
                                              ThemeSize.bigRadius)),
                                    ),
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.only(
                                        left: ThemeSize.smallMargin, top: 0),
                                    child: TextField(
                                        controller: keywordController,
                                        cursorColor: Colors.grey, //设置光标
                                        decoration: InputDecoration(
                                          hintText: replyCommentItem != null
                                              ? '回复${replyCommentItem.username}'
                                              : '有爱评论，说点好听的~',
                                          hintStyle: TextStyle(
                                              fontSize: ThemeSize.smallFontSize,
                                              color: Colors.grey),
                                          contentPadding: EdgeInsets.only(
                                              left: ThemeSize.smallMargin,
                                              top: 0),
                                          border: InputBorder.none,
                                        ))),
                              ),
                              SizedBox(width: ThemeSize.smallMargin),
                              Container(
                                height: 45,
                                child: RaisedButton(
                                    highlightColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    color: disabledSend
                                        ? ThemeColors.disableColor
                                        : Theme.of(context).accentColor,
                                    child: Text("发送",
                                        style: TextStyle(
                                            color: disabledSend
                                                ? ThemeColors.subTitle
                                                : Colors.white)),
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide.none,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                ThemeSize.superRadius))),
                                    onPressed: () async {
                                      if (disabledSend) {
                                        Fluttertoast.showToast(
                                            msg: "已经到底了",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIos: 1,
                                            backgroundColor:
                                                ThemeColors.disableColor,
                                            textColor: Colors.white,
                                            fontSize: ThemeSize.middleFontSize);
                                      } else {
                                        onInserComment();
                                      }
                                    }),
                              )
                            ]))
                      ])),
                )
              ],
            )));
  }

  void onInserComment() {
    Map commentMap = {};
    commentMap["content"] = keywordController.text;
    commentMap["parentId"] =
        replyCommentItem == null ? null : replyCommentItem.id;
    commentMap["topId"] =
        replyCommentItem == null ? null : replyTopCommentItem.topId;
    commentMap["movieId"] = widget.movieItem.movieId;
    commentMap["replyUserId"] =
        replyCommentItem == null ? null : replyCommentItem.userId;
    insertCommentService(commentMap).then((res) {
      setState(() {
        commentCount++;
        if (replyTopCommentItem == null) {
          commentList.add(CommentModel.fromJson(res["data"]));
        } else {
          replyTopCommentItem.replyList.add(CommentModel.fromJson(res["data"]));
          replyCommentItem = replyTopCommentItem = null;
        }
        keywordController.text = '';
      });
    });
  }

  //获取回复
  Widget getReplyList(List<CommentModel> replyList, topCommentItem) {
    List<Widget> replyListWidget = [];
    replyList.forEach((element) {
      replyListWidget.add(Padding(
          padding: EdgeInsets.only(top: ThemeSize.smallMargin),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipOval(
                  child: Image.network(serviceUrl + element.avater,
                      height: ThemeSize.middleIcon,
                      width: ThemeSize.middleIcon,
                      fit: BoxFit.cover)),
              SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    InkWell(
                        onTap: () {
                          setState(() {
                            replyTopCommentItem = topCommentItem;
                            replyCommentItem = element;
                          });
                        },
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                  '${element.username}▶${element.replyUserName}',
                                  style:
                                      TextStyle(color: ThemeColors.subTitle)),
                              SizedBox(height: ThemeSize.miniMargin),
                              Text(element.content),
                              Text(formatTime(element.createTime) + '  回复',
                                  style: TextStyle(color: ThemeColors.subTitle))
                            ]))
                  ],
                ),
              )
            ],
          )));
    });
    return Column(children: replyListWidget);
  }

  //获取播放地址
  Widget playUrlWidget() {
    return FutureBuilder(
        future: getMovieUrlService(widget.movieItem.movieId),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Container();
          } else {
            List<MovieUrlModel> playList =
                (snapshot.data["data"] as List).cast().map((item) {
              return MovieUrlModel.fromJson(item);
            }).toList();
            if (playList.length == 0) {
              return Container();
            }
            List<List<MovieUrlModel>> playGroupList = [];
            for (int i = 0; i < playList.length; i++) {
              if (i == 0) {
                url = playList[0].url;
              }
              int playGroup = playList[i].playGroup;
              if (playGroupList.length < playGroup) {
                playGroupList.add(<MovieUrlModel>[]);
              }
              playGroupList[playGroup - 1].add(playList[i]);
            }
            Widget tabs = _renderTab(playGroupList.length);
            Widget series = _getPlaySeries(playGroupList);
            return Container(
                decoration: ThemeStyle.boxDecoration,
                padding: ThemeStyle.padding,
                margin: ThemeStyle.margin,
                child: Column(children: [
                  tabs,
                  SizedBox(
                      height: playGroupList.length > 1
                          ? ThemeSize.containerPadding
                          : 0),
                  series
                ]));
          }
        });
  }

  Widget _renderTab(int length) {
    List<Widget> tabs = <Widget>[];
    if (length > 1) {
      for (int i = 0; i < length; i++) {
        tabs.add(InkWell(
            onTap: () {
              setState(() {
                currentIndex = i;
              });
            },
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft:
                            Radius.circular(i == 0 ? ThemeSize.bigRadius : 0),
                        bottomLeft:
                            Radius.circular(i == 0 ? ThemeSize.bigRadius : 0),
                        topRight: Radius.circular(
                            i == length - 1 ? ThemeSize.bigRadius : 0),
                        bottomRight: Radius.circular(
                            i == length - 1 ? ThemeSize.bigRadius : 0)),
                    color: currentIndex == i
                        ? ThemeColors.activeColor
                        : ThemeColors.colorWhite,
                    border: Border(
                        left: BorderSide(
                            width: ThemeSize.borderWidth,
                            color: ThemeColors.borderColor),
                        right: BorderSide(
                            width: ThemeSize.borderWidth,
                            color: ThemeColors.borderColor),
                        top: BorderSide(
                            width: ThemeSize.borderWidth,
                            color: ThemeColors.borderColor),
                        bottom: BorderSide(
                            width: ThemeSize.borderWidth,
                            color: ThemeColors.borderColor))),
                height: ThemeSize.buttonHeight,
                padding: EdgeInsets.only(
                    left: ThemeSize.smallMargin, right: ThemeSize.smallMargin),
                child: Center(
                    child: Text("播放地址${(i + 1).toString()}", style: TextStyle(color: currentIndex == i ? ThemeColors.colorWhite : Colors.black))))));
      }
    }
    return Row(
      children: tabs,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Widget _getPlaySeries(List playGroupList) {
    List<Widget> playSeries = [];
    for (int i = 0; i < playGroupList[currentIndex].length; i++) {
      playSeries.add(Container(
        padding: ThemeStyle.padding,
        decoration: BoxDecoration(
            border: Border.all(
                color: url == playGroupList[currentIndex][i].url
                    ? Colors.orange
                    : ThemeColors.borderColor),
            borderRadius:
                BorderRadius.all(Radius.circular(ThemeSize.middleRadius))),
        child: Center(
          child: Text(playGroupList[0][i].label,
              style: TextStyle(
                  color: url == playGroupList[currentIndex][i].url
                      ? Colors.orange
                      : Colors.black)),
        ),
      ));
    }
    return GridView.count(
        crossAxisSpacing: ThemeSize.smallMargin,
        mainAxisSpacing: ThemeSize.smallMargin,
        //水平子 Widget 之间间距
        crossAxisCount: ThemeSize.crossAxisCount,
        //一行的 Widget 数量
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        childAspectRatio: ThemeSize.childAspectRatio,
        children: playSeries);
  }

  Widget webViewWidget() {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width / 16 * 9,
        decoration: BoxDecoration(
          color: Colors.black,
        ),
        child:
            /*url != ""
          ? WebView(
              initialUrl: url,
              javascriptMode: JavascriptMode.unrestricted,
            )
          : SizedBox(),*/
            SizedBox());
  }

  Widget handleWidget() {
    return Container(
      decoration: ThemeStyle.boxDecoration,
      padding: ThemeStyle.padding,
      margin: ThemeStyle.margin,
      child: Row(
        children: <Widget>[
          InkWell(
              child: Row(
                children: <Widget>[
                  Image.asset(
                    "lib/assets/images/icon-comment.png",
                    width: ThemeSize.middleIcon,
                    height: ThemeSize.middleIcon,
                  ),
                  SizedBox(width: ThemeSize.smallMargin),
                  Text(commentCount.toString()),
                ],
              ),
              onTap: () {
                setState(() {
                  showComment = true;
                  getTopCommentListService(
                          widget.movieItem.movieId, ThemeSize.pageSize, pageNum)
                      .then((value) {
                    (value["data"] as List).forEach((element) {
                      setState(() {
                        commentList.add(CommentModel.fromJson(element));
                      });
                    });
                  });
                });
              }),
          Expanded(flex: 1, child: SizedBox()),
          InkWell(
            onTap: () {
              if (isFavoriteFlag) {
                //如果已经收藏过了，点击之后取消收藏
                deleteFavoriteService(widget.movieItem.movieId).then((res) {
                  if (res["data"] > 0) {
                    setState(() {
                      isFavoriteFlag = false;
                    });
                  }
                });
              } else {
                //如果没有收藏过，点击之后添加收藏
                saveFavoriteService(widget.movieItem).then((res) {
                  if (res["data"] > 0) {
                    setState(() {
                      isFavoriteFlag = true;
                    });
                  }
                });
              }
            },
            child: Image.asset(
                isFavoriteFlag
                    ? "lib/assets/images/icon-collection-active.png"
                    : "lib/assets/images/icon-collection.png",
                width: ThemeSize.middleIcon,
                height: ThemeSize.middleIcon),
          ),
          SizedBox(width: ThemeSize.smallMargin),
          Image.asset("lib/assets/images/icon-share.png",
              width: ThemeSize.middleIcon, height: ThemeSize.middleIcon)
        ],
      ),
    );
  }

  Widget titleWidget() {
    return Container(
        decoration: ThemeStyle.boxDecoration,
        padding: ThemeStyle.padding,
        margin: ThemeStyle.margin,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.movieItem.movieName,
                style: ThemeStyle.mainTitleStyle,
              ),
              SizedBox(height: ThemeSize.smallMargin),
              Text(
                widget.movieItem.star,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: ThemeSize.smallMargin),
              ScoreComponent(score: widget.movieItem.score),
            ]));
  }
}
