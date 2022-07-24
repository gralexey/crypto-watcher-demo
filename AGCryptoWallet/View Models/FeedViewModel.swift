//
//  FeedViewModel.swift
//  AGCryptoWallet
//
//  Created by Alexey Grabik on 21.07.2022.
//

import Foundation

class FeedViewModel {
    
    typealias Asset = NetworkService.Asset
    
    private let networkService: NetworkServiceProtocol
    
    // MARK: State
    
    var onAssetsUpdated: (() -> Void)? {
        didSet {
            onAssetsUpdated?()
        }
    }
    private(set) var assets = [Asset]() {
        didSet {
            onAssetsUpdated?()
        }
    }
    
    var onStateUpdated: ((State) -> Void)? {
        didSet {
            onStateUpdated?(state)
        }
    }
    private var state = State.no {
        didSet {
            onStateUpdated?(state)
        }
    }
    
    private var page = 1
    
    func requestNextPage() {
        page += 1
        requestFeed(page: page)
    }
    
    // MARK: -
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func setUp() {
        requestFeed(page: 1)
    }
    
    private func requestFeed(page: Int) {
        state = .loading
        print("requesting page \(page)")
        networkService.requestFeed(page: page) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let assets):
                self.assets += assets
                self.state = .loaded
                
            case .failure(let error):
                print("error requesting feed: \(error)")
                self.state = .error
            }
        }
    }
}

extension FeedViewModel {
    enum State {
        case no, loading, error, loaded
    }
}
