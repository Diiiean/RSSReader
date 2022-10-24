import UIKit
import SnapKit
import SafariServices
class TableViewController: UIViewController, NewsPresenterDelegate, UITextFieldDelegate, UISearchBarDelegate {
    private var rssItems: [RSSItemModel]?
    private let presenter = NewsPresenter()
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(EntryCell.self, forCellReuseIdentifier: EntryCell.identifier)
        return tableView
    }()
    private let searchVC = UISearchController(searchResultsController: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        setUpViews()
        createSearchBar()
    }
    private func createSearchBar() {
        searchVC.searchBar.placeholder = "Enter RSS chanel url"
        navigationItem.searchController = searchVC
        searchVC.searchBar.delegate = self
    }
    func setUp() {
        self.navigationItem.title = "News"
        //Table set up
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        // Presenter
        presenter.setViewDelegate(delegate: self)
        // data fetching
        fetchData(urlString: nil)
    }
    @objc private func didPullToRefresh() {
        fetchData(urlString: nil)
    }
    func setUpViews() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
    }
    func fetchData(urlString: String?) {
        rssItems?.removeAll()
        //called with default url
        if urlString == nil {
            presenter.parseFeed(url: "https://rss.nytimes.com/services/xml/rss/nyt/ArtandDesign.xml") { [weak self] (rssItems) in
                self?.rssItems = rssItems
                DispatchQueue.main.async {
                    self?.tableView.refreshControl?.endRefreshing()
                    self?.tableView.reloadData()
                    self?.tableView.reloadSections(IndexSet(integer: 0), with: .left)
                    self?.searchVC.dismiss(animated: true)
                }
            }
        }
        //called when user enter url
        else {
            presenter.parseFeed(url: urlString!) { [weak self] (rssItems) in
                self?.rssItems = rssItems
                //print(searchedRSSItems)
                DispatchQueue.main.async {
                    self?.tableView.refreshControl?.endRefreshing()
                    self?.tableView.reloadData()
                    self?.tableView.reloadSections(IndexSet(integer: 0), with: .left)
                }
            }
        }
    }
    
    //MARK: - Search Delegates methods
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchUrl = searchBar.text, !searchUrl.isEmpty else {
            return
        }
        fetchData(urlString: searchUrl)
        searchBar.text = ""
    }
}

// MARK: - Table view data source

extension TableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let rssItems = rssItems else { return 0 }
        return rssItems.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EntryCell.identifier, for: indexPath) as! EntryCell
        if let item = rssItems?[indexPath.item] {
            cell.item = item
            cell.selectionStyle = .none
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! EntryCell
        tableView.beginUpdates()
        cell.descriptionLabel.numberOfLines = (cell.descriptionLabel.numberOfLines == 0) ? 3 : 0
        tableView.endUpdates()
        //Safari
        guard let url = URL(string: (rssItems?[indexPath.item].link)!) else { return }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
        //Scroll to the top
        self.scrollToTop()
    }
    private func scrollToTop() {
        let topRow = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: topRow, at: .top, animated: true)
    }
}
