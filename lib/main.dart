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
  bool _disableFetchButton = false;

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
        dismissDirection: DismissDirection.up,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Dio getClient(String baseUrl, List<String> allowedSHAFingerprints) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
      ),
    );
    dio.interceptors.add(
      CertificatePinningInterceptor(
        allowedSHAFingerprints: allowedSHAFingerprints,
      ),
    );

    return dio;
  }

  void fetchAPI() {
    List<String> allowedSHAFingerprints = [];
    if (_useValidSHA256Certificate) {
      allowedSHAFingerprints.add(validSHA256Certificate);
    }
    if (_useExpiredCertificate) {
      allowedSHAFingerprints.add(expiredSHA256Certificate);
    }

    if (!_disableFetchButton) {
      setState(() {
        _disableFetchButton = true;
      });
      Dio client = getClient(
        baseURL,
        allowedSHAFingerprints,
      );
      client
          .get("/")
          .then(
            (value) => {
              _showInfoMessage('${value.statusCode} ${value.statusMessage}'),
              setState(() {
                _disableFetchButton = false;
              })
            },
          )
          .catchError(
            (e) => {
              _showInfoMessage(e.toString()),
              setState(() {
                _disableFetchButton = false;
              })
            },
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 16,
          ),
          child: Column(
            children: [
              Card(
                elevation: 2,
                child: Column(
                  children: [
                    SwitchListTile(
                      value: _useValidSHA256Certificate,
                      onChanged: (bool value) {
                        _toggleUsingValidSHA256Certificate(value);
                      },
                      title: const Text(
                        'Use Valid SHA256 Certificate',
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      height: 40,
                      child: RichText(
                        // textAlign: TextAlign.center,
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodySmall,
                          children: [
                            TextSpan(
                              text: _useValidSHA256Certificate
                                  ? 'SHA-256 Certificate Fingerprint: '
                                  : '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            TextSpan(
                              text: _useValidSHA256Certificate
                                  ? validSHA256Certificate
                                  : '',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: Column(
                  children: [
                    SwitchListTile(
                      value: _useExpiredCertificate,
                      onChanged: (bool value) {
                        _toggleUsingExpriedCertificate(value);
                      },
                      title: const Text(
                        'Use Expried Certificate',
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      height: 40,
                      child: RichText(
                        // textAlign: TextAlign.center,
                        text: TextSpan(
                          style: Theme.of(context).textTheme.bodySmall,
                          children: [
                            TextSpan(
                              text: _useExpiredCertificate
                                  ? 'SHA-256 Certificate Fingerprint: '
                                  : '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            TextSpan(
                              text: _useExpiredCertificate
                                  ? expiredSHA256Certificate
                                  : '',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_disableFetchButton)
                const Expanded(
                  child: Text("Fetching API from $baseURL"),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchAPI,
        tooltip: 'Fetch API',
        child: Icon(_disableFetchButton ? Icons.lock : Icons.send),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
