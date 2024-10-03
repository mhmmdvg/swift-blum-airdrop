//
//  ProfileModel.swift
//  telegram-bot
//
//  Created by Muhammad Vikri on 03/10/24.
//


struct Id: Decodable {
    let id: String
}

public struct ProfileResponse: Decodable {
    let id: Id
    let username: String
}
