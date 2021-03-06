import 'dart:math';
import 'package:mult_tables/model/enumLevel.dart';

class Quiz {
  final bool allow12and21;
  final int countOfQuestions;
  final Level levelOfQuiz;
  final OpType operation;

  var _result; //= getListForQuiz(5, 7, 0, true);
  var _firstListOfNumbers, _secondListOfNumbers;

  List<Question> questions = [];

  Quiz(this.countOfQuestions, this.levelOfQuiz, this.allow12and21,
      {this.operation = OpType.Multiply}) {
    populateQuestions();
  }

  void populateQuestions() {
    _result = _getQuestionsForQuiz();

    _firstListOfNumbers = _result[0];
    _secondListOfNumbers = _result[1];

    for (int count = 0; count < countOfQuestions; count++) {
      questions.add(Question(
          _firstListOfNumbers[count], _secondListOfNumbers[count],
          operation: operation));
    }
  }

  int get totalTime {
    int sum = 0;
    questions.forEach((e) => sum += e?.time ?? 0);
    return sum;
  }

  int get totalScore {
    int sum = 0;
    questions.forEach((e) => sum += e.rightAns == e.selected ? 1 : 0);
    return sum;
  }

// @param const countOfQuestions = 5; This is the length of the List returned
// const levelOfQuiz = enum.index *10 + 10; //random generator upto this level (not inclusive). Max number in the quiz
// const startLevel = 0; //lowest digit in the quiz, Min number in the quiz
// const allow12and21 = true;
  List<List> _getQuestionsForQuiz() {
    var firstListOfNums = <int>[];
    var secondListOfNums = <int>[];

    var _resultList = <String>[];

    var _num1, _num2, _comb;
    int _effort = 0;

    int generateNumsFrom =
        levelOfQuiz == Level.Easy ? 0 : levelOfQuiz == Level.Medium ? 5 : 8;
    int generateNumsUpto =
        levelOfQuiz == Level.Easy ? 5 : levelOfQuiz == Level.Medium ? 12 : 15;

    if ((generateNumsFrom + 3) > generateNumsUpto) {
      generateNumsUpto = generateNumsUpto + 3;
    }

    while (firstListOfNums.length < countOfQuestions && _effort < 100) {
      _effort++;
      _num1 = _getRandomNumberInRange(generateNumsFrom, generateNumsUpto);

      _num2 = _getRandomNumberInRange(generateNumsFrom, generateNumsUpto);

      //Prevent Div by 0
      if (operation == OpType.Divide) {
        _num2 == 0 ? _num2 = _num2 + _num1 + 1 : print('no change');
      }

      //No negative numbers in subtraction
      if (operation == OpType.Subtract) {
        if (_num2 > _num1) {
          int _temp = _num1;
          _num1 = _num2;
          _num2 = _temp;
        }
      }
      if (allow12and21) {
        _comb = '$_num1$_num2';
      } else {
        if (_num1 > _num2) {
          _comb = '$_num2$_num1';
        }
      }
      if (!_resultList.contains(_comb)) {
        _resultList.add(_comb);
        firstListOfNums.add(_num1);
        secondListOfNums.add(_num2);
      }
    }

    if (_effort > 98) {
      print(
          "Possible error , effor at $_effort, l1 = $firstListOfNums , l2 = $secondListOfNums");
    }

    return [firstListOfNums, secondListOfNums];
  }

  int _getRandomNumberInRange(int generateNumsFrom, int generateNumsUpto) {
    final _random = Random();
    int range = generateNumsUpto - generateNumsFrom;
    int num = _random.nextInt(range) + generateNumsFrom;
    return num;
  }
}

class Question {
  int num1, num2;
  OpType operation;
  int selected;
  int time;
  List<int> answers;

  Question(this.num1, this.num2, {this.operation = OpType.Multiply});

  int get rightAns {
    int result = 0;
    if (operation == OpType.Multiply) {
      result = num1 * num2;
    } else if (operation == OpType.Add) {
      result = num1 + num2;
    } else if (operation == OpType.Subtract) {
      result = num1 - num2;
    } else if (operation == OpType.Divide) {
      result = num1 ~/ num2;
    }
    return result;
  }

  List<int> getAllPossibleAnswers() {
    if (answers == null) {
      answers = _getPossibleResults(num1, num2);
    }
    return answers;
  }

  List<int> _getPossibleResults(final int firstNo, final int secondNo) {
    List<int> resultsUpdated = [];
    final int answer = rightAns;

    const int listLength = 4;
    List<int> results = List<int>(4);

    results[0] = answer + 5;
    results[1] = answer == 0
        ? firstNo * secondNo + Random().nextInt(secondNo + listLength)
        : answer > 30 ? answer - 10 : answer - 1;
    results[2] = answer;
    results[3] = answer + 10;

    //make the answers more difficult by ensuring the last digit is the same as the answer
    if (answer > 30) {
      int modified;
      String ans = answer.toString().substring(answer.toString().length - 1);
      results.forEach((element) {
        modified = element;
        if (element > 9) {
          modified = int.parse(
              element.toString().substring(0, element.toString().length - 1) +
                  ans);
        }
        if (results.contains(modified)) {
          resultsUpdated.add(element);
        } else {
          resultsUpdated.add(modified);
        }
      });

      if (results.length == resultsUpdated.length) {
        results = resultsUpdated;
      }
    }

    //ensure list has unique numbers - no repeats
    //remove duplicate
    List<int> uniqueResults = [
      ...{...results}
    ];

    if (results.length != uniqueResults.length) {
      int noOfDuplicates = results.length - uniqueResults.length;
      int value = _getValue(uniqueResults);

      for (int i = 0; i < noOfDuplicates; i++) {
        if (!uniqueResults.contains(value)) {
          uniqueResults.add(value);
          value = _getValue(uniqueResults);
        } else {
          var nextInt = uniqueResults.reduce(max) + 10;
          uniqueResults.add(nextInt);
        }
      }
    }

    int right = answer;
    if (!uniqueResults.contains(answer)) {
      int index = Random().nextInt(3);
      uniqueResults[index] = right;
    }

    uniqueResults.shuffle();

    return uniqueResults;
  }

  int _getValue(List<int> uniqueResults) {
    int value;
    int max1 = uniqueResults.reduce(max);
    int min1 = uniqueResults.reduce(min);
    if (min1 > 10) {
      value = min1 - Random().nextInt(3) - 2;
    } else {
      value = max1 + Random().nextInt(5) + 5;
    }
    return value;
  }
}
