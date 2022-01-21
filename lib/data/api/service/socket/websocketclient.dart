




 import 'dart:convert';
import 'dart:io';
 import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:payarapp/data/api/model/model_ticker_price_api.dart';
import 'package:payarapp/data/mapper/mapper_trading_data.dart';
import 'package:payarapp/domain/model/trading/model_orderbook_bid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../constant.dart';

class WebSocketClient{


   static const BASE_URL='wss://ftx.com/ws/';
   static const API_KEY='AQmjcrH8Q-vWS8tsrzZjqWDRzNXH-QVIysguGeu9';
   static const API_PRIVATE_KEY='S3FtewQslutLHbji4hm2_FyJOpjjDMRN0imc6xjY';
   WebSocketChannel? _channel;
   WebSocketChannel? _chanellTicker;
   WebSocketChannel? _channelTrades;
   WebSocketChannel? _channelOrdersbookGrouped;




   WebSocketClient(){
     _channel=WebSocketChannel.connect(Uri.parse('wss://ftx.com/ws/'));
    _chanellTicker=WebSocketChannel.connect(Uri.parse('wss://ftx.com/ws/'));
     _channelTrades=WebSocketChannel.connect(Uri.parse('wss://ftx.com/ws/'));
     _channelOrdersbookGrouped=WebSocketChannel.connect(Uri.parse('wss://ftx.com/ws/'));
   }
     //Тикерный канал предоставляет последние лучшие рыночные данные о предложениях и предложениях.
   subscribeTicker({required Function update}){
     _chanellTicker!.sink.add(jsonEncode({
       'op': 'subscribe', 'channel': Constant.CHANNEL_TICKER, 'market': 'DOGE/USD'
     }));
     _chanellTicker!.stream.listen((event) {
       update(MapperTradingData.fromApiTicker(modelTickerPriceApi: ModelTickerPriceApi.fromApi(map: jsonDecode(event)['data'])));
     }).onError((error){
       print("error ws");
     });

   }

    //Канал сделок предоставляет данные обо всех сделках на рынке.
   subscribeTrades({required Function update}){
     _channelTrades!.sink.add(jsonEncode({
       'op': 'subscribe', 'channel': 'trades', 'market': 'DOGE/USD'
     }));
     _channelTrades!.stream.listen((event) {
       update(event);
     });

   }
   //Todo not work
   //получение данных  открыты орерах
   subscribeOrders({required String channel,required Function update})async{

     final ts=DateTime.now().millisecondsSinceEpoch;
     var key = utf8.encode(API_PRIVATE_KEY);
     var signaturePayload = utf8.encode('${ts}websocket_login');
     final hmac256=Hmac(sha256, key);
     Digest sha256Result = hmac256.convert(signaturePayload);
     _channel!.sink.add(jsonEncode({
       "args": {
         "key": API_KEY,
         "sign":  hex.encode(sha256Result.bytes),
         "time": ts
       },
       'op': 'login'
     })
    );
     _channel!.sink.add(jsonEncode({'op': 'subscribe', 'channel': 'orders'}));
     _channel!.stream.listen((event) {
       update(event);

     }).onError((error){
       print('Error subscrabe $error');
     });


   }


   //Канал книги ордеров предоставляет данные о 100 лучших ордерах книги ордеров с обеих сторон..
   subscribeOrderbookgrouped({required Function update}){
     _channelOrdersbookGrouped!.sink.add(jsonEncode({
       'op': 'subscribe', 'channel': 'orderbook', 'market': 'DOGE/USD'
     }));
     _channelOrdersbookGrouped!.stream.listen((event) {
       update(jsonDecode(event)['data']);
     });

   }



   close(){
     _channel!.sink.close();
     _chanellTicker!.sink.close();
     _channelTrades!.sink.close();
     _channelOrdersbookGrouped!.sink.close();
   }
 }