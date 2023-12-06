import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:http_certificate_pinning/http_certificate_pinning.dart';
import 'package:poc_ssl_certificate_pinning/dummy_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  bool _useValidSHA256Certificate = true;
  bool _useExpiredCertificate = false;

  void _toggleUsingValidSHA256Certificate(bool value) {
    setState(() {
      _useValidSHA256Certificate = value;
    });
  }

  void _toggleUsingExpriedCertificate(bool value) {
    setState(() {
      _useExpiredCertificate = value;
    });
  }

  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void fetchAPI() async {
    List<String> allowedSHAFingerprints = [];
    if (_useValidSHA256Certificate) {
      allowedSHAFingerprints.add(validSHA256Certificate);
    }
    if (_useExpiredCertificate) {
      allowedSHAFingerprints.add(expiredSHA256Certificate);
    }

    try {
      Dio client = getClient(
        baseURL,
        allowedSHAFingerprints,
      );
      final res = await client.get("/");
      _showInfoMessage('${res.statusCode} ${res.statusMessage}');
    } catch (e) {
      _showInfoMessage(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SwitchListTile(
              value: _useValidSHA256Certificate,
              onChanged: (bool value) {
                _toggleUsingValidSHA256Certificate(value);
              },
              title: const Text(
                'Use The Valid SHA256 Certificate',
              ),
            ),
            SwitchListTile(
              value: _useExpiredCertificate,
              onChanged: (bool value) {
                _toggleUsingExpriedCertificate(value);
              },
              title: const Text(
                'Use The Expried Certificate',
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchAPI,
        tooltip: 'Fetch API',
        child: const Icon(Icons.send),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

Dio getClient(String baseUrl, List<String> allowedSHAFingerprints) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
    ),
  );
  // (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
  //     (HttpClient client) {
  //   client.badCertificateCallback =
  //       (X509Certificate cert, String host, int port) => false;
  //   return client;
  // };
  dio.interceptors.add(
    CertificatePinningInterceptor(
      allowedSHAFingerprints: allowedSHAFingerprints,
    ),
  );

  return dio;
}
