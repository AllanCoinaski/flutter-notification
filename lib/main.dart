import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:notifications/utils/token.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); //Para inializar o firebase antes do runApp, devo aplicar o ensureInit...
  await Firebase.initializeApp();
  FirebaseMessaging messaging = FirebaseMessaging
      .instance; //Instanciando Firebase para receber notificações
  _startPushNotifications(messaging);
  //Chamando permissões (Não é obrigatório, mas é interessante implementar para o app não dar crash)
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('Permissão concedida');
    _startPushNotifications(messaging);
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('Permissão concedida de modo provisório');
    _startPushNotifications(messaging);
  } else {
    print('Permissão negada');
  }
  runApp(const MyApp());
}

///Verifica as permissões e chama a função para obter o token
void _startPushNotifications(FirebaseMessaging messaging) async {
  String? token = await messaging
      .getToken(); //Obtém o token para enviar mensagem para somente um usuário
  print('token: $token');
  setToken(token);

  //Quando o app estar em foregroud(aberto), ele considera que a notificação não deve ser exibida, então é necessário tratar
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Mensagem recebida enquanto o App estava aberto!');
    print(message.data);
    if (message.notification != null) {
      print(
          'A mensagem continha uma notificação: ${message.notification!.title}, ${message.notification!.body}');
    }
  });

  //Tratando as notificações em backgroud(segundo plano)
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroudHandler);

  //Verificando se o app foi aberto pela notificação
  await FirebaseMessaging.instance
      .getInitialMessage()
      .then((RemoteMessage? message) async {
    if (message != null) {
      showMyDialog('Você clicou na notificação!');
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Notificações Firebase'),
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Para receber uma notificação, configure seu Firebase e informe ao projeto as configurações.',
          style: TextStyle(
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

///Função para controlar notificações em segundo plano
Future<void> _firebaseMessagingBackgroudHandler(RemoteMessage message) async {
  print('Mensagem recebida em segundo plano ${message.notification}');
}

///Função para abrir Dialog na tela
void showMyDialog(String message) {
  Widget okButton = OutlinedButton(
      onPressed: () => Navigator.pop(navigatorKey.currentContext!),
      child: const Text('Ok'));
  AlertDialog alerta = AlertDialog(
    title: const Text('Testando!'),
    content: Text(message),
    actions: [],
  );
  showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) {
        return alerta;
      });
}
