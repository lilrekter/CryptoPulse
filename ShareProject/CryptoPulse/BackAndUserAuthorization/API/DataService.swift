//
//  DataService.swift
//  userLoginWithNode
//
//  Created by Vitaly on 17.10.2023.
//

import Foundation

class DataService {
    
    static func getData(complition: @escaping (Result<[Account], Error>) -> Void) {
        
        guard var request = Endpoint.getData().request else { return }
        
        request.addValue("Token \(AuthToken.authToken)", forHTTPHeaderField: "Authorization")
    
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data else {
                
                if let error = error {
                    complition(.failure(ServiceError.serverError(error.localizedDescription)))
                } else {
                    complition(.failure(ServiceError.unknownError()))
                }
                
                return
            }
            
            let decoder = JSONDecoder()
            
            if let array = try? decoder.decode([Account].self, from: data) {
                complition(.success(array))
                print("Успешно декодим полученные данные!")
                return
            } else if let errorMessage = try? decoder.decode(ErrorResponse.self, from: data) {
                complition(.failure(ServiceError.serverError(errorMessage.error)))
                return
            } else {
                complition(.failure(ServiceError.decodingError()))
                return
            }
        }.resume()
    }
    
    static func getUser(complition: @escaping (Result<CurrentUserResponse, Error>) -> Void) {
        
        guard var request = Endpoint.currentUser().request else { return }
        request.addValue("Token \(AuthToken.authToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, urlResponse, error in
            
            guard let data = data else {
                
                if let error = error {
                    complition(.failure(ServiceError.serverError(error.localizedDescription)))
                } else {
                    complition(.failure(ServiceError.unknownError()))
                }
                
                return
            }
            
            let decoder = JSONDecoder()
            
            if let currentUserModel = try? decoder.decode(CurrentUserResponse.self, from: data) {
                complition(.success(currentUserModel))
                return
            } else if let tokenError = try? decoder.decode(TokenErrorServerResponse.self, from: data) {
                complition(.failure(ServiceError.serverError(tokenError.detail)))
                return
            } else {
                complition(.failure(ServiceError.decodingError()))
                return
            }
        }.resume()
    }
    
}
