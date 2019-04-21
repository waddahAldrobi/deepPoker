//
//  PokerRankClassifier.swift
//  deepPoker
//
//  Created by Waddah Al Drobi on 2019-04-21.
//  Copyright © 2019 Waddah Al Drobi. All rights reserved.
//

import Foundation

enum Suit: Int {
    case spades, hearts, clubs, diamonds
}

enum Rank: Int {
    case two = 2, three=3, four=4, five=5, six, seven, eight, nine, ten
    case jack, queen, king, ace
}

struct Card {
    let rank: Rank
    let suit: Suit
}

enum PokerHandRank: Int {
    case highCard = 1
    case onePair
    case twoPair
    case threeOfAKind
    case straight
    case flush
    case fullHouse
    case fourOfAKind
    case straightFlush
    case royalFlush
}

struct PokerHand {
    let ranks: [Rank: Int]
    let suits: [Suit: Int]
    
    init(cards: [Card]) {
        if cards.count != 5 {
            fatalError("Wrong number of cards!")
        }
        var ranks = [Rank: Int]()
        var suits = [Suit: Int]()
        for card in cards {
            ranks[card.rank] = ranks[card.rank] != nil ? ranks[card.rank]! + 1 : 1
            suits[card.suit] = suits[card.suit] != nil ? suits[card.suit]! + 1 : 1
        }
        self.ranks = ranks
        self.suits = suits
    }
    
    func handRank() -> (String, Int) {
        let tripleRanks = ranks.values.filter { $0 == 3 }
        let doubleRanks = ranks.values.filter { $0 == 2 }
        
        if suits.keys.count == 1 && ranks.keys.lazy.filter({[.ten,.jack,.queen,.king,.ace].contains($0)}).count == 5 {
            return ("Royal Flush", 10)
        }
        if isStraight() && isFlush() {
            return ("Straight Flush", 9)
        }
        if ranks.values.contains(4) {
            return ("Four of a Kind", 8)
        }
        if tripleRanks.count == 1 && doubleRanks.count == 1 {
            return ("Full House", 7)
        }
        if isFlush() {
            return ("Flush", 6)
        }
        if isStraight() {
            return ("Straight", 5)
        }
        if ranks.values.contains(3) {
            return ("Three of a kind", 4)
        }
        if doubleRanks.count == 2 {
            return ("Two Pair", 3)
        }
        if doubleRanks.count == 1 {
            return ("Pair", 2)
        }
        return ("High Card", 1)
    }
    
    func isFlush() -> Bool {
        return suits.keys.count == 1
    }
    
    func isStraight() -> Bool {
        guard ranks.keys.count == 5 else {
            return false
        }
        let sortedRanks = ranks.keys.map({$0.rawValue}).sorted(by: >)
        return sortedRanks[0] - sortedRanks[4] == 4
    }
}

//===============================================
func runHandClassifier(c1:String, c2:String, c3:String, c4:String, c5:String) {
        
        func cardFromString(_ string: String) -> Card {
//            let rankString = string.substring(with: (string.startIndex ..< string.index(string.startIndex, offsetBy: 1)))
//            let suitString = string.substring(with: (string.index(string.startIndex, offsetBy: 1) ..< string.endIndex))
            
            let rankString = string[string.index(string.startIndex, offsetBy: 1) ..< string.endIndex]
            let suitString = String(string.first!)
            
            let suit: Suit
            switch suitString {
            case "D": suit = .diamonds
            case "H": suit = .hearts
            case "C": suit = .clubs
            case "S": suit = .spades
            default: suit = .diamonds
            }
            
            let rank: Rank
            switch rankString {
            case "10": rank = .ten
            case "9": rank = .nine
            case "8": rank = .eight
            case "7": rank = .seven
            case "6": rank = .six
            case "5": rank = .five
            case "4": rank = .four
            case "3": rank = .three
            case "2": rank = .two
            case "j": rank = .jack
            case "q": rank = .queen
            case "k": rank = .king
            case "a": rank = .ace
            default:
                rank = Rank(rawValue: (rankString as NSString).integerValue)!
            }
            return Card(rank: rank, suit: suit)
    }
    
    
    
    let cards = [
        cardFromString(c1),
        cardFromString(c2),
        cardFromString(c3),
        cardFromString(c4),
        cardFromString(c5),
    ]
    
    let hand = PokerHand(cards: cards)

    if CardsDataSingleton.shared.handsClassifications[hand.handRank().0] == nil {
        CardsDataSingleton.shared.handsClassifications[hand.handRank().0] = hand.handRank().1
    }
    
    print("hand:", hand.handRank())
}



/*
 In the card game poker, a hand consists of five cards and are ranked, from lowest to highest, in the following way:
 
 + High Card: Highest value card.
 + One Pair: Two cards of the same value.
 + Two Pairs: Two different pairs.
 + Three of a Kind: Three cards of the same value.
 + Straight: All cards are consecutive values.
 + Flush: All cards of the same suit.
 + Full House: Three of a kind and a pair.
 + Four of a Kind: Four cards of the same value.
 + Straight Flush: All cards are consecutive values of same suit.
 + Royal Flush: Ten, Jack, Queen, King, Ace, in same suit.
 The cards are valued in the order:
 2, 3, 4, 5, 6, 7, 8, 9, 10, Jack, Queen, King, Ace.
 
 If two players have the same ranked hands then the rank made up of the highest value wins; for example, a pair of eights beats a pair of fives (see example 1 below). But if two ranks tie, for example, both players have a pair of queens, then highest cards in each hand are compared (see example 4 below); if the highest cards tie then the next highest cards are compared, and so on.
 */
