//
//  UIView+Additions.swift
//  AGCryptoWallet
//
//  Created by Alexey Grabik on 21.07.2022.
//

import Foundation
import UIKit

extension UIView {
    func addConstraintedSubview(_ view: UIView,
                                insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        view.topAnchor.constraint(equalTo: topAnchor, constant: insets.top).isActive = true
        view.leftAnchor.constraint(equalTo: leftAnchor, constant: insets.left).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom).isActive = true
        view.rightAnchor.constraint(equalTo: rightAnchor, constant: -insets.right).isActive = true
    }
    
    func addCenteredSubview(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        view.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0).isActive = true
        view.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
    }
}
