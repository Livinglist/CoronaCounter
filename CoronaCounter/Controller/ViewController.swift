//
//  ViewController.swift
//  CoronaCounter
//
//  Created by Jiaqi Feng on 4/8/20.
//  Copyright © 2020 Jiaqi Feng. All rights reserved.
//

import Cocoa
import WebKit
import Kanna
import Alamofire



class ViewController: NSViewController, WKUIDelegate, WKNavigationDelegate{
    
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
    let statusBarMenu = NSMenu(title: "Cap Status Bar Menu")
    var infoByCountryDict: [String: Info] = [String: Info]()
    var gameTimer: Timer?
    var web: WKWebView!
    var curCountry: String? = nil
    
    let url = "https://en.wikipedia.org/wiki/Template:2019%E2%80%9320_coronavirus_pandemic_data#covid19-container"
    
    override func viewDidLoad() {
//        print("viewDidLoad")
        super.viewDidLoad()
    }
        
    @objc func loadWeb(){
        web.load(requestURL())
    }
        
    override func loadView() {
        initWeb()
        initBarMenu()
        gameTimer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(loadWeb), userInfo: nil, repeats: true)
    }
    
    func initBarMenu() -> Void {
        statusItem.menu = statusBarMenu;
        if let button = statusItem.button {
            button.title = "Loading"
        }
    }
    
    func initWeb() -> Void {
        let webConfiguration = WKWebViewConfiguration()
        web = WKWebView(frame: .zero, configuration: webConfiguration)
        web.uiDelegate = self
        web.navigationDelegate = self
        web.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        web.load(requestURL())
    }
    
    func requestURL() -> URLRequest {
        let myURL = URL(string: url)
        return URLRequest(url: myURL!)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            
            if(Float(web.estimatedProgress) == 1.0){
                loadItems()
            }
        }
    }
    
    func loadItems(){
        web.evaluateJavaScript("document.documentElement.outerHTML", completionHandler: { (html: Any?, error: Error?) in
                if let doc = try? HTML(html: html as! String, encoding: .utf8) {
                    self.statusItem.menu?.removeAllItems();
                    let countryNameSpans:XPathObject = doc.xpath("//*/tbody/tr/th[2]/a")
                    if countryNameSpans.count != 0{
                        if countryNameSpans.count < 10{
                            self.loadItems()
                        }
                        let countryName = self.curCountry ?? countryNameSpans.first?.text;
                        self.curCountry = countryName;
                        self.initMenuItems(countryNameSpans, doc)
                        self.printDataOnBarMenu(countryName)
                    }else{
                        if let button = self.statusItem.button {
                            button.title = "Failed to fetch data, please update software."
                        }

                        self.addQuitButton()
                    }
                }
        })
    }
    
    func addQuitButton() -> Void {
        let quitItem = NSMenuItem(title: "Quit CoronaCounter", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        self.statusBarMenu.addItem(quitItem)
    }
    
    func printButtons(_ countryName: String?, _ confirmed: String?, _ recovered: String?, _ deaths: String?) -> Void {
        if let button = self.statusItem.button {
            print("\(countryName!): \(confirmed!) confirmed \(recovered!) recovered \(deaths!) deaths".replacingOccurrences(of: "\n", with: ""))
            button.title = "\(countryName!): \(confirmed!) confirmed \(recovered!) recovered \(deaths!) deaths".replacingOccurrences(of: "\n", with: "")
        }
    }
    
    func printDataOnBarMenu(_ countryName: String?) -> Void {
        
        let confirmed = self.infoByCountryDict[countryName!]?.confirms;
        let recovered = self.infoByCountryDict[countryName!]?.recovers;
        let deaths = self.infoByCountryDict[countryName!]?.deaths;
        
        addQuitButton()
        self.statusBarMenu.addItem(NSMenuItem.separator())
        printButtons(countryName, confirmed, recovered, deaths)
    }
    
    func initMenuItems(_ countryNameSpans: XPathObject, _ doc: HTMLDocument) -> Void {
        
        let confirmSpans = doc.xpath("//*/tbody/tr/td[1]")
        let recoverSpans = doc.xpath("//*/tbody/tr/td[3]")
        let deathSpans = doc.xpath("//*/tbody/tr/td[2]")
        for i in 0..<countryNameSpans.count {
            self.infoByCountryDict[countryNameSpans[i].text!] = Info(confirms: confirmSpans[i].text!, recovers: recoverSpans[i].text!, deaths: deathSpans[i].text!);
            let item = NSMenuItem.init(title: countryNameSpans[i].text!, action:  #selector(self.printQuote(_:)), keyEquivalent: "");
            item.target = self;
            self.statusItem.menu?.addItem(item);
            
        }
        
    }
    
    @objc func printQuote(_ sender: Any?) {
        let item:NSMenuItem = sender as! NSMenuItem
        print(item.title)
        curCountry = item.title;
        let confirmed = infoByCountryDict[item.title]?.confirms;
        let deaths = infoByCountryDict[item.title]?.deaths;
        let recovered = infoByCountryDict[item.title]?.recovers;
        
        statusItem.button?.title = "\(item.title): \(confirmed!) confirmed \(recovered!) recovered \(deaths!) deaths".replacingOccurrences(of: "\n", with: "");
    }
}

