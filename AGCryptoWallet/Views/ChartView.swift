//
//  ChartView.swift
//  AGCryptoWallet
//
//  Created by Alexey Grabik on 24.07.2022.
//

import UIKit

class ChartView: UIView {

    private let stackView = UIStackView()
    
    func set(timeItems: [AssetViewModel.TimeItem]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        guard let maxValue = (timeItems.max { $0.close < $1.close }) else { return }
        guard let minValue = (timeItems.min { $0.close < $1.close }) else { return }
        
        timeItems.forEach { item in
            stackView.addArrangedSubview(ItemView(timeItem: item,
                                                  max: maxValue,
                                                  min: minValue))
        }
    }
    
    private func setup() {
        addConstraintedSubview(stackView)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 2
    }
    
    // MARK: View
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
}

extension ChartView {
    class ItemView: UIView {
        
        init(timeItem: AssetViewModel.TimeItem,
             max: AssetViewModel.TimeItem,
             min: AssetViewModel.TimeItem) {
            super.init(frame: .zero)
            
            let diff = (max.close - min.close)
            let ration = (timeItem.close - min.close) / diff
            
            let view = UIView()
            view.backgroundColor = .blue
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            view.heightAnchor.constraint(equalTo: heightAnchor, multiplier: ration).isActive = true
            view.leftAnchor.constraint(equalTo: leftAnchor, constant: 1).isActive = true
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
            view.rightAnchor.constraint(equalTo: rightAnchor, constant: -1).isActive = true
        }
    
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
