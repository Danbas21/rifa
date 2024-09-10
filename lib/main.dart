import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rifa/core/functions/random.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rifa/core/functions/upload_data.dart';
import 'firebase_options.dart';
import 'package:uuid/uuid.dart' as id;

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
      title: 'Flutter Demo',
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

  void saveRegister() {
    CollectionReference ref = FirebaseFirestore.instance.collection('tickets');

    ref.add({
      'id': const id.Uuid().v4(),
      'name': name.text,
      'phone': phones.text,
      'mail': mail.text,
      'ticket': '$_counter'
    });
  }

  @override
  void dispose() {
    phone.dispose();
    email.dispose();
    name.dispose();
    phones.dispose();
    mail.dispose();
    super.dispose();
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 200, width: 200, child: ImageScreen()),
            SizedBox(
              width: width,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
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
            const Text(
              'Obtén tu número de la suerte:',
              style: TextStyle(
                fontSize: 50,
              ),
            ),
            Text(
              '$_counter',
              style: const TextStyle(
                fontSize: 50,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        height: height / 3,
        width: width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: width / 10,
              height: height / 13,
              child: FloatingActionButton(
                onPressed: saveRegister,
                tooltip: textToolTip,
                child: Text(
                  "Guardar el registro boleto",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: width / 80,
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 60,
            ),
            FloatingActionButton(
              onPressed: _incrementCounter,
              tooltip: textToolTip,
              child: const Icon(
                Icons.add,
                size: 50,
              ),
            ),
            Expanded(
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
                        title: Text(data['name'] ?? 'No Name'),
                        subtitle: Text(
                            '${data['phone'] ?? 'No Phone'}\n${data['mail'] ?? 'No Email'}\n${data['ticket'] ?? 'No ticket'}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
