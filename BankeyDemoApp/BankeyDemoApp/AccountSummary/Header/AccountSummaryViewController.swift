
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
    
    var profileManager: ProfileManageable = ProfileManager()
    
    var isLoaded = false
    
    lazy var errorAlert: UIAlertController = {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        return alert
    }()
    
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
        setUpSkeleton()
        fetchData()
        
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = appColor
        
        tableView.register(AccountSummaryCell.self, forCellReuseIdentifier: AccountSummaryCell.cellIdentifier)
        tableView.register(SkeletonCell.self, forCellReuseIdentifier: SkeletonCell.cellIdentifier)
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
    func setUpSkeleton() {
        let row = Account.makeSkeleton()
        accounts = Array(repeating: row, count: 10)
        configureTableCells(with: accounts)
    }
}

extension AccountSummaryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard !accountCellViewModels.isEmpty else {return UITableViewCell()}
        let account = accountCellViewModels[indexPath.row]
        if isLoaded {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AccountSummaryCell.cellIdentifier, for: indexPath) as? AccountSummaryCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.configure(with: account)
        return cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SkeletonCell.cellIdentifier, for: indexPath) as? SkeletonCell else {
            return UITableViewCell()
        }
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

// MARK: - Networking
extension AccountSummaryViewController {
    private func fetchData() {
        let group = DispatchGroup()
        
        // Testing - random number selection
        let userId = String(Int.random(in: 1..<4))
        
        fetchProfile(group: group, userId: userId)
        fetchAccounts(group: group, userId: userId)
        
        group.notify(queue: .main) {
            self.reloadView()
        }
    }
    
  private   func fetchProfile(group: DispatchGroup, userId: String) {
    group.enter()
    profileManager.fetchProfile(forUserId: userId) { result in
        switch result {
        case .success(let profile):
            self.profile = profile
        case .failure(let error):
            self.displayError(error: error)
        }
        group.leave()
    }
}
    
private func fetchAccounts(group: DispatchGroup, userId: String) {
    group.enter()
    fetchAccounts(forUserId: userId) { result in
        switch result {
        case .success(let accounts):
            self.accounts = accounts
        case .failure(let error):
            self.displayError(error: error)
        }
        group.leave()
    }

}
private func reloadView() {
    self.tableView.refreshControl?.endRefreshing()
    
    guard let profile = self.profile else { return }
    
    self.isLoaded = true
    self.configureTableHeaderView(with: profile)
    self.configureTableCells(with: self.accounts)
    self.tableView.reloadData()
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
    private func showErrorAlert(title: String , message: String) {
        errorAlert.title = title
        errorAlert.message = message
        present(errorAlert, animated: true, completion: nil)
    }
    
    func displayError(error: NetworkError) {
        let titleAndMessage = titleAndMessage(for: error)
        self.showErrorAlert(title: titleAndMessage.0, message: titleAndMessage.1)
    }
    
  private  func titleAndMessage(for error: NetworkError) -> (String,String) {
        var title: String
        var message: String
        switch error {
        case .serverError:
            title = Constant.server_title_error.rawValue
            message = Constant.server_message_error.rawValue
        case .decodingError:
            title = Constant.decoding_title_error.rawValue
            message =  Constant.decoding_message_error.rawValue
        }
        return(title,message)
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
        reset()
        setUpSkeleton()
        tableView.reloadData()
        fetchData()
    }
    func reset() {
        profile = nil
        accounts = []
        isLoaded = false
    }
}
// MARK: Unit testing
extension AccountSummaryViewController {
    func titleAndMessageForTesting(for error: NetworkError) -> (String, String) {
            return titleAndMessage(for: error)
    }
    
    func forceFetchProfile() {
        fetchProfile(group: DispatchGroup(), userId: "1")
    }
    
    func forcefetchAccount() {
        fetchAccounts(group: DispatchGroup(), userId: "1")
    }
}
