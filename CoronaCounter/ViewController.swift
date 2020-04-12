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

struct Info{
    let confirms, recovers, deaths :String;
    
    init(confirms confirms:String,recovers recovers:String,deaths deaths: String){
        self.confirms = confirms;
        self.recovers = recovers;
        self.deaths = deaths;
    }
}

class ViewController: NSViewController, WKUIDelegate, WKNavigationDelegate{
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
    let statusBarMenu = NSMenu(title: "Cap Status Bar Menu")
    //    var appDelegate = NSApplication.shared.delegate as! AppDelegate
    var infoByCountryDict: [String: Info] = [String: Info]()
    var gameTimer: Timer?
    var web: WKWebView!
    var curCountry: String? = nil
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        web = WKWebView(frame: .zero, configuration: webConfiguration)
        web.uiDelegate = self
        web.navigationDelegate = self
        let myURL = URL(string:"https://en.wikipedia.org/wiki/Template:2019%E2%80%9320_coronavirus_pandemic_data#covid19-container")
        let myRequest = URLRequest(url: myURL!)
        web.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        web.load(myRequest)
        
        statusItem.menu = statusBarMenu;
        if let button = statusItem.button {
            button.title = "Loading..."
        }
        print("schedule a timer");
        gameTimer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(loadWeb), userInfo: nil, repeats: true)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            print(Float(web.estimatedProgress))
            if(Float(web.estimatedProgress) == 1.0){
                loadItems()
            }
        }
    }
    
    func loadItems(){
        web.evaluateJavaScript("document.documentElement.outerHTML",
                               completionHandler: { (html: Any?, error: Error?) in
                                if let doc = try? HTML(html: html as! String, encoding: .utf8) {
                                    print("below is the thing")


                                    
                                    self.statusItem.menu?.removeAllItems();
                                    
                                    //                                    let countryNameSpans = doc.xpath("//*/c-wiz/div/div/div/div/div/div/div/div/div/div/div/table/tbody/tr/td/span")
                                    let countryNameSpans:XPathObject = doc.xpath("//*/tbody/tr/th[2]/a")
                                    
                    
                                    //var countryNameSpans:[XPathObject] = []

                                    print(countryNameSpans.count)
                                    //print(countryNameSpans[225])

                                    
                                    if countryNameSpans.count != 0{
                                        
                                        if countryNameSpans.count < 10{
                                            self.loadItems()
                                        }

//                                        let worldConfirm = doc.css("#thetable > thead > tr:nth-child(2) > th:nth-child(3)")
//                                        print(worldConfirm.first?.text!)
//                                        let worldDeaths = doc.xpath("//*/thead/tr[2]/th[3]/span/b")[0].text
//                                        let worldRecover = doc.xpath("//*/thead/tr[2]/th[4]/span/b")[0].text
//
                                        
//                                        self.infoByCountryDict["Worldwide"] = Info(confirms: "", recovers: worldRecover!, deaths: worldDeaths!);
//                                        let worldItem = NSMenuItem.init(title:"Worldwide", action:  #selector(self.printQuote(_:)), keyEquivalent: "");
//                                        worldItem.target = self;
//                                        self.statusItem.menu?.addItem(worldItem);
                                        
                                        let confirmSpans = doc.xpath("//*/tbody/tr/td[1]")
                                        let recoverSpans = doc.xpath("//*/tbody/tr/td[3]")
                                        let deathSpans = doc.xpath("//*/tbody/tr/td[2]")
                                        
                                        let countryName = self.curCountry ?? countryNameSpans.first?.text;
                                        self.curCountry = countryName;
                                        
                                        for i in 0..<countryNameSpans.count {
                                            self.infoByCountryDict[countryNameSpans[i].text!] = Info(confirms: confirmSpans[i].text!, recovers: recoverSpans[i].text!, deaths: deathSpans[i].text!);
                                            let item = NSMenuItem.init(title: countryNameSpans[i].text!, action:  #selector(self.printQuote(_:)), keyEquivalent: "");
                                            item.target = self;
                                            self.statusItem.menu?.addItem(item);
                                            
                                            print(countryNameSpans[i].text)
                                        }
                                        
                                        let confirmed = self.infoByCountryDict[countryName!]?.confirms;
                                        let recovered = self.infoByCountryDict[countryName!]?.recovers;
                                        let deaths = self.infoByCountryDict[countryName!]?.deaths;
                                        
                                        let quitItem = NSMenuItem(title: "Quit CoronaCounter", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
                                        
                                        self.statusBarMenu.addItem(NSMenuItem.separator())
                                        self.statusBarMenu.addItem(quitItem)
                                        
                                        if let button = self.statusItem.button {
                                            print("\(countryName!): \(confirmed!) confirmed \(recovered!) recovered \(deaths!) deaths".replacingOccurrences(of: "\n", with: ""))
                                            button.title = "\(countryName!): \(confirmed!) confirmed \(recovered!) recovered \(deaths!) deaths".replacingOccurrences(of: "\n", with: "")
                                        }
                                    }else{
                                        if let button = self.statusItem.button {
                                            button.title = "Failed to fetch data, please update software."
                                        }
                                        
                                        let item = NSMenuItem(title: "Quit CoronaCounter", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
                                        self.statusBarMenu.addItem(item)
                                    }
                                }
        })
    }
    
    override func viewDidLoad() {
        print("viewDidLoad")
        super.viewDidLoad()
    }
    
    @objc func loadWeb(){
        print("load web called")
        let myURL = URL(string:"https://google.com/covid19-map/?hl=en")
        let myRequest = URLRequest(url: myURL!)
        web.load(myRequest)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("web view called")
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
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

