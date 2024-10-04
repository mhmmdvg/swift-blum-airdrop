//
//  main.swift
//  telegram-bot
//
//  Created by Muhammad Vikri on 02/10/24.
//

import Foundation

enum Feature: String, CaseIterable {
    case claimFarmReward = "1"
    case startFarmingSession = "2"
    case autoCompleteTasks = "3"
    case autoPlayAndClaimGamePoints = "4"
    case claimDailyReward = "5"
}


func featureDescription(for feature: Feature) -> String {
    switch feature {
    case .claimFarmReward:
        return "Claim Farm Reward 🌾"
    case .startFarmingSession:
        return "Start Farming Session 🚜"
    case .autoCompleteTasks:
        return "Auto Complete Tasks ✅"
    case .autoPlayAndClaimGamePoints:
        return "Auto Play and Claim Game Points 🎮"
    case .claimDailyReward:
        return "Claim Daily Reward ✨"
    }
}

func handleDefaultFlow() {
    print("Which feature would you like to use?")
    for feature in Feature.allCases {
        print("\(feature.rawValue). \(featureDescription(for: feature))")
    }
    print("Choose 1, 2, 3, 4, or 5: ", terminator: "")
    
    guard let choice = readLine(), let feature = Feature(rawValue: choice) else {
        print("🚫 Invalid choice! Please restart the program and choose a valid option.")
        return
    }
    
    switch feature {
    case .claimFarmReward:
        handleClaimFarmReward()
    case .startFarmingSession:
        handleStartFarmingSession()
    case .autoCompleteTasks:
        handleAutoCompleteTasks()
    case .autoPlayAndClaimGamePoints:
        handleAutoPlayAndClaimGamePoints()
    case .claimDailyReward:
        handleClaimDailyReward()
    }
}

handleDefaultFlow()



