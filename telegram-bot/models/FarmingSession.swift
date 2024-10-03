//
//  FarmingSession.swift
//  telegram-bot
//
//  Created by Muhammad Vikri on 03/10/24.
//

public struct FarmingSessionResponse: Decodable {
    let balance: String
    let earningsRate: String
    let endTime: Int64
    let startTime: Int64
}
