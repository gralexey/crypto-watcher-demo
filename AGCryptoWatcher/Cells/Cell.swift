//
//  Cell.swift
//  AGCryptoWallet
//
//  Created by Alexey Grabik on 24.07.2022.
//

import UIKit

class Cell: UITableViewCell {
    static let identifier = "Cell"
    
    func fill(with asset: FeedViewModel.Asset) {
        textLabel?.text = "\(asset.symbol), \(asset.name), \(asset.formattedPrice)"
    }
}
