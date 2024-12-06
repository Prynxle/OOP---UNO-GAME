import '../models/uno_card.dart';

class GameService {
  List<UnoCard> deck = [];
  List<UnoCard> playerHand = [];
  List<UnoCard> computerHand = [];
  List<UnoCard> discardPile = [];
  bool isPlayerTurn = true;
  bool skipNextTurn = false;
  int cardsToDraw = 0;
  String? selectedWildColor;

  void initializeGame() {
    // Create deck
    final colors = ['Red', 'Blue', 'Green', 'Yellow'];
    final numbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    final actions = ['Skip', 'Reverse', 'Draw Two'];

    // Add number cards
    for (var color in colors) {
      for (var number in numbers) {
        deck.add(UnoCard(color: color, value: number));
        if (number != '0') {
          // Add duplicates except for 0
          deck.add(UnoCard(color: color, value: number));
        }
      }
    }

    // Add action cards
    for (var color in colors) {
      for (var action in actions) {
        deck.add(UnoCard(color: color, value: action, isActionCard: true));
        deck.add(UnoCard(color: color, value: action, isActionCard: true));
      }
    }

    // // Add wild cards
    // for (var i = 0; i < 4; i++) {
    //   deck.add(UnoCard(color: 'Black', value: 'Wild', isWild: true));
    //   deck.add(UnoCard(color: 'Black', value: 'Wild Draw Four', isWild: true));
    // }

    // Shuffle deck
    deck.shuffle();

    // Deal initial cards
    playerHand = deck.take(7).toList();
    deck.removeRange(0, 7);
    computerHand = deck.take(7).toList();
    deck.removeRange(0, 7);

    // Start discard pile
    discardPile.add(deck.first);
    deck.removeAt(0);
  }

  bool canPlayCard(UnoCard card) {
    if (discardPile.isEmpty) return true;

    UnoCard topCard = discardPile.last;
    return card.isWild ||
        card.color == topCard.color ||
        card.value == topCard.value;
  }

  void playCard(UnoCard card, bool isPlayer) {
    if (isPlayer) {
      playerHand.remove(card);
    } else {
      computerHand.remove(card);
    }
    discardPile.add(card);

    // Handle action cards
    if (card.value == 'Draw Two') {
      cardsToDraw = 2;
    } else if (card.value == 'Wild Draw Four') {
      cardsToDraw = 4;
      // Computer automatically selects color
      if (!isPlayer) {
        selectedWildColor = _selectComputerColor();
      }
    }
  }

  String _selectComputerColor() {
    Map<String, int> colorCounts = {
      'Red': 0,
      'Blue': 0,
      'Green': 0,
      'Yellow': 0,
    };

    for (var card in computerHand) {
      if (colorCounts.containsKey(card.color)) {
        colorCounts[card.color] = colorCounts[card.color]! + 1;
      }
    }

    return colorCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  //Handing drawing of cards
  void handleTurnChange() {
    if (cardsToDraw > 0) {
      if (isPlayerTurn) {
        // ComputerHand needs to draw
        for (int i = 0; i < cardsToDraw; i++) {
          drawCard(false);
        }
      } else {
        // PlayerCard needs to draw
        for (int i = 0; i < cardsToDraw; i++) {
          drawCard(true);
        }
      }
      cardsToDraw = 0;
    }

    // Change turns
    isPlayerTurn = !isPlayerTurn;
  }

  void drawCard(bool isPlayer) {
    if (deck.isEmpty) {
      deck = discardPile.sublist(0, discardPile.length - 1);
      discardPile = [discardPile.last];
      deck.shuffle();
    }

    if (isPlayer) {
      playerHand.add(deck.first);
    } else {
      computerHand.add(deck.first);
    }
    deck.removeAt(0);
  }

  UnoCard? computerPlay() {
    // Check all computer's cards for a valid play
    for (var card in computerHand) {
      if (canPlayCard(card)) {
        return card;
      }
    }

    // If no valid card is found, draw a card and try to play it
    if (deck.isNotEmpty) {
      drawCard(false); // Draw a card for computer

      // Try to play the newly drawn card
      var newCard = computerHand.last;
      if (canPlayCard(newCard)) {
        return newCard;
      }
    }

    return null; // No playable card even after drawing
  }
}
