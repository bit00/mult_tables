import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:mult_tables/model/enumLevel.dart';
import 'package:mult_tables/model/quizData.dart';
import 'package:mult_tables/pages/homePageWidget.dart';
import 'package:mult_tables/pages/quizLevelsPageWidget.dart';
import 'package:mult_tables/pages/quizSettings.dart';
import 'package:nice_button/nice_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResultsPage extends StatelessWidget {
  final Quiz quiz;
  ResultsPage({Key key, @required this.quiz}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var pct = (quiz.totalScore / quiz.countOfQuestions) * 100;
    var firstColor = Color(0xff5b86e5), secondColor = Color(0xff36d1dc);
    getSettingsAndAct();
    return new WillPopScope(
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: QuizAppBar(),
        body: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            Text(
              '${getGreeting(pct)}',
              style: TextStyle(color: Colors.red, fontSize: 28,fontFamily: 'Fondamento',),
            ),
            RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    text: '\n You have scored  ',
                    style: TextStyle(color: Colors.black, fontSize: 22, fontFamily: 'DancingScript',),
                    children: <TextSpan>[
                      TextSpan(
                        text: '$pct%',
                        style: TextStyle(color: Colors.lime, fontSize: 33,fontFamily: 'Fondamento',),
                      ),
                      TextSpan(
                        text: ' in the Quiz, ',
                        style: TextStyle(color: Colors.black, fontSize: 22),
                      ),
                      TextSpan(
                        text: '\n\n Results : ',
                        style: TextStyle(color: Colors.black, fontSize: 22),
                      ),
                      TextSpan(
                        text:
                            ' ${quiz?.totalScore} ',
                        style: TextStyle(color: Colors.lime, fontSize: 33,fontFamily: 'Fondamento'),
                      ),
                      TextSpan(
                        text:
                            'right from ${quiz?.countOfQuestions} questions, completed in ',
                        style: TextStyle(color: Colors.black, fontSize: 22),
                      ),
                      TextSpan(
                        text:
                            '${quiz?.totalTime} ',
                        style: TextStyle(color: Colors.orange[300], fontSize: 33,fontFamily: 'Fondamento'),
                      ),
                      TextSpan(
                        text:
                            'seconds',
                        style: TextStyle(color: Colors.black, fontSize: 22),
                      ),
                    ])),
            SizedBox(
              height: 50,
            ),
            //Navigate to QuizPageWidget
            NiceButton(
              radius: 30,
              padding: const EdgeInsets.all(10),
              text: 'Re-try',
              icon: Icons.rotate_right,
              gradientColors: [secondColor, firstColor],
              onPressed: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => QuizLevelsPageWidget()))
                    }),
            
            
          ],
        ),
      ),
      onWillPop: () async => false,
    );
  }

  Future<QuizSettings> getSettingsAndAct() async {
    _retrieveSettings();
    _saveSettings(quiz);
    QuizSettings settings = await _retrieveSettings();
    if (QuizSettings.hasNewAllTimeTopScoreBeenSet(quiz, settings)) {
      Vibrate.vibrate();
    }
    return settings;
  }

  Future<QuizSettings> _retrieveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    QuizSettings settings = QuizSettings.from(prefs);

    print(
        'Settings, Total time Quiz attempted: ${settings.totalTimesPlayed} times. Quiz was last played on ${settings.lastPlayed} at ${settings.lastLevel} and the score was ${settings.lastScore}. The count of questions was ${settings.countOfQuestions} \n The Top score at Level Easy was ${settings.allTimeBestScoreAtEasy}, \n The Top score at Level Medium was ${settings.allTimeBestScoreAtMed}, \n The Top score at Level Difficult was ${settings.allTimeBestScoreAtDiff}.');

    return settings;
  }

  _saveSettings(Quiz quiz) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    QuizSettings settings = QuizSettings.from(prefs);

    bool newAllTimeScoreSet = false;

    print(
        'Before Quiz attempted ${settings.totalTimesPlayed} times. Quiz was last played on ${settings.lastPlayed} at ${settings.lastLevel} and the score was ${settings.lastScore}. The count of questions was ${settings.countOfQuestions} \n The Top score at Level Easy was ${settings.allTimeBestScoreAtEasy}, \n The Top score at Level Medium was ${settings.allTimeBestScoreAtMed}, \n The Top score at Level Difficult was ${settings.allTimeBestScoreAtDiff}. \n This attempt set a new Top score = $newAllTimeScoreSet');

    await prefs.setInt('totalTimesPlayed', settings.totalTimesPlayed + 1);
    await prefs.setString('lastPlayed', DateTime.now().toString());
    await prefs.setInt('lastScore', quiz.totalScore);
    await prefs.setString('lastLevel', quiz.levelOfQuiz.toString());
    await prefs.setInt('countOfQuestions', quiz.countOfQuestions);

    if (QuizSettings.hasNewAllTimeTopScoreBeenSet(quiz, settings)) {
      if (quiz.levelOfQuiz == Level.Easy) {
        await prefs.setInt('allTimeBestScoreAtEasy', quiz.totalScore);
        await prefs.setString(
            'newAllTimeScoreSetAtEasy', DateTime.now().toString());
      } else if (quiz.levelOfQuiz == Level.Medium) {
        await prefs.setInt('allTimeBestScoreAtMed', quiz.totalScore);
        await prefs.setString(
            'newAllTimeScoreSetAtMed', DateTime.now().toString());
      } else if (quiz.levelOfQuiz == Level.Difficult) {
        await prefs.setInt('allTimeBestScoreAtDiff', quiz.totalScore);
        await prefs.setString(
            'newAllTimeScoreSetAtDiff', DateTime.now().toString());
      }
    }
  }
}

String getGreeting(double pct) {
  String congrats = 'Congratulations!!!';
  String betterLuck = 'Better Luck Next Time!';
  if (pct > 50.0) {
    return congrats;
  } else {
    return betterLuck;
  }
}

//https://stackoverflow.com/questions/53411890/how-can-i-have-my-appbar-in-a-separate-file-in-flutter-while-still-having-the-wi
class QuizAppBar extends StatelessWidget implements PreferredSizeWidget {
  QuizAppBar({
    Key key,
  }) : super(key: key);

  final AppBar appBar = AppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text('Quiz Results'),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.home),
          color: Theme.of(context).backgroundColor,
          onPressed: () {
            Route route = MaterialPageRoute(
                builder: (context) => MultTablesHomePageWidget());
            Navigator.pushAndRemoveUntil(context, route, (_) => false);
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(appBar.preferredSize.height);
}

