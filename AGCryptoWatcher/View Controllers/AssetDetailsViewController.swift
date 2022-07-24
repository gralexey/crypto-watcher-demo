//
//  AssetDetailsViewController.swift
//  AGCryptoWallet
//
//  Created by Alexey Grabik on 24.07.2022.
//

import UIKit
import WebKit

class AssetDetailsViewController: UIViewController {
    
    private let viewModel: AssetViewModel
    
    private let stackView = UIStackView()
    private let symbolLabel = UILabel()
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let taglineLabel = UILabel()
    private let detailsView = WKWebView()
    private let linksView = WKWebView()
    private let chartView = ChartView()
    
    private let messageLabel = UILabel()
    
    // MARK: Lifecycle
    
    init(viewModel: AssetViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        
        viewModel.setUp()
    }

    // MARK: -
    
    private func setupUI() {
        view.backgroundColor = .white
        title = "\(viewModel.symbol) details"
        
        // Setup stack
        let holderView = UIView()
        view.addConstraintedSubview(holderView, insets: UIEdgeInsets(top: 100, left: 20, bottom: 20, right: 20))
        holderView.addConstraintedSubview(stackView)
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.addArrangedSubview(symbolLabel)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(priceLabel)
        stackView.addArrangedSubview(taglineLabel)
        stackView.addArrangedSubview(linksView)
        stackView.addArrangedSubview(detailsView)
        stackView.addArrangedSubview(chartView)
        
        // Setup tagline
        taglineLabel.numberOfLines = 0
        
        // Setup details
        detailsView.navigationDelegate = self
        detailsView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        // Setup links
        linksView.navigationDelegate = self
        linksView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        // Setup message
        chartView.addCenteredSubview(messageLabel)
    }
    
    private func bindViewModel() {
        symbolLabel.text = "Symbol: " + viewModel.symbol
        nameLabel.text = "Name: " + (viewModel.name ?? "no")
        priceLabel.text = "Price: " + viewModel.price
        taglineLabel.text = "Tagline: " + (viewModel.tagline ?? "no")
        
        if let details = viewModel.details {
            detailsView.loadHTMLString(Self.sizedHTML(details), baseURL: nil)
        }
        
        if let links = viewModel.links {
            let html = links.compactMap {
                guard let link = $0.link else { return nil }
                let name = $0.name
                return "<a href=\(link)>\(name ?? link)</a>"
            }
            .joined(separator: ", ")
            linksView.loadHTMLString(Self.sizedHTML(html), baseURL: nil)
        }
        
        viewModel.onTimeSeriesUpdated = { [weak self] ts in
            guard let self = self else { return }
            self.chartView.set(timeItems: ts)
        }
        
        viewModel.onStateUpdated = { [weak self] state in
            guard let self = self else { return }
            switch state {
            case .no:
                self.messageLabel.text = ""
            case .loading:
                self.messageLabel.text = "Loading"
            case .error:
                self.messageLabel.text = "Error"
            case .loaded:
                self.messageLabel.text = ""
            }
        }
    }
    
    private static func sizedHTML(_ html: String) -> String {
        "<div style='font-size: 50'>\(html)</div>"
    }
}

extension AssetDetailsViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.absoluteString != "about:blank" {
            decisionHandler(.cancel)
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            decisionHandler(.allow)
        }
    }
}
