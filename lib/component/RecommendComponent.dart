import 'package:flutter/material.dart';
import 'package:movie/service/server_method.dart';
import './MovieListComponent.dart';
/*-----------------------获取推荐的影片------------------------*/
class RecommendComponent extends StatelessWidget {
  final String classify;
  final String direction;
  const RecommendComponent({Key key,this.classify,this.direction}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getRecommend(classify),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Container();
          }else{
            List movieList = snapshot.data["data"];
            return MovieListComponent(movieList: movieList,title: "推荐",direction: direction,);
          }
        });
  }
}
/*-----------------------获取推荐的影片------------------------*/
