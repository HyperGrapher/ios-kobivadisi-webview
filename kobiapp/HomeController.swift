//
//  HomeController.swift
//  kobivadisi
//
//  Created by burak mestan on 13.02.2020.
//  Copyright © 2020 Burak Mestan. All rights reserved.
//

import UIKit
import WebKit

// URL parametrelerini ayırmak için gerekli extension
extension URL {
    subscript(queryParam:String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParam })?.value
    }
}

class HomeController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView!
    
    // Loading indicator
    
    private var loadingObservation: NSKeyValueObservation?

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = .black
        return spinner
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureWebview(link: "https://www.kobivadisi.com/")
        configureNavigationBar()
    }
    
    func configureWebview(link: String) {
          
          let url = URL(string: link)
          let request = URLRequest(url: url!)

          if webView == nil {
              webView = WKWebView()
              webView.navigationDelegate = self
              view = webView
          }
        
        setUpLoadingIndicator()
          
          webView?.load(request)
        
        // Pull to refresh
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadWebView(_:)), for: .valueChanged)
        webView.scrollView.addSubview(refreshControl)

         
          
      }
    
    // Loading Indicator for page loads
    func setUpLoadingIndicator(){
        
        view = webView
        
        loadingObservation = webView.observe(\.isLoading, options: [.new, .old]) { [weak self] (_, change) in
            guard let strongSelf = self else { return }
            
            let new = change.newValue!
            let old = change.oldValue!
            
            if new && !old {
                strongSelf.view.addSubview(strongSelf.loadingIndicator)
                strongSelf.loadingIndicator.startAnimating()
                NSLayoutConstraint.activate([strongSelf.loadingIndicator.centerXAnchor.constraint(equalTo: strongSelf.view.centerXAnchor),
                                             strongSelf.loadingIndicator.centerYAnchor.constraint(equalTo: strongSelf.view.centerYAnchor)])
                strongSelf.view.bringSubviewToFront(strongSelf.loadingIndicator)
            }
            else if !new && old {
                strongSelf.loadingIndicator.stopAnimating()
                strongSelf.loadingIndicator.removeFromSuperview()
            }
        }
    }
    
    // Tıklanan URL'leri sapta ve ilgili methodu çağır.
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        // link yazım hatalarından kaynaklı çökmeleri engellemek için,
        // linkler http veya https ile başlamalı
        guard let myUrl = navigationAction.request.url, let scheme = myUrl.scheme, scheme.contains("http") else {
            decisionHandler(.cancel)
            return
        }
        
        print("-----------------> URL: ", myUrl.absoluteString)

        
        if myUrl.absoluteString.contains("kobivadisi.com") {
            
            let params = URL(string: myUrl.absoluteString)!
            

            
            // extension method yardimiyla verilen query parametresini alir
            // Deep link alindiginda uygulama acilirken burada link sonunda query
            // parametresi varsa alinir ve "site" Q parametresinde bulunan link acilir
            if let actionParam: String = params["site"]{ // TODO sitedeeplink vs olabilir
                print("- - - - - -> QUERY PARAM: \(actionParam)")
                configureWebview(link: actionParam)
            }


        }


        decisionHandler(.allow)

       
    }


    
    
    // Navigation bar
    func configureNavigationBar() {
        
        
        navigationController?.navigationBar.barTintColor = .darkGray
        navigationController?.navigationBar.barStyle = .black
        
        // Webview ikonları - SAĞ taraf
                
        let exitIcon:UIBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_close").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleExit))
        
        
        let forwardIcon:UIBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "webview_forward").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleForward))
        
        
        let backwardIcon:UIBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "webview_backward").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleBackward))
        
        
        // Sağdaki ikonları ekle
        navigationItem.setRightBarButtonItems([exitIcon,  forwardIcon, backwardIcon ], animated: true)


    }
    
    // pull to refresh
    @objc func reloadWebView(_ sender: UIRefreshControl) {
        webView.reload()
        sender.endRefreshing()
    }
    
    
    // Toolbar action ikonları için methodlar
    
    
    // Exit app
    @objc func handleExit() {
        
        UIControl().sendAction(#selector(NSXPCConnection.suspend),
                               to: UIApplication.shared, for: nil)
        
    }

    
    
    @objc func handleForward() {
        
        if webView.canGoForward {
            webView?.goForward()
        }
        
    }
    
    
    @objc func handleBackward() {
        
        if webView.canGoBack {
            webView?.goBack()
        }
        
    }
}
