//
//  TaskModel.swift
//  telegram-bot
//
//  Created by Muhammad Vikri on 03/10/24.
//

import Foundation

// MARK: - Root Model
public struct TaskResponse: Codable {
    let sectionType: String
    let tasks: [Task]?
    let subSections: [SubSection]?
    let title: String?
    
}

struct SubSection: Codable {
    let title: String
    let tasks: [Task]?
}

// MARK: - Task Model
public struct Task: Codable {
    let id: String
    let kind: String
    let type: String
    let status: String
    let validationType: String
    let iconFileKey: String
    let bannerFileKey: String?
    let title: String
    let productName: String?
    let description: String?
    let reward: String
    let subTasks: [Task]?
    let isHidden: Bool?
    let isDisclaimerRequired: Bool
    let socialSubscription: SocialSubscription?
    let applicationLaunch: ApplicationLaunch?
}

// MARK: - SubTask Model
//struct SubTask: Codable {
//    let id: String
//    let kind: String
//    let type: String
//    let status: String
//    let validationType: String
//    let iconFileKey: String
//    let title: String
//    let productName: String?
//    let reward: String
//    let socialSubscription: SocialSubscription?
//    let applicationLaunch: ApplicationLaunch?
//    let isDisclaimerRequired: Bool
//}

// MARK: - SocialSubscription Model
struct SocialSubscription: Codable {
    let openInTelegram: Bool
    let url: String
}

// MARK: - ApplicationLaunch Model
struct ApplicationLaunch: Codable {
    let url: String
}

