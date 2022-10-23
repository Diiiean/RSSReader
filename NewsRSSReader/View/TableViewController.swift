
import UIKit
import SnapKit
import SafariServices
class TableViewController: UIViewController, NewsPresenterDelegate, UITextFieldDelegate {
    private var rssItems: [RSSItemModel]?
    private let presenter = NewsPresenter()
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(EntryCell.self, forCellReuseIdentifier: EntryCell.identifier)
       return tableView
    }()
    lazy var searchTextField: UITextField = {
        let textField = UITextField(frame: CGRect(x: 10, y: 10, width: (self.navigationController?.navigationBar.frame.size.width)!, height: 30))
        textField.placeholder = "Enter URL"
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.font = UIFont.systemFont(ofSize: 13)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        return textField
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        setUpViews()
    }
    func setUp() {
        self.navigationItem.title = "News"
        //SearchTextField
       self.navigationItem.titleView = searchTextField
        searchTextField.delegate = self
        //TABLE
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        // Presenter
        presenter.setViewDelegate(delegate: self)
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
//        tableView.estimatedRowHeight = 155.0
//        tableView.rowHeight = UITableView.automaticDimension
}
    func fetchData(urlString: String?) {
        rssItems?.removeAll()
        if urlString == nil {
            presenter.parseFeed(url: "https://rss.nytimes.com/services/xml/rss/nyt/Sports.xml") { [weak self] (rssItems) in
                self?.rssItems = rssItems
                    DispatchQueue.main.async {
                    
                    self?.tableView.refreshControl?.endRefreshing()
                    self?.tableView.reloadSections(IndexSet(integer: 0), with: .left)
                }
                
            }
        } else {
            presenter.parseFeed(url: urlString!) { [weak self] (rssItems) in
                
                self?.rssItems = rssItems
                    DispatchQueue.main.async {
                    
                    self?.tableView.refreshControl?.endRefreshing()
                    self?.tableView.reloadSections(IndexSet(integer: 0), with: .left)
                }
                
            }
        }
       
    }

    //MARK: - TextField Delegates methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
           print("TextField did begin editing method called")
       }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
           if let textFieldUrl = searchTextField.text {
               fetchData(urlString: textFieldUrl)
           }
           searchTextField.text = ""
       }

       func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
           print("TextField should begin editing method called")
           return true;
       }

       func textFieldShouldClear(_ textField: UITextField) -> Bool {
           print("TextField should clear method called")
           return true;
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
           //        cell.descriptionLabel.text = rssItems?[indexPath.row].description
                   if let item = rssItems?[indexPath.item] {
                       cell.item = item
                       cell.selectionStyle = .none
//
//                       if let cellStates = cellStates {
//                           cell.descriptionLabel.numberOfLines = (cellStates[indexPath.row] == .expanded ? 0 : 4)
//                       }
                   }
                   return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
                let cell = tableView.cellForRow(at: indexPath) as! EntryCell
                tableView.beginUpdates()
        
                cell.descriptionLabel.numberOfLines = (cell.descriptionLabel.numberOfLines == 0) ? 3 : 0
//                cellStates?[indexPath.row] = (cell.descriptionLabel.numberOfLines == 0) ? .expanded : .collapsed
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
//    override func numberOfSections(in tableView: UITableView) -> Int {
//
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        guard let rssItems = rssItems else { return 0 }
//return rssItems.count
//    }
//
//        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//            let cell = tableView.dequeueReusableCell(withIdentifier: EntryCell.identifier, for: indexPath) as! EntryCell
//    //        cell.descriptionLabel.text = rssItems?[indexPath.row].description
//            if let item = rssItems?[indexPath.item] {
//                cell.item = item
//                cell.selectionStyle = .none
//
//                if let cellStates = cellStates {
//                    cell.descriptionLabel.numberOfLines = (cellStates[indexPath.row] == .expanded ? 0 : 4)
//                }
//            }
//            return cell
//        }
//
//
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        tableView.deselectRow(at: indexPath, animated: true)
//        let cell = tableView.cellForRow(at: indexPath) as! EntryCell
//        tableView.beginUpdates()
//
//        cell.descriptionLabel.numberOfLines = (cell.descriptionLabel.numberOfLines == 0) ? 3 : 0
//        cellStates?[indexPath.row] = (cell.descriptionLabel.numberOfLines == 0) ? .expanded : .collapsed
//        tableView.endUpdates()
//
//        //Safari
//        guard let url = URL(string: presenter.currentLink) else { return }
//
//        let vc = SFSafariViewController(url: url)
//        present(vc, animated: true)
//        //Scroll to the top
//        self.scrollToTop()
//    }
//
//    private func scrollToTop() {
//        let topRow = IndexPath(row: 0, section: 0)
//        self.tableView.scrollToRow(at: topRow, at: .top, animated: true)
//    }
}
//extension TableViewController: UISearchResultsUpdating, UISearchBarDelegate {
//    text
//    func updateSearchResults(for searchController: UISearchController) {
//        let searchText = searchController.searchBar.text!
//        print(searchText)
//        if !searchText.isEmpty {
//            rssItems?.removeAll()
//            print(searchText)
//                presenter.parseFeed(url: searchText) { [weak self] (rssItems) in
//                    self?.rssItems = rssItems
//                    self?.cellStates = Array(repeating: .collapsed, count: rssItems.count)
//                    DispatchQueue.main.async {
//
//                        //self?.tableView.refreshControl?.endRefreshing()
//                        self?.tableView.reloadSections(IndexSet(integer: 0), with: .left)
//
//
//                }
//            }
//        }
//
//
//
//            self.tableView.reloadSections(IndexSet(integer: 0), with: .left)
//
//
//    }
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//       // rssItems?.removeAll()
//        tableView.reloadData()
//    }
//
//
//}
