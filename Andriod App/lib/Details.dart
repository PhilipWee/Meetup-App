import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getflutter/getflutter.dart';


class Details extends StatefulWidget {
  final dynamic item;
  Details({this.item});

  @override
  State<StatefulWidget> createState() => DetailsPageState(item: item);
}

class DetailsPageState extends State<Details> {
  dynamic item;
  DetailsPageState({this.item});

  //Function to build the carousel for images
  Widget _buildImgCarousel(List images, double height) {
    return Container(
      child: GFCarousel(
        items: images.map((img) {
          return Container(
            child: Image.asset(img, fit: BoxFit.cover,),
          );
        }).toList(),
        height: height,
        viewportFraction: 1.0,
        pagination: true,
        pagerSize: 8.0,
        passiveIndicator: Colors.grey,
        activeIndicator: Colors.white,
        onPageChanged: (index) {
          setState(() {
            index;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    double expHeight = screen.height*0.6;
    double imgHeight = screen.height*0.7;

    return Scaffold(
      body: Container(
        height: screen.height,
        width: screen.width,
        child: Hero(
            tag: item.name,
            child: Container(
              color: Colors.white,
              width: screen.width,
              height: screen.height,
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: expHeight,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Text(item.name, textAlign: TextAlign.center,),
                      background: Stack(
                        alignment: AlignmentDirectional.bottomCenter,
                        fit: StackFit.expand,
                        children: <Widget>[
                          Container(
                            child: Container(child: Image.asset(item.images[0], fit: BoxFit.cover,),),
                          )
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: const EdgeInsets.only(left:10.0, bottom: 15.0, top: 15.0),
                        child: Row(
                          children: <Widget>[
                            const Padding(padding:EdgeInsets.symmetric(horizontal: 2)),
                            Icon(Icons.location_on),
                            const Padding(padding:EdgeInsets.symmetric(horizontal: 8)),
                            Container(
                              color: Colors.white,
                              child: Column(
                                children: <Widget>[
                                  const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
                                  Text(
                                    item.address,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15.0
                                    ),
                                  ),
                                  const Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
                                ],
                                crossAxisAlignment: CrossAxisAlignment.start,
                              ),
                            ),
                          ],
                        ),
                      ),

                    ]),
                  )
                ],
              ),
            ),
        ),
      ),
    );
  }
}