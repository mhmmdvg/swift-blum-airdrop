//
//  api-enum.swift
//  telegram-bot
//
//  Created by Muhammad Vikri on 02/10/24.
//

enum NetworkError: Error {
    case invalidResponse
    case noData
}

enum HTTPMethod: String {
    case GET
    case POST
}
