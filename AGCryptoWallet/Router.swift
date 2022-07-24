//
//  Router.swift
//  AGCryptoWallet
//
//  Created by Alexey Grabik on 24.07.2022.
//

import UIKit

class Router {
    
    let rootViewController = UINavigationController()
    
    init() {
        DispatchQueue.main.async {  //?
            let vc = FeedViewController()
            self.rootViewController.setViewControllers([vc], animated: false)
        }
    }
    
    func goToAssetDetails(_ asset: FeedViewModel.Asset) {
        let vc = AssetDetailsViewController(viewModel: AssetViewModel(asset: asset,
                                                                      networkService: AppState.shared.networkService))
        rootViewController.pushViewController(vc, animated: true)
    }
}
