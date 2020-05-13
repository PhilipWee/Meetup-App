import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:getflutter/getflutter.dart';

class DetailsPage extends StatelessWidget {
  final dynamic item;
  DetailsPage({this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Details(item: item,),
    );
  }
}

class Details extends StatefulWidget {
  final dynamic item;
  Details({this.item});

  @override
  State<StatefulWidget> createState() => DetailsState(item: item);
}

class DetailsState extends State<Details> {
  dynamic item;
  DetailsState({this.item});

  //Function to build the carousel for images
  Widget _buildImgCarousel(List images, double height) {
    return Container(
      child: GFCarousel(
        items: images.map((img) {
          return Container(
            child: Image.network(img, fit: BoxFit.cover,),
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
    String details = item.details;
    String address = item.address;
    double rating = item.rating;
    List images = item.images;
    Size screen = MediaQuery.of(context).size;
    double expHeight = screen.height*0.6;
    double imgHeight = screen.height*0.7;

    return Scaffold(
      body: Container(
        height: screen.height,
        width: screen.width,
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
                  titlePadding: const EdgeInsets.only(bottom: 18.0),
                  title: Text(item.name, textAlign: TextAlign.center,),
                  background: Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    fit: StackFit.expand,
                    children: <Widget>[
                      Hero(
                        tag: item.name,
                        child: Container(
                          child: Image.network(item.images[0], fit: BoxFit.cover,),
                        ),
                      ),
                      Container(
                        child: GFCarousel(
                          items: images.map((img) {
                            return Container(
                              child: Image.network(img, fit: BoxFit.cover,),
                            );
                          }).toList(),
                          height: imgHeight,
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
                      )
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.only(left:10.0, right: 10.0, bottom: 10.0, top: 15.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(right:8.0),
                            child: Container(
                                child: Icon(Icons.location_on,)
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 12,
                          child: Container(
                            color: Colors.white,
                            child: Text(
                              address,
                              style: const TextStyle(fontSize: 15.0),
                              maxLines: 2,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left:10.0, right: 15.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: Container(
                                child: Text(""),
                              ),
                            ),
                            Expanded(
                              flex: 12,
                              child:Container(
                                child: Text(
                                  details,
                                  style: TextStyle(
                                    fontSize: 12.0,
                                  ),
                                  maxLines: 15,
                                ),
                              ),
                            )
                          ],
                        ),
                        Padding(padding: const EdgeInsets.symmetric(vertical: 12.0)),
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 12,
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Text("Ratings & Reviews",
                                  style: TextStyle(
                                    fontSize: 12.0,
                                  ),
                                  maxLines: 100,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                "$rating",
                                style: TextStyle(
                                    fontSize: 12.0
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: RatingBarIndicator(
                                  rating: item.rating,
                                  itemBuilder: (context, index) => Icon(
                                    Icons.star,
                                    color: Colors.black,
                                  ),
                                  itemCount: 5,
                                  itemSize: 12,
                                ),
                              ),
                            )
                          ],
                        ),
                        Divider(
                          color: Colors.black26,
                          thickness: 1.0,
                        ),
                        Container(
                          alignment: Alignment.center,
                          height: 500.0,
                          child: Text("Try this out and be the first to review!"),
                        )
                      ],
                    ),
                  )
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}