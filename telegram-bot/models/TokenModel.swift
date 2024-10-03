//
//  api-model.swift
//  telegram-bot
//
//  Created by Muhammad Vikri on 02/10/24.
//


struct Token: Decodable {
    let access: String
}

struct TokenResponse: Decodable {
    let token: Token
}



