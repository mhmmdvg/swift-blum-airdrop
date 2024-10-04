//
//  handlingFeature.swift
//  telegram-bot
//
//  Created by Muhammad Vikri on 03/10/24.
//

import Foundation
import Dispatch

extension String {
    var red: String { return self }
    var green: String { return self }
    var yellow: String { return self }
    var cyan: String { return self }
}


private let semaphore = DispatchSemaphore(value: 0)

public func handleClaimFarmReward() {
    print("🌾 Claiming farm reward...")
    claimFarmReward { result in
        
        defer { semaphore.signal() }
        
        switch result {
        case .success(let reward):
            print(reward)
            print("✅ Farm reward claimed successfully!" .green)
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
    semaphore.wait()
    
    print("Do you want to run this farm reward claim every 9 hours? (yes/no): ", terminator: "")
    
    if let response = readLine(), response.lowercased() == "yes" {
        setupFarmRewardCron()
    } else {
        print("👋 Exiting the bot. See you next time!".cyan)
        exit(0)
    }
}

public func handleStartFarmingSession() {
    print("🚜 Starting farming session...".yellow)
    print("")
    
    startFarmingSession { result in
        
        defer { semaphore.signal() }
        
        switch result {
        case .success(let farm):
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM d yyyy, h:mm:ss a"
            
            let farmStartTime = Date(timeIntervalSince1970: TimeInterval(farm.startTime))
            let farmEndTime = Date(timeIntervalSince1970: TimeInterval(farm.endTime))
            
            let formattedStartTime = dateFormatter.string(from: farmStartTime)
            let formattedEndTime = dateFormatter.string(from: farmEndTime)
            
            print("✅ Farming session started!".green)
            print("⏰ Start time: \(formattedStartTime)")
            print("⏳ End time: \(formattedEndTime)")
            
            getBalance { balance in
                
                defer { semaphore.signal() }
                
                switch balance {
                case .success(let success):
                    print("🌾 Updated farming balance: \(success.farming.balance) BLUM".green)
                    setupCronJob()
                    setupBalanceCheckJob()
                    exit(0)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
        case .failure(let error):
            print("Failed to start farming session \(error)".red)
        }
    }
    
    semaphore.wait()
    semaphore.wait()
    
}


func handleTask(task: Task) {
    
    switch task.status {
    case "FINISHED":
        print("⏭️  Task \(task.title) is already completed.")
        semaphore.signal()
        
    case "NOT_STARTED":
        print("⏳ Task \(task.title) is not started yet. Starting now...")
        startTasks(id: task.id, title: task.title) { result in
            defer { semaphore.signal() }
            switch result {
            case .success(let startedTask):
                print("✅ Task \"\(startedTask.title)\" has been started!".green)
                claimTaskReward(id: task.id) { claimedTask in
                    defer { semaphore.signal() }
                    switch claimedTask {
                    case .success(let claimed):
                        print("✅ Task \"\(claimed.title)\" has been claimed!".green)
                        print("🎁 Reward: \(claimed.reward)".green)
                    case .failure(let error):
                        print("🚫 Unable to claim task \"\(task.title)\", please try to claim it manually.", error)
                    }
                }
                
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    case "STARTED", "READY_FOR_CLAIM":
        claimTaskReward(id: task.id) { result in
            defer { semaphore.signal() }
            switch result {
            case .success(let claimed):
                print("✅ Task \"\(claimed.title)\" has been claimed!".green)
                print("🎁 Reward: \(claimed.reward)".green)
            case .failure(_):
                print("🚫 Unable to claim task \"\(task.title)\".".red)
            }
        }
        
    default:
        print("Task \"\(task.title)\" has an unknown status: \(task.status)".yellow)
        semaphore.signal()
    }
    
    semaphore.wait()
}

public func handleAutoCompleteTasks() {
    print("✅ Auto completing tasks...".yellow)
    print("")
    
    getTasks { result in
        defer { semaphore.signal() }
        switch result {
        case .success(let taskData):
            for category in taskData {
                if let tasks = category.tasks, !tasks.isEmpty, let subTasks = tasks[0].subTasks {
                    for task in subTasks {
                        DispatchQueue.global().async {
                            handleTask(task: task)
                            semaphore.signal()
                        }
                        
                    }
                }
                
                if let subSections = category.subSections, !subSections.isEmpty {
                    for subSection in subSections {
                        if let tasks = subSection.tasks {
                            for task in tasks {
                                DispatchQueue.global().async {
                                    handleTask(task: task)
                                    semaphore.signal()
                                }
                            }
                        }
                    }
                }
            }
            
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
    semaphore.wait()
}


func playGame(counter: Int) {
    var count = counter
    getGameId { result in
        defer {
            semaphore.signal()
        }
        switch result {
        case .success(let gameData):
            print("⌛ Please wait for 1 minute to play the game...".yellow)
            DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
                let randPoints = Int.random(in: 160...240)
                claimGamePoints(gameID: gameData.gameId, points: randPoints) { claimResult in
                    defer {
                        semaphore.signal()
                    }
                    
                    switch claimResult {
                    case .success(let success):
                        if success == "OK" {
                            
                            getBalance { newBalance in
                                defer {
                                    semaphore.signal()
                                }
                                switch newBalance {
                                case .success(let balance):
                                    print("🎮 Play game success! Your balance now: \(balance.availableBalance) BLUM".green)
                                case .failure(_):
                                    print("🎮 Play game success!".green)
                                }
                            }
                        }
                        count -= 1
                        if count > 0 {
                            playGame(counter: count)
                        }
                    case .failure(_):
                        print("🎮 Play game success!".green)
                    }
                }
            }
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
    semaphore.wait()
    semaphore.wait()
}

public func handleAutoPlayAndClaimGamePoints() {
    print("🎮 Auto playing game and claiming reward...".yellow)
    
    
    getBalance { result in
        
        defer {
            semaphore.signal()
        }
        
        switch result {
        case .success(let balance):
            if balance.playPasses > 0 {
                let counter = balance.playPasses
                playGame(counter: counter)
            } else {
                print("🚫 You can't play again because you have \(balance.playPasses) chance(s) left.".red)
            }
            
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
    semaphore.wait()
}

public func handleClaimDailyReward() {
    
    claimDailyReward { result in
        defer {
            semaphore.signal()
        }
        switch result {
        case .success(_):
            print("✅ Daily reward claimed successfully!".green)
            
            print("Do you want to run this daily reward claim every 24 hours? (yes/no): ", terminator: "")
            if let response = readLine(), response.lowercased() == "yes" {
                setupDailyRewardCron()
            } else {
                print("👋 Exiting the bot. See you next time!".cyan)
                exit(0)
            }
            
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    semaphore.wait()
}
