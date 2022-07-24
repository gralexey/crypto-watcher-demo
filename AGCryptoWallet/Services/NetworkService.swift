//
//  NetworkService.swift
//  AGCryptoWallet
//
//  Created by Alexey Grabik on 21.07.2022.
//

import Foundation

protocol NetworkServiceProtocol {
    func requestFeed(page: Int,
                     completion: @escaping ((Result<[NetworkService.Asset], NetworkService.NetworkServiceError>) -> Void))
    func requestAssetData(assetKey: String,
                          startDateString: String,
                          completion: @escaping ((Result<NetworkService.ValuesResponse, NetworkService.NetworkServiceError>) -> Void))
}

class NetworkService: NetworkServiceProtocol {
    
    private let marketDataUri = "https://data.messari.io/api/v2/assets?with-profiles"
    private let marketAssetDataUri = "https://data.messari.io/api/v1/assets/{assetKey}/metrics/price/time-series?interval=1d&columns=close"
    
    enum NetworkServiceError: Error {
        case general(Error), noData, parseError(Error)
    }
    
    func requestAssetData(assetKey: String,
                          startDateString: String,
                          completion: @escaping ((Result<ValuesResponse, NetworkServiceError>) -> Void)) {
        let dataURL = URL(string: marketAssetDataUri.replacingOccurrences(of: "{assetKey}", with: assetKey) + "&start=\(startDateString)")!
        let request = URLRequest(url: dataURL)
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.general(error)))
                } else if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let response = try decoder.decode(ValuesResponse.self, from: data)
                        completion(.success(response))
                    } catch {
                        completion(.failure(.parseError(error)))
                    }
                } else {
                    completion(.failure(.noData))
                }
            }
        }.resume()
    }
    
    func requestFeed(page: Int,
                     completion: @escaping ((Result<[Asset], NetworkServiceError>) -> Void)) {
        let marketDataURL = URL(string: marketDataUri + "&page=\(page)")!
        let request = URLRequest(url: marketDataURL)
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.general(error)))
                } else if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let response = try decoder.decode(Response.self, from: data)
                        completion(.success(response.data))
                    } catch {
                        completion(.failure(.parseError(error)))
                    }
                } else {
                    completion(.failure(.noData))
                }
            }
        }.resume()
    }
}

extension NetworkService {
    
    struct Response: Decodable {
        let data: [Asset]
    }
    
    struct Asset: Decodable {
        let id: String
        let symbol: String
        let name: String
        let slug: String
        let metrics: Metrics
        let profile: Profile
        
        var formattedPrice: String {
            String(format: "$%.2f", metrics.marketData.priceUsd).replacingOccurrences(of: " ", with: "")
        }
    }
    
    struct Metrics: Decodable {
        let marketData: MarketData
        
        struct MarketData: Decodable {
            let priceUsd: Double
        }
    }
    
    struct Profile: Decodable {
        let general: General
        
        struct General: Decodable {
            let overview: Overview
            
            struct Overview: Decodable {
                let tagline: String?
                let projectDetails: String?
                let officialLinks: [Link]?
                
                struct Link: Decodable {
                    let name: String?
                    let link: String?
                }
            }
        }
    }
    
    struct ValuesResponse: Decodable {
        let data: Data
        
        struct Data: Decodable {
            let values: [[Double]]
        }
    }
}
