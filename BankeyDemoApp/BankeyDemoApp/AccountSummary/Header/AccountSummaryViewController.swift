
//
//  AccountSummaryViewController.swift
//  BankeyDemoApp
//
//  Created by scmc-mac3 on 26/01/22.
//

import UIKit

class AccountSummaryViewController: UIViewController {
    var tableView = UITableView()
    
    // Request Models
    var profile: Profile?
    var accounts: [Account] = []
    
    // View Models
    var headerViewModel = AccountSummaryHeaderView.ViewModel(welcomeMessage: "Welcome", name: "", date: Date())
    
    //Components
    var accountCellViewModels: [AccountSummaryCell.ViewModel] = []
    var headerView = AccountSummaryHeaderView(frame: .zero)
    
    let refreshControl = UIRefreshControl()
    
    lazy var logoutBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logOutTapped))
        barButtonItem.tintColor = .label
        return barButtonItem
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
       
    }
}

extension AccountSummaryViewController {
    private func setup() {
        setUpNavigationBar()
        setupTableView()
        setupTableHeaderView()
        setUpRefreshControl()
        fetchData()
        
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = appColor
        
        tableView.register(AccountSummaryCell.self, forCellReuseIdentifier: AccountSummaryCell.cellIdentifier)
        tableView.rowHeight = AccountSummaryCell.rowHeight
        tableView.tableFooterView = UIView()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    func setupTableHeaderView() {
        
        var size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        size.width = UIScreen.main.bounds.width
        headerView.frame.size = size
        tableView.tableHeaderView = headerView
    }
    
    func setUpRefreshControl() {
        refreshControl.tintColor = appColor
        refreshControl.addTarget(self, action: #selector(refreshContent), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
}

extension AccountSummaryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AccountSummaryCell.cellIdentifier, for: indexPath) as? AccountSummaryCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        let viewModel = accountCellViewModels[indexPath.row]
        cell.configure(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }
}

extension AccountSummaryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension AccountSummaryViewController {
    
    private func fetchData() {
        
        let group = DispatchGroup()
        let userID = String(Int.random(in: 1..<4))
        
        group.enter()
        fetchProfile(forUserId: userID) { result in
            switch result {
            case .success(let profile):
                self.profile = profile
                self.configureTableHeaderView(with: profile)
                self.tableView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
            group.leave()
        }
        
        group.enter()
        fetchAccounts(forUserId: userID) { result in
            switch result {
            case .success(let accounts):
                self.accounts = accounts
                self.configureTableCells(with: accounts)
                self.tableView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
        }
        
    }
    
    private func configureTableHeaderView(with profile: Profile ) {
        let vm = AccountSummaryHeaderView.ViewModel(welcomeMessage: "Good morning", name: profile.firstName, date: Date())
        headerView.configure(viewModel: vm)
    }
    
    private func configureTableCells(with account: [Account]) {
        accountCellViewModels = account.map({ account in
            
            AccountSummaryCell.ViewModel(accountType: account.type,
                                         accountName: account.name,
                                         balance: account.amount)
        })
    }
}




extension AccountSummaryViewController {
    
    private func setUpNavigationBar() {
        navigationItem.rightBarButtonItem = logoutBarButtonItem
    }
    
    @objc func logOutTapped(sender: UIButton) {
        NotificationCenter.default.post(name: .logout, object: nil)
    }
    
    @objc func refreshContent() {
        fetchData()
    }
}
