import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'constants.dart';
import 'card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'icon_content.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _hasSpeech = false;
  bool _stressTest = false;
  double level = 0.0;
  int _stressLoops = 0;
  String lastWords = "";
  String lastError = "";
  String lastStatus = "";
  String _currentLocaleId = "";
  List<LocaleName> _localeNames = [];
  final SpeechToText speech = SpeechToText();

  @override
  void initState() {
    super.initState();
  }

  Future<void> initSpeechState() async {
    bool hasSpeech = await speech.initialize(
        onError: errorListener, onStatus: statusListener);
    if (hasSpeech) {
      _localeNames = await speech.locales();

      var systemLocale = await speech.systemLocale();
      _currentLocaleId = systemLocale.localeId;
    }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Convert your voice to text'),

      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0,10.0,8.0,8.0),
            child: Container(
              child: Text('Single Tap on mic to select the language.',style: kLabelTextStyle,),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0,8.0,8.0,10.0),
            child: Container(

                child: Text('Then double Tap on mic to start recording',style: kLabelTextStyle,),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                   onTap: speech.isListening ? stopListening : null,


                    child: ReusableCard(
                      cardChild: IconContent(
                        icon: FontAwesomeIcons.stop,
                        label: 'Stop',
                      ),
                    )
                ),
              ),
              Expanded(
                child: GestureDetector(
                    onTap: _hasSpeech ? null : initSpeechState,
                    onDoubleTap: !_hasSpeech || speech.isListening ? null : startListening,
                    child: ReusableCard(
                      cardChild: IconContent(
                        icon: FontAwesomeIcons.microphone,
                        label: 'Start',
                      ),
                    )
                ),
              ),
              Expanded(
                child: GestureDetector(
                    onTap: speech.isListening ? cancelListening : null,
                    child: ReusableCard(
                      cardChild: IconContent(
                        icon: FontAwesomeIcons.times,
                        label: 'Cancel',
                      ),
                    )
                ),
              ),
            ],

          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              DropdownButton(
                onChanged: (selectedVal) => _switchLang(selectedVal),
                value: _currentLocaleId,
                items: _localeNames
                    .map(
                      (localeName) => DropdownMenuItem
                        (
                    value: localeName.localeId,
                    child: Text(localeName.name),
                  ),
                )
                    .toList(),
              ),
            ]


          ),
          Container(
            width: MediaQuery.of(context).size.width *0.7,
            height: 180.0,

            child: Text(lastWords, textAlign: TextAlign.center,),
            decoration: BoxDecoration(
                color: Color(0xFF5a3d5c),
                borderRadius: BorderRadius.circular(6.0)
            ),


          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 8.0),
              child: Column(
                children: <Widget>[
                  Center(
                    child: Text(
                      'Error Status',
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ),
                  Center(
                    child: Text(lastError),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            color: Colors.white,
            child: Center(
              child: speech.isListening
                  ? Text(
                "I'm listening...",
                style: kListeningStyle
              )
                  : Text(
                'Not listening',
                  style: kListeningStyle
              ),
            ),
          ),



        ],
      ),
    );
  }








  void changeStatusForStress(String status) {
    if (!_stressTest) {
      return;
    }
    if (speech.isListening) {
      stopListening();
    } else {
      if (_stressLoops >= 100) {
        _stressTest = false;
        print("Stress test complete.");
        return;
      }
      print("Stress loop: $_stressLoops");
      ++_stressLoops;
      startListening();
    }
  }

  void startListening() {
    lastWords = "";
    lastError = "";
    speech.listen(
        onResult: resultListener,
        listenFor: Duration(seconds: 30),
        localeId: _currentLocaleId,
        onSoundLevelChange: soundLevelListener,
        cancelOnError: false,
        partialResults: true);
    setState(() {});
  }

  void stopListening() {
    speech.stop();
    setState(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    speech.cancel();
    setState(() {
      level = 0.0;
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      lastWords = "${result.recognizedWords} - ${result.finalResult}";
    });
  }

  void soundLevelListener(double level) {
    setState(() {
      this.level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    setState(() {
      lastError = "${error.errorMsg} - ${error.permanent}";
    });
  }

  void statusListener(String status) {
    changeStatusForStress(status);
    setState(() {
      lastStatus = "$status";
    });
  }

  _switchLang(selectedVal) {
    setState(() {
      _currentLocaleId = selectedVal;
    });
    print(selectedVal);
  }
}



