

import UIKit
import Alamofire
import SwiftyJSON


class ServerManager: NSObject {

    static let shared = ServerManager()

    typealias Completion = (Bool, JSON, String) -> ()
  
    let baseUrl = "http://junior.balinasoft.com/api/"
    //MARK:- Sign up
    func signUp(login:String, password:String, completion: @escaping Completion) {
        
        let params:Parameters = ["login":login,"password":password]
        
        Alamofire.request(baseUrl + "account/signup", method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).response {
            response in
            self.responseHandler(response: response, completion: completion)
        }
    }
    //MARK:- Sign in
    func signIn(login:String, password:String, completion: @escaping Completion) {
        
        let params:Parameters = ["login":login,"password":password]
        
        Alamofire.request(baseUrl + "account/signin", method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).response {
            response in
            self.responseHandler(response: response, completion: completion)
        }
    }
    //MARK:- Get images from the server
    func getUserImages(page:Int ,completion: @escaping Completion) {
        
        guard let token = token else { return }
        
        let params: Parameters = ["page" : page]
        let headers: HTTPHeaders = ["Access-Token" : token]
        
        Alamofire.request(baseUrl + "image", method: .get, parameters: params, encoding: URLEncoding.default, headers: headers).response { (response) in
            self.responseHandler(response: response, completion: completion)
        }
    }
    //MARK:- Upload images to the server
    func getImage(data: String, date: Int, lat: String, lng: String, completion: @escaping Completion) {
        
        guard let token = token else { return }
        
        let params:Parameters = ["base64Image" : data, "date" : date, "lng" : lng, "lat" : lat]
        let headers: HTTPHeaders = ["Access-Token": token]
        
        Alamofire.request(baseUrl + "image", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).response {
            response in
            self.responseHandler(response: response, completion: completion)
        }
    }
    
    //MARK: - Delete photo
    func deletePhoto(photoId:String, completion: @escaping Completion) {
        
        guard let token = token else { return }
        
        let headers: HTTPHeaders = ["Access-Token" : token]
        
        Alamofire.request(baseUrl + "image/\(photoId)"  , method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers).response {
            response in
            self.responseHandler(response: response, completion: completion)
        
        }
        
    }
    
    //MARK: - Post comment
    func postComment(text:String,photoId:String,completion: @escaping Completion) {
        
        guard let token = token else { return }
        
        let params: Parameters = ["text":text,"imageId":photoId]
        let headers: HTTPHeaders = ["Access-Token" : token]
        
        Alamofire.request(baseUrl + "image/\(photoId)/comment", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).response {
            response in
            self.responseHandler(response: response, completion: completion)
            
        }
        
    }
    //MARK: - Get comments
    func getComment(photoId:String,page:Int,completion: @escaping Completion) {
        
        guard let token = token else { return }
        
        let params: Parameters = ["imageId":photoId,"page":page]
        let headers: HTTPHeaders = ["Access-Token" : token]
        
        Alamofire.request(baseUrl + "image/\(photoId)/comment", method: .get, parameters: params, encoding: JSONEncoding.default, headers: headers).response {
            response in
            self.responseHandler(response: response, completion: completion)
            
        }
        
    }
    //MARK: - Delete comment
    
    func deleteComment(photoId:String,commentId:String,completion: @escaping Completion) {
        
        guard let token = token else { return }
        
       // let params: Parameters = ["imageId":photoId,"commentId":commentId]
        let headers: HTTPHeaders = ["Access-Token" : token]
        
        Alamofire.request(baseUrl + "image/\(photoId)/comment/\(commentId)", method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers).response {
            response in
            self.responseHandler(response: response, completion: completion)
            
        }
    }
    
    //MARK: - ResponseHandler
    
    func responseHandler(response: DefaultDataResponse, completion: @escaping Completion){
        let status = response.response?.statusCode
        let data = response.data
        if let status = status {
            if status == 200 || status == 201{
                if let data = data {
                    let json =  JSON(data: data)
                    completion(true, json, "")
                } else {
                    completion(true, [], "")
                }
            } else if status >= 500 {
                completion(false, "", "Сервер не работает")
            } else{
                
                if let data = data {
                    let json =  JSON(data: data)
                    print(json)
                    if let message = json["detail"].string{
                        completion(false, json, message)
                    } else {
                        completion(false, json, "Unknown error")
                    }
                }
                completion(false, [], "Unknown error")
            }
        }
    }
}


