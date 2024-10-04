//
//  api.swift
//  telegram-bot
//
//  Created by Muhammad Vikri on 02/10/24.
//

import Foundation


public func getToken(completion: @escaping (Result<String, Error>) -> Void) {
    guard let url = URL(string: "https://user-domain.blum.codes/api/v1/auth/provider/PROVIDER_TELEGRAM_MINI_APP") else {
        return
    }
    
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let parameters: [String: Any] = [
        "query": ProcessInfo.processInfo.environment["SESSION_KEY"] ?? "",
        "referralToken": "vTHusRz4j0" // changeable
    ]
    
    
    do {
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
    } catch {
        print("Error serializing request body: \(error.localizedDescription)")
        completion(.failure(error))
        return
    }
    
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error with data task: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            print("Error: No data received")
            completion(.failure(NetworkError.noData))
            return
        }
        
        
        do {
            let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
            let token = "Bearer \(tokenResponse.token.access)"
            completion(.success(token))
        } catch {
            completion(.failure(error))
        }
    }.resume()
}


private func createRequest(with url: URL?, type: HTTPMethod, completion: @escaping (URLRequest) -> Void) {
    getToken { result in
        switch result {
        case .success(let token):
            print("Token fetched successfully")
            guard let apiURL = url else {
                print("Error: Invalid API URL")
                return
            }
            
            var req = URLRequest(url: apiURL)
            req.httpMethod = type.rawValue
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.setValue(token, forHTTPHeaderField: "Authorization")
            completion(req)
            
        case .failure(let error):
            print("Error fetching token: \(error.localizedDescription)")
        }
    }
}


public func getUsername(completion: @escaping (Result<ProfileResponse, Error>) -> Void) {
    createRequest(with: URL(string: "https://user-domain.blum.codes/api/v1/user/me"), type: .GET) { baseRequest in
        print("Sending request for username...")
        URLSession.shared.dataTask(with: baseRequest) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(ProfileResponse.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}


public func getBalance(completion: @escaping (Result<BalanceResponse, Error>) -> Void) {
    createRequest(with: URL(string: "https://game-domain.blum.codes/api/v1/user/balance"), type: .GET) { baseRequest in
        URLSession.shared.dataTask(with: baseRequest) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
//                let result = try JSONSerialization.jsonObject(with: data)
//                print("Hasil", result)
//                completion(.success("Successfully"))
                let result = try JSONDecoder().decode(BalanceResponse.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

public func getTribe(completion: @escaping (Result<String, Error>) -> Void) {
    createRequest(with: URL(string: "https://tribe-domain.blum.codes/api/v1/tribe/my"), type: .GET) { baseRequest in
        URLSession.shared.dataTask(with: baseRequest) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let result = try JSONSerialization.jsonObject(with: data)
                print(result)
                completion(.success("Successfully fetch"))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}


public func claimFarmReward(completion: @escaping (Result<ClaimFarmResponse, Error>) -> Void) {
    createRequest(with: URL(string: "https://game-domain.blum.codes/api/v1/farming/claim"), type: .POST) { baseRequest in
        URLSession.shared.dataTask(with: baseRequest) { data, _, error in
            if let error = error {
                print("🚨 Error occurred from farm claim: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(ClaimFarmResponse.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
            
        }.resume()
    }
}


public func claimDailyReward(completion: @escaping (Result<ClaimFarmResponse, Error>) -> Void) {
    createRequest(with: URL(string: "https://game-domain.blum.codes/api/v1/daily-reward?offset=-420"), type: .POST) { baseRequest in
        URLSession.shared.dataTask(with: baseRequest) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(ClaimFarmResponse.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

public func startFarmingSession(completion: @escaping (Result<FarmingSessionResponse, Error>) -> Void) {
    createRequest(with: URL(string:"https://game-domain.blum.codes/api/v1/farming/start"), type: .POST) { baseRequest in
        URLSession.shared.dataTask(with: baseRequest) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(NetworkError.noData))
                return
            }

            
            do {                
                let result = try JSONDecoder().decode(FarmingSessionResponse.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

public func getTasks(completion: @escaping (Result<[TaskResponse], Error>) -> Void) {
    createRequest(with: URL(string: "https://earn-domain.blum.codes/api/v1/tasks"), type: .GET) { baseRequest in
        URLSession.shared.dataTask(with: baseRequest) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
//                let result = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
//                print(result)
                let result = try JSONDecoder().decode([TaskResponse].self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

public func startTasks(id: String, title: String, completion: @escaping (Result<Task, Error>) -> Void) {
    createRequest(with: URL(string: "https://earn-domain.blum.codes/api/v1/tasks/\(id)/start"), type: .POST) { baseRequest in
        URLSession.shared.dataTask(with: baseRequest) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(Task.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

public func claimTaskReward(id: String, completion: @escaping (Result<Task, Error>) -> Void) {
    createRequest(with: URL(string: "https://earn-domain.blum.codes/api/v1/tasks/\(id)/claim"), type: .POST) { baseRequest in
        URLSession.shared.dataTask(with: baseRequest) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(Task.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

public func getGameId(completion: @escaping (Result<GameID, Error>) -> Void) {
    createRequest(with: URL(string: "https://game-domain.blum.codes/api/v1/game/play"), type: .POST) { baseRequest in
        URLSession.shared.dataTask(with: baseRequest) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
//                let result = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
//                print("Result Game ID", result)
                
                let result = try JSONDecoder().decode(GameID.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

public func claimGamePoints(gameID: String, points: Int, completion: @escaping (Result<String, Error>) -> Void) {
    createRequest(with: URL(string: "https://game-domain.blum.codes/api/v1/game/claim"), type: .POST) { baseRequest in
        var request = baseRequest
        
        let payload: [String: Any] = [
            "gameId": gameID,
            "points": points
        ]
        
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload, options: .fragmentsAllowed)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let result = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                print("Claim success \(result)")
                completion(.success("Hellooooo"))
            } catch {
                completion(.failure(error))
            }
        }.resume() 
    }
}
