import UIKit

protocol NewsPresenterDelegate: AnyObject {
    func fetchData(urlString: String?)
}

typealias PresenterDelegate = NewsPresenterDelegate & UIViewController

class NewsPresenter: NSObject, XMLParserDelegate
{
    weak var delegate: PresenterDelegate?
    
    public func setViewDelegate(delegate: PresenterDelegate) {
        self.delegate = delegate
    }
    private var rssItems: [RSSItemModel] = []
    
    private var currentElement = ""
    
    private var currentTitle: String = "" {
        didSet {
            currentTitle = currentTitle.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    private var currentDescription: String = "" {
        didSet {
            currentDescription = currentDescription.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    private var currentPubDate: String = "" {
        didSet {
            currentPubDate = currentPubDate.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    private var currentLink: String = "" {
        didSet {
            currentLink = currentLink.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    
    private var parserCompletionHandler: (([RSSItemModel]) -> Void)?
    
    func parseFeed(url: String, completionHandler: (([RSSItemModel]) -> Void)?) -> Void
    {
        self.parserCompletionHandler = completionHandler
        let request = URLRequest(url: URL(string: url)!)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                if let error = error {
                    print(error)
                }
                return
            }
            // parse xml data
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
        }
        task.resume()
    }
    
    // MARK: - XML Parser Delegate
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:])
    {
    // we assign the name of the element to currentElement, if the item tag is found, we reset the temporary variables of title, description and pubdate for later use
        currentElement = elementName
        if currentElement == "item" {
            currentTitle = ""
            currentDescription = ""
            currentPubDate = ""
            currentLink = ""
        }
    }
    // when the value of an element is found, this method gets called with a string representation of part of the characters of the current element
    func parser(_ parser: XMLParser, foundCharacters string: String)
    {
        switch currentElement {
        case "title": currentTitle += string
        case "description" : currentDescription += string
        case "pubDate": currentPubDate += string
        case "link": currentLink += string
        default: break
        }
    }
    // when we reach the closing tag /item is found, this method gets called
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        if elementName == "item" {
            let rssItem = RSSItemModel(title: currentTitle, description: currentDescription, pubDate: currentPubDate, link: currentLink)
            rssItems += [rssItem]
            print(rssItem)
        }
    }
    func parserDidEndDocument(_ parser: XMLParser) {
        parserCompletionHandler?(rssItems)
    }
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError.localizedDescription)
    }
}
