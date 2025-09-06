import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(FlashcardApp());
}

class Flashcard {
  final String question;
  final String answer;

  Flashcard({required this.question, required this.answer});
}

class FlashcardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcards',
      theme: ThemeData(
        primaryColor: const Color.fromARGB(255, 170, 29, 76),
        fontFamily: "Baskerville Old Face", // will work if font is available
      ),
      home: FlashcardHome(),
    );
  }
}

class FlashcardHome extends StatefulWidget {
  @override
  _FlashcardHomeState createState() => _FlashcardHomeState();
}

class _FlashcardHomeState extends State<FlashcardHome> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    FlashcardScreen(),
    LearnedScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: "Flashcards",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: "Learned",
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class FlashcardScreen extends StatefulWidget {
  static List<Flashcard> flashcards = [];
  static List<Flashcard> learned = [];

  @override
  _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();

  int _currentCardIndex = 0;

  void _addFlashcard() {
    if (_questionController.text.isEmpty || _answerController.text.isEmpty) {
      return;
    }
    setState(() {
      FlashcardScreen.flashcards.add(
        Flashcard(
          question: _questionController.text,
          answer: _answerController.text,
        ),
      );
      _questionController.clear();
      _answerController.clear();
    });
    Navigator.pop(context);
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add Flashcard', textAlign: TextAlign.center),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _questionController,
                decoration: InputDecoration(labelText: 'Question'),
              ),
              TextField(
                controller: _answerController,
                decoration: InputDecoration(labelText: 'Answer'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addFlashcard,
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _markAsLearned() {
    setState(() {
      if (FlashcardScreen.flashcards.isNotEmpty) {
        FlashcardScreen.learned.add(
            FlashcardScreen.flashcards[_currentCardIndex]);
        FlashcardScreen.flashcards.removeAt(_currentCardIndex);
        if (_currentCardIndex >= FlashcardScreen.flashcards.length) {
          _currentCardIndex =
              (FlashcardScreen.flashcards.length - 1).clamp(0, 9999);
        }
      }
    });
  }

  void _nextCard() {
    setState(() {
      if (_currentCardIndex < FlashcardScreen.flashcards.length - 1) {
        _currentCardIndex++;
      }
    });
  }

  void _previousCard() {
    setState(() {
      if (_currentCardIndex > 0) {
        _currentCardIndex--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 227, 214, 213), // baby pink
      appBar: AppBar(
        title: Text('Flashcards', textAlign: TextAlign.center),
        centerTitle: true,
      ),
      body: FlashcardScreen.flashcards.isEmpty
          ? Center(child: Text("No flashcards yet. Add some!"))
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Card ${_currentCardIndex + 1} of ${FlashcardScreen.flashcards.length}",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink[800]),
                ),
                SizedBox(height: 20),
                FlashcardWidget(
                  flashcard:
                      FlashcardScreen.flashcards[_currentCardIndex],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _previousCard,
                      child: Text("Previous"),
                    ),
                    ElevatedButton(
                      onPressed: _markAsLearned,
                      child: Text("Mark as Learned"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[300],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _nextCard,
                      child: Text("Next"),
                    ),
                  ],
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}

class FlashcardWidget extends StatefulWidget {
  final Flashcard flashcard;

  FlashcardWidget({required this.flashcard});

  @override
  _FlashcardWidgetState createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget> {
  bool _showQuestion = true;

  void _toggleCard() {
    setState(() {
      _showQuestion = !_showQuestion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleCard,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);

          return AnimatedBuilder(
            animation: rotateAnim,
            builder: (context, child) {
              final isUnder = (ValueKey(_showQuestion) != child!.key);
              var tilt = (animation.value - 0.5).abs() - 0.5;
              tilt *= isUnder ? -0.003 : 0.003;

              return Transform(
                transform: Matrix4.rotationY(rotateAnim.value)
                  ..setEntry(3, 0, tilt),
                alignment: Alignment.center,
                child: child,
              );
            },
            child: child,
          );
        },
        child: Card(
          key: ValueKey(_showQuestion),
          color: Color(0xFFFFF5E1), // cream/orangish background
          shape: RoundedRectangleBorder(),
          elevation: 6,
          margin: EdgeInsets.all(16),
          child: Container(
            padding: EdgeInsets.all(20),
            height: 180,
            alignment: Alignment.center,
            child: Text(
              _showQuestion
                  ? widget.flashcard.question
                  : widget.flashcard.answer,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: "Baskerville Old Face",
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class LearnedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFE4E1), // baby pink
      appBar: AppBar(
        title: Text("Learned Flashcards"),
        centerTitle: true,
      ),
      body: FlashcardScreen.learned.isEmpty
          ? Center(child: Text("No learned flashcards yet."))
          : ListView.builder(
              itemCount: FlashcardScreen.learned.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.green[50],
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      FlashcardScreen.learned[index].question,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      FlashcardScreen.learned[index].answer,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
