import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:freerasp/talsec_app.dart';
import 'package:freerasp/utils/hash_converter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isSecure = true;

  @override
  void initState() {
    String base64Hash = hashConverter.fromSha256toBase64(
        "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad");
    final TalsecConfig config = TalsecConfig(
      /// For Android
      androidConfig: AndroidConfig(
        expectedPackageName: 'com.aheaditec.freeraspExample',
        expectedSigningCertificateHash: base64Hash,
        supportedAlternativeStores: ["com.sec.android.app.samsungapps"],
      ),

      watcherMail: 'your_mail@example.com',
    );

    final TalsecCallback callback = TalsecCallback(
      /// For Android
      androidCallback: AndroidCallback(
        onRootDetected: () => changeState(),
        onEmulatorDetected: () => changeState(),
        onHookDetected: () => changeState(),
        onTamperDetected: () => changeState(),
        onDeviceBindingDetected: () => changeState(),
        onUntrustedInstallationDetected: () => changeState(),
      ),

      /// For iOS
      iosCallback: IOSCallback(
        onSignatureDetected: () => changeState(),
        onRuntimeManipulationDetected: () => changeState(),
        onJailbreakDetected: () => changeState(),
        onPasscodeDetected: () => changeState(),
        onSimulatorDetected: () => changeState(),
        onMissingSecureEnclaveDetected: () => changeState(),
        onDeviceChangeDetected: () => changeState(),
        onDeviceIdDetected: () => changeState(),
        onUnofficialStoreDetected: () => changeState(),
      ),

      /// Debugger is common for both platforms
      onDebuggerDetected: () => changeState(),
    );

    TalsecApp app = TalsecApp(config: config, callback: callback);
    app.start();
  }

  void changeState() {
    setState(() {
      isSecure = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Security"),
        ),
        body: isSecure
            ? const Center(child: Text("Content"))
            : AlertDialog(
                title: const Text("Important Alert!"),
                content: const Text("Your system has been compromised!"),
                actions: [
                  ElevatedButton(
                      onPressed: () {
                        SystemChannels.platform
                            .invokeMethod('SystemNavigator.pop');
                      },
                      child: const Text("Exit"))
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: changeState,
          child: const Icon(Icons.settings),
        ),
      ),
    );
  }
}
