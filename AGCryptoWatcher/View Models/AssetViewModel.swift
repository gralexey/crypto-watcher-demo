//
//  AssetViewModel.swift
//  AGCryptoWallet
//
//  Created by Alexey Grabik on 24.07.2022.
//

import UIKit

class AssetViewModel {
    
    typealias Link = NetworkService.Profile.General.Overview.Link
    
    private let networkService: NetworkServiceProtocol
    private let asset: FeedViewModel.Asset
    
    var symbol: String {
        asset.symbol
    }
    
    var name: String? {
        asset.name
    }
    
    var price: String {
        asset.formattedPrice
    }
    
    var tagline: String? {
        asset.profile.general.overview.tagline
    }
    
    var details: String? {
        asset.profile.general.overview.projectDetails
    }
    
    var links: [Link]? {
        asset.profile.general.overview.officialLinks
    }
    
    // MARK: State
    
    var onTimeSeriesUpdated: (([TimeItem]) -> Void)? {
        didSet {
            onTimeSeriesUpdated?(timeSeries)
        }
    }
    private(set) var timeSeries = [TimeItem]() {
        didSet {
            onTimeSeriesUpdated?(timeSeries)
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
    
    // MARK: -

    init(asset: FeedViewModel.Asset, networkService: NetworkServiceProtocol) {
        self.asset = asset
        self.networkService = networkService
    }
    
    func setUp() {
        let d = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let startDateString = dateFormatter.string(from: d)
        
        state = .loading
        networkService.requestAssetData(assetKey: asset.id, startDateString: startDateString) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let valuesResponse):
                self.timeSeries = valuesResponse.timeItems
                self.state = .loaded
                
            case .failure(let error):
                print("error requesting market data: \(error)")
                self.state = .error
            }
        }
    }
}

extension AssetViewModel {
    struct TimeItem {
        let ts: Double
        let close: Double
    }
}

extension NetworkService.ValuesResponse {
    var timeItems: [AssetViewModel.TimeItem] {
        data.values.map {
            AssetViewModel.TimeItem(ts: $0[0], close: $0[1])
        }
    }
}

extension AssetViewModel {
    enum State {
        case no, loading, error, loaded
    }
}
