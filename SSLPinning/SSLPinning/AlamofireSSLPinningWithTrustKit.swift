//
//  AlamofireSSLPinningWithTrustKit.swift
//  SSLPinning
//
//  Created by Sohanur Rahman on 20/11/24.
//

import Alamofire
import TrustKit
import Foundation
import CommonCrypto

class AlamofireSSLPinningWithTrustKit {
    
    var afSession: Session!
    
    init() {
        
        let trustKitConfig: [String:Any] = [
                    kTSKSwizzleNetworkDelegates: false,
                    kTSKPinnedDomains: [
                        Constants.shared.baseURL: [
                            kTSKEnforcePinning: true,
                            kTSKIncludeSubdomains: true,
                            kTSKPublicKeyHashes: [
                                "5xGZDDjnj/dHtOGADRsTIXID1OChTenrUGSfvKFCQuE=",
                                "1tY/jIR34efYAQAcKnK8wfOPS7ekRNkL79u+/EpEdKs="
                            ],
                        ]
                        
//                        [ "" , "5xGZDDjnj/dHtOGADRsTIXID1OCherenrUGSfvKFCQuE=" ]
                        
                        // Add More if required
                    ]
        ] as [String : Any]
                
        TrustKit.initSharedInstance(withConfiguration: trustKitConfig)
        
        
        let certificateName = "dog_ceo"
        
        guard let certificatePath = Bundle.main.path(forResource: certificateName, ofType: "cer"),
              let certificateData = NSData(contentsOfFile: certificatePath),
              let certificate = SecCertificateCreateWithData(nil, certificateData) else {
            print("Certificate not found or invalid")
            return
        }
        
        let evaluators: [String: ServerTrustEvaluating] = [
            "dog.ceo": PinnedCertificatesTrustEvaluator(
                certificates: [certificate],
                acceptSelfSignedCertificates: false, // Adjust based on your requirements
                performDefaultValidation: true,     // Validate certificate chain
                validateHost: true                  // Validate host
            )
        ]
        
        let serverTrustManager = ServerTrustManager(evaluators: evaluators)
        
        // Retain the Session object
        afSession = Session(
            configuration: URLSessionConfiguration.default, 
            delegate: AlamofireWithTrustKitSessionDelegate.init(),
            serverTrustManager: serverTrustManager
        )
    }
    
    func checkSSLPinning(completion: @escaping(String?) -> Void?) {
        
        
        print("\n\n\n\nChecking Alamofire SSL Pinning\n\n\n\n")
        
        // Make sure afSession is not nil and is retained
        guard let afSession = self.afSession else {
            print("Alamofire session is not initialized.")
            return
        }
        
        afSession.request(Constants.shared.apiURL)
            .validate()
            .response{ response in
                switch response.result {
                    
                case .success(let value):
                    AlertManager.shared.showAlert(title: "Success!!!", message: "SSL Pinning Successfull for Alamofire With TrustKit and Response Model Decoded to JSON")
                    
                    if let value {
                        do {
                            let jsonObject = try JSONSerialization.jsonObject(with: value, options: [])
                                
                            if let jsonDict = jsonObject as? [String: Any] {
                                completion(jsonDict["message"] as? String)
                            } else {
                                print("⚠️ JSON is not a dictionary.")
                                completion(nil)
                            }
                        } catch {
                            AlertManager.shared.showAlert(title: "Failed!", message: error.localizedDescription)
                        }
                    }
                    
                case .failure(let error):
                    
                    switch error {
                        
                    case .serverTrustEvaluationFailed(let reason):
                        print("Trusted Issue Occured!!! \n\(reason)")
                        
                    default:
                        if String(describing: error.localizedDescription) == "URLSessionTask failed with error: cancelled" {
                            print("\n\n\n SSL Pinning Failed For Alamofire With TrustKit!!! \n\n\n")
                            AlertManager.shared.showAlert(title: "Failed!", message: "SSL Pinning Failed For Alamofire With TrustKit.")
                        }
                        else{
                            AlertManager.shared.showAlert(title: "Failed!", message: error.localizedDescription)
                            print("Error Happened! Reason: \(error.localizedDescription)")
                        }
                    }
                }
            }
    }
}

class AlamofireWithTrustKitSessionDelegate: SessionDelegate {
    
    override func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        if TrustKit.sharedInstance().pinningValidator.handle(challenge, completionHandler: completionHandler) == false {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
