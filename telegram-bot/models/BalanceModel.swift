//
//  BalanceModel.swift
//  telegram-bot
//
//  Created by Muhammad Vikri on 03/10/24.
//

import Foundation

struct Farming: Decodable {
    let balance: String
    let earningsRate: String
    let endTime: Int64
    let startTime: Int64
}

public struct BalanceResponse: Decodable {
    let availableBalance: String
    let farming: Farming
    let isFastFarmingEnabled: Bool
    let playPasses: Int
    let timestamp: Int64
}
