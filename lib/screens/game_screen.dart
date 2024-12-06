import 'package:flutter/material.dart';
import '../models/uno_card.dart';
import '../services/game_service.dart';
import '../widgets/player_card.dart';
import '../widgets/computer_card.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameService _gameService = GameService();
  int playerScore = 0;
  int computerScore = 0;

  @override
  void initState() {
    super.initState();
    _gameService.initializeGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '"O"-no Game',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showComputerHand,
            icon: const Icon(Icons.bug_report),
            color: Colors.white,
            tooltip: 'Show computer cards',
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: Text(
                'Score: $playerScore - $computerScore',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              showMenu(
                context: context,
                position: const RelativeRect.fromLTRB(100, 50, 0, 0),
                items: [
                  PopupMenuItem(
                    value: 'restart',
                    child: const Text('Restart Game'),
                    onTap: () => _showRestartDialog(),
                  ),
                  PopupMenuItem(
                    value: 'reset_scores',
                    child: const Text('Reset Scores'),
                    onTap: () {
                      setState(() {
                        playerScore = 0;
                        computerScore = 0;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Scores reset!')),
                        );
                      });
                    },
                  ),
                  PopupMenuItem(
                    value: 'rules',
                    child: const Text('Show Rules'),
                    onTap: () => _showRulesDialog(),
                  ),
                ],
              );
            },
            icon: const Icon(Icons.menu),
            color: Colors.white,
            tooltip: 'Menu',
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/assets/bgCard.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Computer's hand at top
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 100,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _gameService.computerHand.map((card) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: ComputerCard(),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),

                // Middle section with discard pile
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDiscardPile(),
                      const SizedBox(height: 20),
                      _buildDrawCardButton(),
                    ],
                  ),
                ),

                // Player's hand at bottom
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 100,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _gameService.playerHand.map((card) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: PlayerCard(
                              card: card,
                              onTap: () => _onCardTapped(card),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onCardTapped(UnoCard card) {
    if (!_gameService.isPlayerTurn) return;

    if (_gameService.canPlayCard(card)) {
      setState(() {
        _gameService.playCard(card, true);
        _gameService.handleTurnChange();

        // Check for winner after player's move
        _checkWinner();

        // Only do computer's turn if it wasn't skipped and no winner yet
        if (!_gameService.isPlayerTurn && _gameService.playerHand.isNotEmpty) {
          _computerTurn();
        }
      });
    }
  }

  void _computerTurn() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        UnoCard? computerCard = _gameService.computerPlay();
        if (computerCard != null) {
          _gameService.playCard(computerCard, false);

          // Show what card computer played
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Computer played ${computerCard.color} ${computerCard.value}'),
              duration: const Duration(seconds: 1),
            ),
          );
        } else {
          // Show that computer had to draw
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Computer had to draw a card!'),
              duration: Duration(seconds: 1),
            ),
          );
        }

        _gameService.handleTurnChange();
        _checkWinner();
      });
    });
  }

  void _checkWinner() {
    String? winner;
    if (_gameService.playerHand.isEmpty) {
      winner = "Player";
      playerScore++;
    } else if (_gameService.computerHand.isEmpty) {
      winner = "Computer";
      computerScore++;
    }

    if (winner != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Game Over!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$winner wins!'),
                const SizedBox(height: 10),
                Text('Score: $playerScore - $computerScore'),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Play Again'),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    _gameService.initializeGame();
                  });
                },
              ),
            ],
          );
        },
      );
    }
  }

  Widget _buildDrawCardButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3D3D3D),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: _drawCard,
      child: const Text(
        'Draw Card',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _drawCard() {
    if (!_gameService.isPlayerTurn) return;

    setState(() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Drew a card!'),
          duration: Duration(seconds: 1),
        ),
      );

      _gameService.drawCard(true);
      _gameService.handleTurnChange();

      if (!_gameService.isPlayerTurn) {
        _computerTurn();
      }
    });
  }

  void _showRestartDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Restart Game?'),
          content: const Text(
              'Are you sure you want to restart? Current game progress will be lost.'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Restart'),
              onPressed: () {
                Navigator.of(context).pop();
                _restartGame();
              },
            ),
          ],
        );
      },
    );
  }

  void _restartGame() {
    setState(() {
      _gameService.initializeGame();
      // Optionally reset scores
      // playerScore = 0;
      // computerScore = 0;

      // Show restart message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Game restarted!'),
          duration: Duration(seconds: 1),
        ),
      );
    });
  }

  void _showComputerHand() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Computer\'s Hand (Debug)'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Computer has ${_gameService.computerHand.length} cards:'),
                const SizedBox(height: 8),
                ..._gameService.computerHand
                    .map(
                      (card) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text('• ${card.color} ${card.value}'),
                      ),
                    )
                    .toList(),
                const Divider(),
                Text(
                  'Top card on pile: ${_gameService.discardPile.last.color} ${_gameService.discardPile.last.value}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showRulesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('UNO Game Rules'),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('1. The game is played with a deck of 108 cards.'),
                Text('2. Each player starts with 7 cards.'),
                Text(
                    '3. Players take turns playing cards that match the top card of the discard pile by color or number.'),
                Text('4. Special cards include:'),
                Text(
                    '   - Draw Two: Next player draws 2 cards and skips their turn.'),
                Text('   - Skip: Next player loses their turn.'),
                Text('   - Reverse: Reverses the direction of play.'),
                Text(
                    '   - Wild: Player can choose any color to continue play.'),
                Text(
                    '   - Wild Draw Four: Next player draws 4 cards and skips their turn.'),
                Text('5. If a player has one card left, they must say "UNO!"'),
                Text('6. The first player to play all their cards wins!'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDiscardPile() {
    if (_gameService.discardPile.isEmpty) return Container();
    return PlayerCard(card: _gameService.discardPile.last);
  }
}
