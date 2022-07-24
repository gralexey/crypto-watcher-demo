//
//  FeedViewController.swift
//  AGCryptoWallet
//
//  Created by Alexey Grabik on 21.07.2022.
//

import UIKit

class FeedViewController: UIViewController {
    
    private var tableView = UITableView()
    private let viewModel: FeedViewModel
    private let messageLabel = UILabel()
    
    private var state = FeedViewModel.State.no {
        didSet {
            switch state {
            case .no:
                messageLabel.text = ""
                
            case .loading:
                messageLabel.text = "Loading"
                
            case .error:
                messageLabel.text = ""
                
            case .loaded:
                messageLabel.text = ""
            }
        }
    }
    
    // MARK: Lifecycle
    
    init(viewModel: FeedViewModel = FeedViewModel(networkService: AppState.shared.networkService)) {
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
    
    // MARK: UI
    
    private func setupTable() {
        view.addConstraintedSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(Cell.self, forCellReuseIdentifier: Cell.identifier)
    }
    
    private func setupMessageView() {
        view.addCenteredSubview(messageLabel)
        messageLabel.textAlignment = .center
        messageLabel.backgroundColor = .white
        messageLabel.layer.cornerRadius = 4
        messageLabel.layer.masksToBounds = true
    }

    private func setupUI() {
        setupTable()
        setupMessageView()
        title = "Feed"
    }
    
    // MARK: -
    
    private func bindViewModel() {
        viewModel.onAssetsUpdated = { [weak self] in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
        
        viewModel.onStateUpdated = { [weak self] state in
            guard let self = self else { return }
            self.state = state
        }
    }
}

extension FeedViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.assets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Cell.identifier, for: indexPath) as? Cell else {
            return UITableViewCell()
        }
        
        cell.fill(with: viewModel.assets[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= viewModel.assets.count - 1 {
            viewModel.requestNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        
        let asset = viewModel.assets[indexPath.row]
        AppState.shared.router.goToAssetDetails(asset)
        
    }
}
