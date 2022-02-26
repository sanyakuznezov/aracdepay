
  import 'package:payarapp/constant.dart';
import 'package:payarapp/data/api/model/modelorderplaceapi.dart';
import 'package:payarapp/internal/dependencies/repository_module.dart';

class StrategyLimitOrder {




   placeOrderSell({required String market,required int percentageOfBalance,required price}){
     RepositoryModule.apiRepository().placeOrder(modelOrderRequestPlaceApi:
     ModelOrderRequestPlaceApi(
         market: market,
         side: Constant.SIDE_SELL,
         //todo compute price
         price: price,
         type: Constant.TYPE_ORDER_LIMIT,
         //todo init balance usd
         size: 1,
         reduceOnly: false,
         ioc: false,
         postOnly: false,
         clientId:null));
   }


   double _getSize(int percentageOfBalance,double mainBalance){
      return (mainBalance*percentageOfBalance)/100;
   }


  placeOrderBuy({required String market,required int percentageOfBalance,required price}){
    RepositoryModule.apiRepository().placeOrder(modelOrderRequestPlaceApi:
    ModelOrderRequestPlaceApi(
        market: market,
        side: Constant.SIDE_BUY,
        //todo compute price
        price: price,
        type: Constant.TYPE_ORDER_LIMIT,
        //todo init balance usd
        size: 1,
        reduceOnly: false,
        ioc: false,
        postOnly: false,
        clientId:null));


  }


  }