


 import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:payarapp/domain/state/state_screen_glass.dart';

class PageGlass extends StatefulWidget{



  @override
  State<PageGlass> createState() => _PageGlassState();
}

class _PageGlassState extends State<PageGlass> {

  StateScreenGlass? _stateScreenGlass;
  late ScrollController _scrollController;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        margin: const EdgeInsets.fromLTRB(0, 30, 0, 0),
        child: Observer(builder: (_){
           if(_stateScreenGlass!.hasData){
             return SingleChildScrollView(
               child: Row(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: List.generate(_stateScreenGlass!.asksFinal.length, (index){
                       return _ItemGlassAsk(stateScreenGlass:_stateScreenGlass!,price: _stateScreenGlass!.asksFinal[index].price, size:  _stateScreenGlass!.asksFinal[index].size);
                     }),
                   ),
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.end,
                     children: List.generate(_stateScreenGlass!.bidsFinal.length, (index){
                       return _ItemGlassBid(price: _stateScreenGlass!.bidsFinal[index].price, size:  _stateScreenGlass!.bidsFinal[index].size);
                     }),
                   ),

                 ],
               ),
             );
           }

          return Center(child: CircularProgressIndicator());
        },),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _stateScreenGlass=StateScreenGlass();
    _stateScreenGlass!.getOrderBook();
    _stateScreenGlass!.getTrade();
    _scrollController=ScrollController();


  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _stateScreenGlass!.close();
  }
}




 class _ItemGlassAsk extends StatelessWidget {

   final double price;
   final double size;
   final StateScreenGlass stateScreenGlass;

   _ItemGlassAsk({required this.price, required this.size,required this.stateScreenGlass});

   @override
   Widget build(BuildContext context) {
     // TODO: implement build
     return Container(
       color: Colors.redAccent,
       child: GestureDetector(
         onTap: (){
           stateScreenGlass.priceCurrent=price;
         },
         child: Row(
           mainAxisAlignment: MainAxisAlignment.spaceAround,
           children: [
             Padding(
               padding: const EdgeInsets.all(5.0),
               child: Text('$price'),
             ),
             Divider(),
             Text('$size',style: TextStyle(
               fontWeight: FontWeight.bold
             ),),
           ],
         ),
       ),
     );
   }


 }



 class _ItemGlassBid extends StatelessWidget {

   final double price;
   final double size;

   _ItemGlassBid({required this.price, required this.size});


   @override
   Widget build(BuildContext context) {
     // TODO: implement build
     return Container(
       color: Colors.greenAccent,
       child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceAround,
         children: [
           Padding(
             padding: const EdgeInsets.all(5.0),
             child: Text('$price'),
           ),
           Divider(),
           Text('$size',style: TextStyle(
               fontWeight: FontWeight.bold
           ),),
         ],
       ),
     );
   }
 }
