
import UIKit
import SnapKit
import SafariServices
class TableViewController: UIViewController, NewsPresenterDelegate, UITextFieldDelegate {
    
    
   
    
    private var rssItems: [RSSItemModel]?
    private let presenter = NewsPresenter()
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(EntryCell.self, forCellReuseIdentifier: EntryCell.identifier)
        //tableView.translatesAutoresizingMaskIntoConstraints = false
       return tableView
    }()
    
    lazy var searchTextField: UITextField = {
        let textField = UITextField(frame: CGRect(x: 10, y: 10, width: (self.navigationController?.navigationBar.frame.size.width)!, height: 30))
       // let textField = UITextField()

        //textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter URL"
        //textField.sizeToFit()
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.font = UIFont.systemFont(ofSize: 13)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.clearButtonMode = UITextField.ViewMode.whileEditing;
        textField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        return textField
    }()
//    private let searchButt: UIButton = {
//        let button = UIButton()
//        button.setTitle("Test Button", for: .normal)
//         button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
//        return button
//    }()
    // Vertical Stack View
//    lazy var vStackView: UIStackView = {
//        let stack = UIStackView()
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        stack.axis = .vertical
//        stack.alignment = .leading
//        stack.spacing = 7
//        stack.distribution = .equalSpacing
//        //stack.distribution = .fillProportionally
//        stack.clipsToBounds = true
//        stack.addArrangedSubview(searchTextField)
//        stack.addArrangedSubview(tableView)
//
//
//
//        return stack
//    }()
//    private let searchController = UISearchController(searchResultsController: nil)
//    private var searchBarIsEmpty: Bool {
//        guard let text = searchController.searchBar.text else { return false }
//        return text.isEmpty
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        setUpViews()
    }
   
    func setUp() {
        self.navigationItem.title = "News"
              navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(didTapAdd))
        
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
        @objc private func didTapAdd() {
            let alert = UIAlertController(title: "Check another RSS Chanel", message: "Add RSS Chanel", preferredStyle: .alert)
            alert.addTextField { field in
                field.placeholder = "Enter channel URL"
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak self] (_) in
                if let field = alert.textFields?.first {
                    if let text = field.text, !text.isEmpty {
                        
                        self?.fetchData(urlString: text)

                    }
                }
            }))
            present(alert, animated: true)
        }
        
    @objc private func didPullToRefresh() {
        fetchData(urlString: nil)
    }
    @objc private func buttonAction() {
        
    }
    
    func setUpViews() {
        view.addSubview(tableView)
       
        //view.addSubview(searchTextField)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
//        searchTextField.snp.makeConstraints { make in
//            make.edges.equalTo()
//
//        }
        //TABLE
//        tableView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor).isActive = true
//        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
//        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
//        tableView.snp.makeConstraints { make in
//
//            make.edges.equalTo(vStackView)
//
//
//        }
        //TEXTFIELD
//        searchTextField.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//        searchTextField.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
//        searchTextField.bottomAnchor.constraint(equalTo: view.topAnchor).isActive = true
//        searchTextField.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
//        searchTextField.snp.makeConstraints { make in
////            make.size.equalTo(CGSize(width: view.snp.width, height: 30))
//            make.edges.equalTo(vStackView)
//
//
//        }
        
        tableView.estimatedRowHeight = 155.0
        tableView.rowHeight = UITableView.automaticDimension
       
        
        
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
   
//    private func configureSearchController() {
//        //Set up Search Controller
//        searchController.loadViewIfNeeded()
//        searchController.searchResultsUpdater = self
//        searchController.searchBar.delegate = self
//        searchController.obscuresBackgroundDuringPresentation = false
//        searchController.searchBar.enablesReturnKeyAutomatically = false
//        searchController.searchBar.returnKeyType = UIReturnKeyType.done
//        self.navigationItem.searchController = searchController
//        self.navigationItem.hidesSearchBarWhenScrolling = false
//        definesPresentationContext = true
//        searchController.searchBar.placeholder = "Enter link"
//    }

    //MARK: - TextField Delegates methods
    
  
    func textFieldDidBeginEditing(_ textField: UITextField) {
           print("TextField did begin editing method called")
       }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
    }

       func textFieldDidEndEditing(_ textField: UITextField) {
           if let textFieldUrl = searchTextField.text {
               presenter.parseFeed(url: textFieldUrl) { [weak self] (rssItems) in
                   self?.rssItems = rssItems
                  
                  
                   DispatchQueue.main.async {
                       
                       self?.tableView.refreshControl?.endRefreshing()
                       self?.tableView.reloadSections(IndexSet(integer: 0), with: .left)
                   }
                   
               }
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
