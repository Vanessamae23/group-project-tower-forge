//
//  GameRoom.swift
//  TowerForge
//
//  Created by Vanessa Mae on 02/04/24.
//

import Foundation
import FirebaseDatabaseInternal

class GameRoom {
    private(set) var roomName: String
    private(set) var roomState: RoomState?
    private(set) var roomId: RoomId?

    private(set) var playerOne: GamePlayer?
    private(set) var playerTwo: GamePlayer?

    private let roomRef = FirebaseDatabaseReference(.Rooms)

    var isRoomFull: Bool {
        playerOne != nil && playerTwo != nil
    }

    weak var gameRoomDelegate: GameRoomDelegate?

    var isRoomEmpty: Bool {
        playerOne == nil && playerTwo == nil
    }

    // the player creating the room will auto join the room
    init?(roomName: String,
          roomState: RoomState? = nil,
          completion: @escaping (Bool) -> Void) {
        self.roomName = roomName
        self.roomState = roomState

        // Check if the room name is available
        isRoomNameAvailable(roomName: roomName) { isAvailable in
            // If the room name is available, try to join the room
            if isAvailable {
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    init(roomName: String, roomState: RoomState? = nil) {
        self.roomName = roomName
        self.roomState = roomState
        self.makeRoomChangeListener()
    }

    deinit {
        removeAllListeners()
    }

    private func postRoomDataToFirebase(completion: ((_ err: Any?, _ result: String?) -> Void)?) {
        let roomRef = FirebaseDatabaseReference(.Rooms).child(roomName)
        roomRef.updateChildValues(["roomName": roomName ]) { err, snap in
            if err != nil {
                completion?(err, nil)
            } else {
                completion?(nil, snap.key)
            }
        }
    }

    func joinRoom(player: GamePlayer, completion: @escaping (Bool) -> Void) {
        self.isRoomFull(roomName) { isFull in
            if isFull {
                completion(false)
            }
        }
        if playerOne == nil {
            playerOne = player
        } else {
            playerTwo = player
        }
        let playerRef = roomRef.child(roomName).child("players").childByAutoId()
        playerRef.setValue(player.userName)
        player.userPlayerId = playerRef.key
        completion(true) // Successfully joined the room
    }

    func leaveRoom(player: GamePlayer, completion: @escaping (Bool) -> Void) {
        let roomPlayersRef = roomRef.child(roomName).child("players")

        roomPlayersRef.observeSingleEvent(of: .value) { snapshot  in
            if let playerData = snapshot.value as? [String: Any] {
                // Check if the leaving player is in the room
                if let playerKey = playerData.first(where: { $0.key == player.userPlayerId })?.key {
                    // Remove the player from the room in the database
                    roomPlayersRef.child(playerKey).removeValue()

                    // Update local player data
                    if self.playerOne?.userPlayerId == player.userPlayerId {
                        self.playerOne = nil
                    } else if self.playerTwo?.userPlayerId == player.userPlayerId {
                        self.playerTwo = nil
                    }
                    if playerData.count == 1 {
                        // Delete the room from the database
                        self.roomRef.child(self.roomName).removeValue()
                    }
                    completion(true) // Successfully left the room
                } else {
                    // The player is not in the room, cannot leave
                    completion(false)
                }
            } else {
                // No player data found in the room, cannot leave
                completion(false)
            }
        }
    }

    func getPlayerNum(gamePlayer: GamePlayer) -> Player? {
        if gamePlayer == playerOne {
            return .ownPlayer
        }
        if gamePlayer == playerTwo {
            return .oppositePlayer
        }
        return nil
    }

    private func isRoomFull(_ roomName: String, completion: @escaping (Bool) -> Void) {
        let roomRef = FirebaseDatabaseReference(.Rooms).child(roomName).child("players")
        roomRef.getData { error, snapshot in
            if let error = error {
                print("Error getting data: \(error.localizedDescription)")
                completion(false)
                return
            }

            if let snap = snapshot, snap.exists() {
                let playerCount = snap.childrenCount
                completion(playerCount >= 2)
            } else {
                completion(false)
            }
        }
    }

    static func findRoomWithName(_ roomName: String, completion: @escaping (GameRoom?) -> Void) {
        let roomRef = FirebaseDatabaseReference(.Rooms).child(roomName)
        roomRef.getData { _, snapshot in
            if let snap = snapshot {
                if snap.exists() {
                    print("Finding the room and making it")
                    let room = GameRoom(roomName: roomName, roomState: .waitingForPlayers)
                    completion(room)
                } else {
                    completion(nil)
                }

            } else {
                completion(nil)
            }
        }
    }

    private func makeRoomChangeListener() {
        roomRef.child(roomName).observe(.value) { [weak self] snap in
            guard let snapshotValue = snap.value as? [String: Any] else {
                return
            }
            if let playersData = snapshotValue["players"] as? [String: Any] {
                for (playerKey, playerData) in playersData {
                    if let playerData = playerData as? String {
                        let player = GamePlayer(userPlayerId: playerKey, userName: playerData)
                        if self?.playerOne == nil {
                            self?.playerOne = player
                        } else if self?.playerTwo == nil && self?.playerOne != player {
                            self?.playerTwo = player
                        }
                    }
                }
            }
            self?.gameRoomDelegate?.onRoomChange()
        }
    }

    private func makeRoomDeletionListener() {
        roomRef.child(roomName).child("players").observe(.childRemoved) { [weak self] snapshot in
                let playerKey = snapshot.key
                // Check if the player is playerOne
                if let playerOne = self?.playerOne, playerOne.userPlayerId == playerKey {
                    self?.playerOne = nil

                    self?.gameRoomDelegate?.onRoomChange()
                    return
                }

                // Check if the player is playerTwo
                if let playerTwo = self?.playerTwo, playerTwo.userPlayerId == playerKey {
                    self?.playerTwo = nil
                    self?.gameRoomDelegate?.onRoomChange()
                    return
                }

        }
    }

    private func isRoomNameAvailable(roomName: String, completion: @escaping (Bool) -> Void?) {
        FirebaseDatabaseReference(.Rooms).child(roomName).getData { _, snapshot in
            if let snap = snapshot {
                if snap.exists() {
                    completion(false)
                } else {
                    self.postRoomDataToFirebase { _, _ in
                        self.makeRoomChangeListener()
                        self.makeRoomDeletionListener()
                        completion(true)
                    }
                }

            } else {
                self.postRoomDataToFirebase { _, _ in
                    self.makeRoomChangeListener()
                    self.makeRoomDeletionListener()
                    completion(true)
                }
            }
        }

    }

    private func removeAllListeners() {
        roomRef.child(roomName).removeAllObservers()
    }
}
