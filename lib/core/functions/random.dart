import 'dart:math';

int counter = 0;
List<int> _generatedNumbers = [25, 27, 64, 37];

getRandomNumber() {
  counter++;
  int randomNumber;

  do {
    if (counter % 3 == 0) {
      randomNumber = 1 + Random().nextInt(150);
    } else {
      randomNumber = 75 + Random().nextInt(76);
    }
  } while (_generatedNumbers.contains(randomNumber) &&
      _generatedNumbers.length <= 120);
  _generatedNumbers.add(randomNumber);

  return randomNumber;
}
