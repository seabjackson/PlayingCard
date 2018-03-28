//
//  ViewController.swift
//  PlayingCard
//
//  Created by Seab Jackson on 3/7/18.
//  Copyright © 2018 Seab Jackson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var deck = PlayingCardDeck()
    
    @IBInspectable
    @IBOutlet private var cardViews: [PlayingCardView]!
    
    lazy var animator = UIDynamicAnimator(referenceView: view)
    lazy var cardBehavior = CardBehavior(in: animator)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var cards = [PlayingCard]()
        for _ in 1...((cardViews.count + 1) / 2) {
            let card = deck.draw()!
            cards += [card, card]
        }
        
        for cardView in cardViews {
            cardView.isFaceUp = false
            let card = cards.remove(at: cards.count.arc4Random)
            cardView.rank = card.rank.order
            cardView.suit = card.suit.rawValue
            cardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard(_:))))
            cardBehavior.addItem(cardView)
            
        }
    }
    
    private var faceUpCardViews: [PlayingCardView] {
        return cardViews.filter {
            $0.isFaceUp &&
            !$0.isHidden &&
            $0.transform != CGAffineTransform.identity.scaledBy(x: Constants.Enlargen, y: Constants.Enlargen) &&
            $0.alpha == 1
        }
    }
    
    private var faceUpCardViewsMatch: Bool {
        return faceUpCardViews.count == 2 &&
            faceUpCardViews[0].rank == faceUpCardViews[1].rank &&
            faceUpCardViews[0].suit == faceUpCardViews[1].suit
    }
    
    @objc func flipCard(_ recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            if let chosenCard = recognizer.view as? PlayingCardView , faceUpCardViews.count < 2 {
                cardBehavior.removeItem(chosenCard)
                UIView.transition(with: chosenCard, duration: 0.6, options: .transitionFlipFromLeft, animations: {
                    chosenCard.isFaceUp = !chosenCard.isFaceUp
                }, completion: { finished in
                    let cardsToAnimate = self.faceUpCardViews
                    if self.faceUpCardViewsMatch {
                        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.6, delay: 0, options: [], animations: {
                            cardsToAnimate.forEach { $0.transform = CGAffineTransform.identity.scaledBy(x: Constants.Enlargen , y: Constants.Enlargen) }
                        }, completion: { (position) in
                            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.75, delay: 0, options: [], animations: {
                                cardsToAnimate.forEach {
                                    $0.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                                    $0.alpha = 0
                                }
                            }, completion: { position in
                                cardsToAnimate.forEach {
                                    $0.isHidden = true
                                    $0.alpha = 1
                                    $0.transform = .identity
                                }
                            })
                        })
                    } else if self.faceUpCardViews.count == 2 {
                        self.faceUpCardViews.forEach { cardView in
                            UIView.transition(with: cardView, duration: 0.6, options: .transitionFlipFromLeft, animations: {
                                cardView.isFaceUp = false
                            }, completion: { finished in
                                self.cardBehavior.addItem(cardView)
                            })
                        }
                    } else {
                        if !chosenCard.isFaceUp {
                            self.cardBehavior.addItem(chosenCard)  
                        }
                    }
                })
            }
        default: break
        }
    }
    
}

extension CGFloat {
    var arc4Random: CGFloat {
        return self > 0.0 ? CGFloat(arc4random_uniform(UInt32(self))) : 0.0
    }
}


