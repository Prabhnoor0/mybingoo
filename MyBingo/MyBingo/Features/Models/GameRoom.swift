//
//  GameRoom.swift
//  MyBingo
//
//  Created by Prabhnoor Kaur on 05/08/25.
//

import Foundation

struct GameRoom: Codable, Identifiable {
    let id: String
    let hostId: String
    let maxPlayers: Int
    var gameState: GameState
    var players: [String: Player]
    var currentNumber: Int?
    var calledNumbers: [Int]
    var gameWinner: String?
    let createdAt: Date
    
    enum GameState: String, Codable, CaseIterable {
        case waiting = "waiting"
        case playing = "playing"
        case finished = "finished"
    }
    
    init(hostId: String, maxPlayers: Int = 8) {
        self.id = UUID().uuidString.prefix(6).uppercased().replacingOccurrences(of: "-", with: "")
        self.hostId = hostId
        self.maxPlayers = maxPlayers
        self.gameState = .waiting
        self.players = [:]
        self.currentNumber = nil
        self.calledNumbers = []
        self.gameWinner = nil
        self.createdAt = Date()
    }
    
    var canStartGame: Bool {
        return players.count >= 2 && players.values.allSatisfy { $0.isReady }
    }
    
    var readyPlayersCount: Int {
        return players.values.filter { $0.isReady }.count
    }
}
