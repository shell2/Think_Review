import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:web_socket_channel/io.dart';
import 'package:device_info/device_info.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '回响',
      theme: ThemeData(
        primaryColor: Colors.deepPurpleAccent,
      ),
      home: MyHomePage(title: '回响'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  _randomBit_user_id(int len) {
    String scopeF = '2345678'; //首位
    String scopeC = '0123456789'; //中间
    String result = '';
    for (int i = 0; i < len; i++) {
      if (i == 1) {
        result = scopeF[Random().nextInt(scopeF.length)];
      } else {
        result = result + scopeC[Random().nextInt(scopeC.length)];
      }
    }
//    print('result'+result);
    return result;
  }

  var list = ['正在接收数据，请点击右下角按钮刷新'];
  var controller = "new";
  bool _lights = false;
  int flag_timer = 1;
//声明 TextEditingController
  TextEditingController textEditingController = new TextEditingController();
//创建 IOWebSocketChannel
  IOWebSocketChannel ioWebSocketChannel;
  IOWebSocketChannel ioWebSocketChannel2;

  void init_State() {
    ioWebSocketChannel = IOWebSocketChannel.connect('ws:local:port');
  }

  //发送信息
  void sendMessage(String send_will) {
    //if (textEditingController.text.isNotEmpty) {
    ioWebSocketChannel.sink.add(send_will);
    //}
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificaionsPlugin =
      new FlutterLocalNotificationsPlugin();
  var initalizationsSettingsAndroid;
  var initalizationsSettingsIOS;
  var initalizationsSettings;
  void _showNotification(String worde, String word2) async {
    await _demoNotification(worde, word2);
  }

  Future<void> _demoNotification(String word_1, String word_2) async {
    // 设置 android 通道名称
    var androidPlatformChannnelSpecifics = AndroidNotificationDetails(
        'channel_ID', 'channel name', 'channel description',
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'test ticker');
    var iOSChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannnelSpecifics, iOSChannelSpecifics);

    await flutterLocalNotificaionsPlugin.show(
        0, word_1, word_2, platformChannelSpecifics,
        payload: 'test payload');
  }

  _randomBit(int len) {
    String scopeF = '2345678'; //首位
    String scopeC = '0123456789'; //中间
    String result = '';
    for (int i = 0; i < len; i++) {
      if (i == 1) {
        result = scopeF[Random().nextInt(scopeF.length)];
      } else {
        result = result + scopeC[Random().nextInt(scopeC.length)];
      }
    }
//    print('result'+result);
    return result;
  }

  void countdown() {
    var random = _randomBit(3);
    print(random);
    Timer _timer;
    _timer =
        new Timer.periodic(new Duration(seconds: int.parse(random)), (timer) {
      setState(() {
        random = _randomBit(3);
        print(random);
        var ioWebSocketChannel =
            IOWebSocketChannel.connect('ws:local:port');
        ioWebSocketChannel.stream.listen((message) {
          _showNotification('来自服务器的消息：', message);
          print(message);
        });
      });
    });
    //    Timer timer = new Timer(new Duration(seconds: int.parse(random)), () {
    //
    //      // 只在倒计时结束时回调
    //    });
  }

  @override
  void initState() {
    super.initState();

    /// android 图标

    initalizationsSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    initalizationsSettingsIOS = new IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initalizationsSettings = new InitializationSettings(
        initalizationsSettingsAndroid, initalizationsSettingsIOS);
    flutterLocalNotificaionsPlugin.initialize(initalizationsSettings,
        onSelectNotification: onSelectNotification);
  }

  Future<String> _getId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint("Notification payload: $payload");
    }
    _getId().then((id) {
      init_State();
      String deviceId_togetwords = id;
      ioWebSocketChannel.sink.add("get," + deviceId_togetwords);
      print("send:" + "get," + deviceId_togetwords + "," + controller);
      ioWebSocketChannel.stream.listen((message) {
        _showNotification('来自服务器的消息：', message);
        print('-----');
        print(message);
        print('-----');
        list = message.split('-');
      });
    });
//    _showNotification('来自服务器的消息：', 'get');

    print('test:');
    print(list);
    await Navigator.push(context,
        MaterialPageRoute(builder: (context) => SecondRoute(data: list)));
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text(title),
              content: Text(body),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text("OK"),
                  onPressed: () async {
                    Navigator.of(context, rootNavigator: true).pop();
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SecondRoute(data: list)));
                  },
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    items:
    List<String>.generate(10000, (i) => "Item $i");
    final _controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: Column(
//          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10.0),
                icon: Icon(Icons.text_fields),
                labelText: 'Input.ex ：rainbow,彩虹',
              ),
              onChanged: _textFieldChanged,
              autofocus: false,
            ),
            MergeSemantics(
              child: ListTile(
                title: Text('接收推送'),
                trailing: CupertinoSwitch(
                  value: _lights,
                  onChanged: (bool value) {
                    Timer _timer2;
                    if (value == true) {
                      _showNotification("开始接收来自服务器的消息",
                          "Start to receive the message from server");
                      flag_timer = 1;
                      _timer2 = new Timer.periodic(new Duration(seconds: 15),
                          (timer) {
                        if (flag_timer == 1) {
                          var ioWebSocketChannel = IOWebSocketChannel.connect(
                              'ws:local:port');
                          _getId().then((id) {
                            String deviceId = id;
                            ioWebSocketChannel.sink
                                .add("device_id," + deviceId);
                            print("send:," + "device_id," + deviceId);
                          });
                          ioWebSocketChannel.stream.listen((message) {
                            _showNotification(
                                message.split(',')[0], message.split(',')[1]);
                            //print(message);
                          });
                          print('1s');
                        }
                      });
                    } else {
                      flag_timer = 0;
                      _showNotification('已停止接收来自服务器的消息：', 'Stop');

//                      countdown();
                    }
                    //print(_lights);
                    setState(() {
                      _lights = value;
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    _lights = !_lights;
                  });
                },
              ),
            ),

            Divider(
              height: 200.0,
              indent: 0.0,
              color: Colors.white,
            ),
            Text('念念不忘，必有回响🍃',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                )) // 默认左对齐
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _getId().then((id) {
            init_State();
            String deviceId = id;
            ioWebSocketChannel.sink.add("dw," + deviceId + "," + controller);
            print("send:" + "dw," + deviceId + "," + controller);
          });
          //countdown();
          _showNotification(controller.split(',')[0], controller.split(',')[1]);
          print("click");
        },
        backgroundColor: Colors.deepPurpleAccent,
        tooltip: '点击发送到云端同步',
        child: Icon(Icons.notifications),
      ),
// This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _textFieldChanged(String str) {
    controller = str;
    //_showNotification('sss','sss');
    print(str);
  }
}

class SecondRoute extends StatelessWidget {
  SecondRoute({this.data});
  List<String> data;

  IOWebSocketChannel ioWebSocketChannel;

  void _showNotification(String worde, String word2) async {
    await _demoNotification(worde, word2);
  }

  Future<void> _demoNotification(String word_1, String word_2) async {
    // 设置 android 通道名称
    var androidPlatformChannnelSpecifics = AndroidNotificationDetails(
        'channel_ID', 'channel name', 'channel description',
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'test ticker');
    var iOSChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannnelSpecifics, iOSChannelSpecifics);
    FlutterLocalNotificationsPlugin flutterLocalNotificaionsPlugin =
        new FlutterLocalNotificationsPlugin();
    await flutterLocalNotificaionsPlugin.show(
        0, word_1, word_2, platformChannelSpecifics,
        payload: 'test payload');
  }

  @override
  Widget build(BuildContext context) {
    Future<String> _getId() async {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
        return iosDeviceInfo.identifierForVendor; // unique ID on iOS
      } else {
        AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
        return androidDeviceInfo.androidId; // unique ID on Android
      }
    }

    var list2 = ['正在接收数据...'];
    return new MaterialApp(
        title: 'Words',
        theme: new ThemeData(
          primaryColor: Colors.deepPurpleAccent,
        ),
        home: new Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              _getId().then((id) {
                ioWebSocketChannel =
                    IOWebSocketChannel.connect('ws:local:port');
                String deviceId_togetwords = id;
                ioWebSocketChannel.sink.add("get," + deviceId_togetwords);
                print("send:" + "get," + deviceId_togetwords);
                ioWebSocketChannel.stream.listen((message) {
                  _showNotification('来自服务器的消息：', message);
                  print('-----');
                  print(message);
                  print('-----');
                  list2 = message.split('-');
                  Navigator.of(context, rootNavigator: true).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SecondRoute(data: list2)));
                });
              });

//              _showNotification('来自服务器的消息：', 'get');
            },
            tooltip: 'Increment',
            backgroundColor: Colors.deepPurpleAccent,
            child: Icon(Icons.autorenew),
          ),
          appBar: AppBar(
            title: Text('Review—Words'),
          ),
          body: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                Future<String> _getId() async {
                  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                  if (Theme.of(context).platform == TargetPlatform.iOS) {
                    IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
                    return iosDeviceInfo
                        .identifierForVendor; // unique ID on iOS
                  } else {
                    AndroidDeviceInfo androidDeviceInfo =
                        await deviceInfo.androidInfo;
                    return androidDeviceInfo.androidId; // unique ID on Android
                  }
                }

                var item = data[index];
                return new Dismissible(
                  key: Key(item),
                  child: ListTile(
                    title: Text(data[index]),
                  ),
                  onDismissed: (direction) {
                    _getId().then((id) {
                      String deviceId = id;
                      ioWebSocketChannel =
                          IOWebSocketChannel.connect('ws:local:port');
                      ioWebSocketChannel.sink
                          .add("de," + deviceId + "," + data[index]);
                      print("send:," + "device_id," + deviceId);
                    });
                    data.remove(index);
                    print(direction);
                  },
                  background: Container(
                      color: Colors.deepPurpleAccent,
                      child: Center(
                        child: Text(
                          "Delete",
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
                  //更换绿色背景
//                  secondaryBackground: Container(
//                    color: Colors.deepPurpleAccent,
//                  ),
                );
              }),
        ));
  }
}
