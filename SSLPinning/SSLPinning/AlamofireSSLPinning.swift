//
//  AlamofireSSLPinning.swift
//  SSLPinning
//
//  Created by Sohanur Rahman on 21/11/24.
//

import Alamofire
import Foundation
import CommonCrypto

class AlamofireSSLPinning {
    
    var afSession: Session!
    
    init() {
        afSession = Session(
            configuration: URLSessionConfiguration.default, 
            delegate: AlamofireSessionDelegate.init()
        )
    }
    
    func checkSSLPinning(completion: @escaping(String?) -> Void?) {
        
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
                    
                    AlertManager.shared.showAlert(title: "Success!!!", message: "SSL Pinning Successfull for Alamofire and Response Model Decoded to JSON.")
                    
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
                        AlertManager.shared.showAlert(title: "Failed!", message: "Trusted Issue Occured!!! \n\(reason)")
                        
                    default:
                        if String(describing: error.localizedDescription) == "URLSessionTask failed with error: cancelled" {
                            AlertManager.shared.showAlert(title: "Failed!", message: "SSL Pinning Failed For Alamofire!!!")
                            print("\n\n\n SSL Pinning Failed For Alamofire!!! \n\n\n")
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

class AlamofireSessionDelegate: SessionDelegate {
    
    override func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        guard let serverTrust = challenge.protectionSpace.serverTrust, let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            return
        }
        
        if let serverPublicKey = SecCertificateCopyKey(certificate), let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey, nil) {
            let data: Data = serverPublicKeyData as Data
            let serverHashKey = SSLPinningUtility().sha256(data: data)
            
            print("Current Server Key: \(serverHashKey)")
            
            if Constants.shared.publicServerKey.contains( serverHashKey ) { // If there is multiple Base URL then we need to check contains.
                let credential: URLCredential = URLCredential(trust: serverTrust)
                print("\nPublic Key pinning is successfull")
                completionHandler(.useCredential, credential)
            } else {
                print("\nPublic Key pinning is failed")
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        }
    }
}
