import 'dart:math';

int counter = 0;
List<int> _generatedNumbers = [];

getRandomNumber() {
  counter++;
  int randomNumber;

  do {
    if (counter % 3 == 0) {
      randomNumber = 1 + Random().nextInt(100);
    } else {
      randomNumber = 60 + Random().nextInt(61);
    }
  } while (_generatedNumbers.contains(randomNumber) &&
      _generatedNumbers.length <= 120);
  _generatedNumbers.add(randomNumber);

  return randomNumber;
}
