//
//  cronJobs.swift
//  telegram-bot
//
//  Created by Muhammad Vikri on 03/10/24.
//

import Foundation

public func setupCronJob() {
    let timer = Timer.scheduledTimer(withTimeInterval: 12 * 60 * 60, repeats: true) { _ in
        print("🔄 Starting farming session every 12 hours...")
        claimFarmReward { result in
            switch result {
            case .success(_):
                print("🌾 Farming reward claimed!")
            case .failure(let error):
                print("❌ Failed to claim farming reward.", error)
            }
        }
    }
    // This will make it run immediately for the first time
    timer.fire()
    
    print("⏰ Timer set up to run every 12 hours.")
    
    // Keep the timer running
    RunLoop.current.run()
}


public func setupBalanceCheckJob() {
    let randomHour = Int.random(in: 1...8)
    let timeInterval = Double(randomHour * 60 * 60)
    
    let timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true) { _ in
        getBalance { result in
            switch result {
            case .success(let balance):
                 let farmingBalance = balance.farming.balance
                print("🌾 Updated farming balance: \(farmingBalance) BLUM")
            case .failure(let error):
                print("❌ Failed to retrieve balance.", error)
            }
        }
    }
    
    timer.fire()
    
    print("⏰ Balance check job set up to run every \(randomHour) hours.")
    
    RunLoop.current.run()
}


public func setupFarmRewardCron() {
    let timer = Timer.scheduledTimer(withTimeInterval: 9 * 60 * 60, repeats: true) { _ in
        print("⏰ Running farm reward cron job...")
        claimFarmReward { result in
            switch result {
            case .success(let success):
                guard !success.message.isEmpty else {
                    return
                }
                print("✅ Daily reward claimed successfully!")
            case .failure(let error):
                print("❌ Failed to claim farming reward.", error)
            }
        }
    }
    timer.fire()
    
    print("🕒 Daily reward cron job scheduled to run every 9 hours.")
    
    RunLoop.current.run()
}

public func setupDailyRewardCron() {
    let timer = Timer.scheduledTimer(withTimeInterval: 24 * 60 * 60, repeats: true) { _ in
        print("⏰ Running daily reward cron job...")
        
        claimDailyReward { result in
            switch result {
            case .success(let reward):
                guard !reward.message.isEmpty else {
                    return
                }
                print("✅ Daily reward claimed successfully!")
            case .failure(let error):
                print("❌ Failed to claim farming reward.", error)
            }
        }
    }
    timer.fire()
    
    print("🕒 Daily reward cron job scheduled to run every 24 hours.")
    
    RunLoop.current.run()
}
