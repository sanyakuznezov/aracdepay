  
  

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:payarapp/domain/model/order.dart';
import 'package:payarapp/domain/model/tickets.dart';
import 'package:payarapp/domain/repository/firebase_repository.dart';
import 'package:payarapp/internal/dependencies/repository_module.dart';
import 'package:payarapp/ui/artifacts_widget.dart';
import 'package:payarapp/util/combi_to_array.dart';
import 'package:payarapp/util/size_controll.dart';
import 'package:transparent_image/transparent_image.dart';




class UserOrderScreen extends StatefulWidget{

   final Order? order;
   final List<Tickets>? list;
   const UserOrderScreen({Key? key,@required this.order,@required this.list}):super(key: key);

  @override
  _UserOrderScreenState createState() {
    // TODO: implement createState
   return _UserOrderScreenState();
  }
  
  
}
    class _UserOrderScreenState extends State<UserOrderScreen> with SingleTickerProviderStateMixin{
      final List<String> _id=<String>['artifact_1','artifact_2','artifact_3','artifact_4','artifact_5'];
      bool _available = true;
      final InAppPurchase _iap = InAppPurchase.instance;
      List<ProductDetails> _products = [];
      List<PurchaseDetails> _purchases = [];
      String _price='Load price...';
      StreamSubscription? _subscription;
      int lenght=0;
      bool isPurchase=true;
      bool isTapped=false;



      @override
      Widget build(BuildContext context) {
        return Scaffold(
            body: Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                height: MediaQuery
                    .of(context)
                    .size
                    .height,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: Image
                          .asset('assets/bg_activity.png')
                          .image,
                      fit: BoxFit.cover
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _appBar(widget.order!.getAvatar, widget.order!.getNik,
                          widget.order!.getId, context),
                      _bodyWidget(
                          widget.order!.getImg, widget.order!.prize, widget.list,
                          context),
                    ],
                  ),
                )

            )
        );
      }

      @override
      void initState() {
        super.initState();
        _initialize();
      }

      @override
      void dispose() {
        _subscription!.cancel();
        super.dispose();
      }


     //billing
      void _initialize() async {
        lenght=widget.list!.length-1;
        final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
        _available = await _iap.isAvailable();
        if (_available) {
          await _getProducts();
        }
        _subscription = purchaseUpdated.listen((purchaseDetailsList) {
          _purchases.addAll(purchaseDetailsList);
          _verifyPurchase();
        }, onDone: () {
          _subscription!.cancel();
        }, onError: (error) {
          // handle error here.
        });
      }

      PurchaseDetails _hasPurchased(String productID) {
        return _purchases.firstWhere( (purchase) => purchase.productID == productID);
      }

      Future<void> addOrder(String idPuschase,String price,Order order)async{
        print('addOrder');
        await RepositoryModule.firebaseRepository().addOrders(id_puschase: idPuschase, price: price, order: order)
            .catchError((error){
             print('error order $error');
        });

      }

      void _verifyPurchase() {
        PurchaseDetails purchase =_hasPurchased(_id[lenght]);
        if (purchase != null && purchase.status == PurchaseStatus.purchased) {
          addOrder(purchase.purchaseID!,_price,widget.order!);
          setState(() {
            isPurchase=false;
          });
          showDialog<String>(context: context,
              builder: (BuildContext context)=>AlertDialog(
                title: Text('Сongratulations!',
                  style: TextStyle(
                    fontFamily: 'Old',
                    fontSize: 25.0,
                    color: Colors.orange
                  ),),
                content: Text('You have become a member of the Arcade2.0 game project. We remind you that the results of the game will be published on our YouTube channel ${widget.order!.getDateGame}, which we will notify you by email. Good luck!',
                  style: TextStyle(
                      fontFamily: 'Old',
                    fontSize: 20.0
                  ),),
                actions: [
                  TextButton(
                      onPressed: ()=>Navigator.pop(context,'Cancel'),
                      child: Text('Cancel',
                        style: TextStyle(
                            fontFamily: 'Old',
                            fontSize: 20.0,
                            color: Colors.orange
                        ),))
                ],
              ));
        }else if(purchase.status==PurchaseStatus.error){
            showDialog<String>(context: context,
                builder: (BuildContext context)=>AlertDialog(
                  title: Text('Payment error',
                  style: TextStyle(
                    fontFamily: 'Old',
                  ),),
                  content: Text('Close this message and try again',
                  style: TextStyle(
                    fontFamily: 'Old'
                  ),),
                  actions: [
                    TextButton(
                        onPressed: ()=>Navigator.pop(context,'Cancel'),
                        child: Text('Cancel',
                        style: TextStyle(
                          fontFamily: 'Old',
                          color: Colors.orange
                        ),))
                  ],
                ));

        }
      }

      Future<void> _getProducts() async {
        Set<String> ids = Set.from([_id[lenght], 'test_a']);
        ProductDetailsResponse response = await _iap.queryProductDetails(ids);
        setState(() {
          _products = response.productDetails;
          _price=_products[0].price;
        });
      }
      void _buyProduct(ProductDetails prod) {
        final PurchaseParam purchaseParam = PurchaseParam(productDetails: prod);
        // _iap.buyNonConsumable(purchaseParam: purchaseParam);
        _iap.buyConsumable(purchaseParam: purchaseParam, autoConsume: false);
      }



      //billing end



      Widget _bodyWidget(String? url, String? prize, List<Tickets>? list,
          BuildContext context) {
        return Container(
            height: MediaQuery
                .of(context)
                .size
                .height,
            child:
            ListView.builder(
                padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 100.0),
                itemCount: list!.length + 1,
                itemBuilder: (BuildContext c, int i) {
                  if (i == 0) {
                    return _widgetTop(context, url!, prize!);
                  } else {
                    return ArtifactsWidget(
                        CombiToArray.toArray(list[i - 1].getCombi));
                  }
                }));
      }


      Widget _widgetTop(BuildContext context, String url, String prize) {
        return Container(
          margin: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
          width:Sizer(buildContext: context, maxSize: 360.0).height(90.0),
          height: Sizer(buildContext: context, maxSize: 460.0).height(75.0),
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: Image
                      .asset('assets/fabric_red_you_win.png',
                    fit: BoxFit.fill,)
                      .image
              )
          ),

          child: Center(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 70.0, 0.0, 0.0),
                  child: Column(
                    children: [
                      Stack(
                        children: <Widget>[
                          Center(
                            child: Container(
                              margin: EdgeInsets.all(15.0),
                               width: Sizer(buildContext: context,maxSize: 100.0).witch(30),
                              height: Sizer(buildContext: context,maxSize: 100.0).witch(30),
                              child:  Center(
                                child: FadeInImage.assetNetwork(
                                  placeholder: 'assets/loader.gif',
                                  imageErrorBuilder:(context, error, stackTrace) {
                                  return Image.asset(
                              'assets/unknown.png',
                              width: Sizer(buildContext: context,maxSize: 100.0).witch(20),
                              height: Sizer(buildContext: context,maxSize: 100.0).witch(20),
                              fit: BoxFit.fill);
                              },
                                  image: url,
                                  fit: BoxFit.fill,
                                  width: Sizer(buildContext: context,maxSize: 100.0).witch(30),
                                  height:Sizer(buildContext: context,maxSize: 100.0).witch(30),
                                ),
                              ),

                            ),
                          ),
                          Center(
                            child: Container(
                              width: Sizer(buildContext: context,maxSize: 140.0).witch(35),
                              height: Sizer(buildContext: context,maxSize: 140.0).witch(35),
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: Image
                                          .asset('assets/rating_frame.png',
                                          fit: BoxFit.fill)
                                          .image
                                  )
                              ),

                            ),
                          )

                        ],
                      ),
                      Container(
                        width:Sizer(buildContext: context,maxSize: 230.0).witch(60),
                        height:Sizer(buildContext: context,maxSize: 160.0).witch(38),
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: Image
                                    .asset('assets/content_field_big.png',
                                  fit: BoxFit.fill,)
                                    .image
                            )
                        ),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                                8.0,Sizer(buildContext: context,maxSize: 30.0).size(8), 8.0, 8.0),
                            child: Column(
                              children: [
                                Text('$prize',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      color: Colors.white
                                  ),),
                                Text(
                                  'Payment for participation in the game is made using the GPay service. In case of winning, the prize will be delivered by local delivery services',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 13.0,
                                      color: Colors.white
                                  ),)
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, Sizer(buildContext: context,maxSize: 40.0).size(10)),
                    child: Container(
                      width: Sizer(buildContext: context,maxSize: 180.0).witch(45),
                      height: Sizer(buildContext: context,maxSize: 60.0).witch(15),
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: Image
                                  .asset('assets/chest.png',
                                  fit: BoxFit.fill)
                                  .image
                          )
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                        child: Center(
                          child: Text('Your choice',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontFamily: 'Old'
                            ),),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: isPurchase? Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0,Sizer(buildContext: context,maxSize: 65.0).size(20)),
                    child:InkWell(
                        onHighlightChanged: (value){
                          setState(() {
                            isTapped=value;
                            print('setState $isTapped');
                          });
                        },
                        onTap: ()=>{
                        _buyProduct(_products[0])
                        },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                           width: isTapped?Sizer(buildContext: context,maxSize: 120.0).witch(30):Sizer(buildContext: context,maxSize: 140.0).witch(40),
                            height:isTapped?Sizer(buildContext: context,maxSize: 50.0).witch(12):Sizer(buildContext: context,maxSize: 60.0).witch(20),
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: Image
                                        .asset('assets/button_orange.png')
                                        .image
                                )
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    0.0, 0.0, 0.0, 5.0),
                                child: Text(_price,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontFamily: 'Old',
                                      fontSize: 15.0,
                                      color: Colors.orange[300]
                                  ),),
                              ),
                            ),
                          ),
                    )
                  ): null
                )

              ],
            ),
          ),
        );
      }


      Widget _appBar(String urlAva, String nik, String id,
          BuildContext context) {
        final textTheme=Theme.of(context).textTheme;
        return Container(
            width: MediaQuery
                .of(context)
                .size
                .width,
            height: 90,
            color: Colors.black45,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 0.0),
                child: Row(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Center(
                                child: FadeInImage.assetNetwork(
                                  placeholder: 'assets/loader.gif',
                                  image: urlAva,
                                  imageErrorBuilder:(context, error, stackTrace) {
                                    return Image.asset(
                                        'assets/woman.png',
                                        width: 30.0,
                                        height: 30.0,
                                        fit: BoxFit.fitWidth);
                                  },
                                  width: 30.0,
                                  height: 30.0,
                                ),
                              ),
                              Container(
                                width: 40.0,
                                height: 40.0,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: Image
                                            .asset('assets/rating_frame.png')
                                            .image,
                                        fit: BoxFit.fill
                                    )
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                5.0, 0.0, 0.0, 0.0),
                            child: Text(nik,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.white,

                              ),),
                          ),

                        ],
                      ),
                    ),
                    Expanded(
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    0.0, 0.0, 5.0, 0.0),
                                child: Image.asset('assets/star_big.png',
                                  width: 20.0,
                                  height: 20.0,),
                              ),
                              Text('$id',
                                style: TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.orange
                                ),)
                            ],
                          ),
                        )
                    )
                  ],
                )
            )
        );
      }
    }



