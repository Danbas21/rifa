import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:rifa/core/functions/random.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rifa/core/functions/upload_data.dart';
import 'firebase_options.dart';
import 'package:uuid/uuid.dart' as id;
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rifa FunFai',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Rifa Benéfica FunFai'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> launchWhatsApp() async {
    final linkUrl = Uri.parse(
        "https://gofundme.com///f///ninos-y-ninas-vulnerables-fomentan-la-educacion///donate?source=btn_donate");

    if (await canLaunchUrl(linkUrl)) {
      await launchUrl(linkUrl);
    } else {
      throw 'Could not launch $linkUrl';
    }
  }

  double _counter = 0;
  final phone = FocusNode();
  final email = FocusNode();
  final name = TextEditingController();
  final phones = TextEditingController();
  final mail = TextEditingController();

  void _incrementCounter() {
    setState(() {
      _counter = getRandomNumber();
    });
  }

  void saveRegister() async {
    CollectionReference ref = FirebaseFirestore.instance.collection('tickets');

    try {
      await ref.add({
        'id': const id.Uuid().v4(),
        'name': name.text,
        'phone': phones.text,
        'mail': mail.text,
        'ticket': '$_counter'
      });

      launchWhatsApp();
    } catch (e) {
      // Manejar cualquier error que ocurra al guardar el registro
      print('Error al guardar el registro: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    const textToolTip = "dale !!!";
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 800, width: 800, child: const ImageListScreen()),
              SizedBox(
                width: width,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: name,
                        autofocus: true,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.person),
                          labelText: 'Nombre',
                        ),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                      ),
                      TextField(
                        controller: phones,
                        focusNode: phone,
                        onEditingComplete: () =>
                            FocusScope.of(context).requestFocus(phone),
                        decoration: const InputDecoration(
                          icon: Icon(Icons.phone),
                          labelText: 'Teléfono',
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                      ),
                      TextField(
                        controller: mail,
                        focusNode: email,
                        onEditingComplete: () =>
                            FocusScope.of(context).requestFocus(email),
                        decoration: const InputDecoration(
                          icon: Icon(Icons.email),
                          labelText: 'Email',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                'Obtén tu número de la suerte:',
                style: TextStyle(
                  fontSize: width / 15,
                ),
              ),
              Text(
                '$_counter',
                style: TextStyle(
                  fontSize: width / 15,
                ),
              ),
              SizedBox(
                height: height / 3,
                width: width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: width / 4,
                      height: height / 10,
                      child: FloatingActionButton(
                        onPressed: _incrementCounter,
                        tooltip: textToolTip,
                        child: Text(
                          "Elije tu numero ganador",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: width / 40,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 60,
                    ),
                    SizedBox(
                      width: width / 4,
                      height: height / 10,
                      child: FloatingActionButton(
                        onPressed: saveRegister,
                        tooltip: textToolTip,
                        child: Text(
                          "Guardar el registro boleto",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: width / 40,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 60,
              ),
              SizedBox(
                height: height / 3,
                width: width / 1.5,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('tickets')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No records found.'));
                    }

                    final records = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final record = records[index];
                        final data = record.data() as Map<String, dynamic>;

                        return ListTile(
                          title: Text(
                            data['name'] ?? 'No Name',
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: width / 40,
                                backgroundColor: Colors.amberAccent),
                          ),
                          subtitle: Text(
                            '${data['phone'] ?? 'No Phone'}\n${data['mail'] ?? 'No Email'}\n${data['ticket'] ?? 'No ticket'}',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: width / 40,
                                backgroundColor: Colors.amberAccent),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
