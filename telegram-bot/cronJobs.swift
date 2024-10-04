//
//  cronJobs.swift
//  telegram-bot
//
//  Created by Muhammad Vikri on 03/10/24.
//

import Foundation
import Dispatch

private let semaphore = DispatchSemaphore(value: 0)

public func setupCronJob() {
    let queue = DispatchQueue(label: "com.yourapp.cronJob", attributes: .concurrent)
    let interval: TimeInterval = 12 * 60 * 60 // 12 hours in seconds
    
    func runJob() {
        print("🔄 Starting farming session...")
        claimFarmReward { result in
            switch result {
            case .success(_):
                print("🌾 Farming reward claimed!")
            case .failure(let error):
                print("❌ Failed to claim farming reward.", error)
            }
            
            // Schedule the next run
            queue.asyncAfter(deadline: .now() + interval) {
                runJob()
            }
        }
    }
    
    // Start the first job immediately
    queue.async {
        runJob()
    }
    
    print("⏰ Cron job set up to run every 12 hours.")
    
    // Keep the program running
    semaphore.wait()
}


public func setupBalanceCheckJob() {
    let randomHour = Int.random(in: 1...8)
    let queue = DispatchQueue(label: "com.yourapp.cronJob", attributes: .concurrent)
    let timeInterval: TimeInterval = Double(randomHour * 60 * 60)
    
    func runJob() {
        getBalance { result in
            //            defer { semaphore.signal() }
            
            switch result {
            case .success(let balance):
                let farmingBalance = balance.farming.balance
                print("🌾 Updated farming balance: \(farmingBalance) BLUM")
            case .failure(let error):
                print("❌ Failed to retrieve balance.", error)
            }
            
            queue.asyncAfter(deadline: .now() + timeInterval) {
                runJob()
            }
        }
    }
    
    queue.async {
        runJob()
    }
    
    print("⏰ Balance check job set up to run every \(randomHour) hours.")
    
    semaphore.wait()
}


public func setupFarmRewardCron() {
    let interval: TimeInterval = 12 * 60 * 60
    let queue = DispatchQueue(label: "com.yourapp.cronJob", attributes: .concurrent)
    
    func runJob() {
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
            queue.asyncAfter(deadline: .now() + interval) {
                runJob()
            }
        }
    }
    queue.async {
        runJob()
    }
    
    print("🕒 Daily reward cron job scheduled to run every 9 hours.")
    
    semaphore.wait()
}

public func setupDailyRewardCron() {
    let queue = DispatchQueue(label: "com.yourapp.cronJob", attributes: .concurrent)
    let interval: TimeInterval = 24 * 60 * 60
    
    func runJob() {
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
            
            queue.asyncAfter(deadline: .now() + interval) {
                runJob()
            }
        }
    }
    
    queue.async {
        runJob()
    }
    
    print("🕒 Daily reward cron job scheduled to run every 24 hours.")
    
    semaphore.wait()
}
