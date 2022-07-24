//
//  AppState.swift
//  AGCryptoWallet
//
//  Created by Alexey Grabik on 21.07.2022.
//

import Foundation

class AppState {
    
    let networkService: NetworkServiceProtocol = NetworkService()
    let router = Router()
    
    static let shared = AppState()
    private init() {}
}
