//
//  GameMode.swift
//  TowerForge
//
//  Created by Vanessa Mae on 27/03/24.
//

import Foundation

protocol GameMode {
    var modeName: String { get }
    var modeDescription: String { get }
    var gameProps: [GameProp] { get }
    var gameState: GameState { get set }
    func startGame()
    func pauseGame()
    func winGame()
    func endGame()
    func resumeGame()
}