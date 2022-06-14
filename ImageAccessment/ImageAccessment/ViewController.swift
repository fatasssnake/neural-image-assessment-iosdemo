//
//  ViewController.swift
//  ImageAccessment
//
//  Created by 何可颐 on 2022/5/20.
//

import UIKit
import Alamofire


class ViewController: UIViewController {
    

    
    
    @IBOutlet weak var score: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pickPhoto: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func pick(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
        
    }
    @IBAction func eva(){
        if imageView.image == nil{
            print("image is not exsist!")
        }else{
            //            AFPostImage(image: imageView.image!)
            UploadImage(image: imageView.image!)
        }
    }
//    func AFPostImage(image:UIImage){
//        let urlString="http://159.75.246.129/fatsnake/predict"
//        let httpHeader=HTTPHeaders()
//        let imageData:Data=image.jpegData(compressionQuality: 0.5)!
//        let imageName:Int = 8888
//        let str = String(imageData.base64EncodedString())
//
//        //        while true{
//        //            Thread.sleep(forTimeInterval: 5.0)
//        AF.upload(multipartFormData: { multiPart in
//            multiPart.append(imageData, withName: "file", mimeType: "image/jpeg")
//        }, to: urlString, method: .post, headers: httpHeader).uploadProgress(queue: .main) { progress in
//        }.responseJSON { res in
//
//            debugPrint(res)
//        }
//
//
//
//        //        }
//
//    }
    func UploadImage(image:UIImage){
        // your image from Image picker, as of now I am picking image from the bundle
        //            let image = UIImage(named: "myimg.jpg",in: Bundle(for: type(of:self)),compatibleWith: nil)
        let imageData = image.jpegData(compressionQuality: 0.7)
        
        //        let imageS=String(decoding: imageData! , as: UTF8.self)
        
        
        let url =  "http://159.75.246.129/fatsnake/predict"
        var urlRequest = URLRequest(url: URL(string: url)!)
        
        urlRequest.httpMethod = "post"
        let bodyBoundary = "--------------------------\(UUID().uuidString)"
        urlRequest.addValue("multipart/form-data; boundary=\(bodyBoundary)", forHTTPHeaderField: "Content-Type")
        
        //attachmentKey is the api parameter name for your image do ask the API developer for this
        // file name is the name w hich you want to give to the file
        let requestData = createRequestBody(imageData: imageData!, boundary: bodyBoundary, fileName: "file")
        
        urlRequest.addValue("\(requestData.count)", forHTTPHeaderField: "content-length")
        urlRequest.httpBody = requestData
        
        let str = String(requestData.base64EncodedString())
        
        
        URLSession.shared.dataTask(with: urlRequest) { (data, httpUrlResponse, error) in
            
            if(error == nil && data != nil && data?.count != 0){
                do {
                    let response = try JSONDecoder().decode(Score.self, from: data!)
                    print(response.pred)
                    
                    DispatchQueue.main.async {
                        self.score.text = "score：\(String(format :"%.2f",response.pred))"
                    }
                }

                catch let decodingError {
                    debugPrint(decodingError)
                }
                print(String(decoding:data!,as: UTF8.self))
                
//                print(httpUrlResponse)
            }
        }.resume()
    }
    
    func createRequestBody(imageData: Data, boundary: String,  fileName: String) -> Data{
        let lineBreak = "\r\n"
        var requestBody = Data()
        
        requestBody.append("\(lineBreak)--\(boundary + lineBreak)" .data(using: .utf8)!)
        requestBody.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\(lineBreak)" .data(using: .utf8)!)
        requestBody.append("Content-Type: image/jpeg \(lineBreak + lineBreak)" .data(using: .utf8)!) // you can change the type accordingly if you want to
        requestBody.append(imageData)
        requestBody.append("\(lineBreak)--\(boundary)--\(lineBreak)" .data(using: .utf8)!)
        
        return requestBody
    }
    
    //加入launchscreen的动画
    
    
}

struct Score :Codable{
    var pred:Double
}


extension ViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //        var image = info[edite]
        //        "UIImagePickerControllerEditedImage"
        print("\(info)")
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage{
            imageView.image=image;
            //            post(img: image)
            //            UploadImage(image: image)
            //            AFPostImage(image: image)
            
        }
        picker.dismiss(animated: true,completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true,completion: nil)
    }
    //    func AFPostImage(image:UIImage){
    //        let urlString="http://159.75.246.129/fatsnake/predict"
    //        let httpHeader=HTTPHeaders()
    //        let imageData:Data=image.jpegData(compressionQuality: 0.5)!
    //        let imageName:Int = 8888
    //
    //
    //        AF.upload(multipartFormData: { multiPart in
    //            multiPart.append(imageData, withName: "pic", fileName: "\(imageName).jpg", mimeType: "image/jpg")
    //        }, to: urlString, method: .post, headers: httpHeader).uploadProgress(queue: .main) { progress in
    //
    //        }.responseJSON { res in
    //            debugPrint(res)
    //        }
    //    }
    //        Alamofire.upload(multipartFormData: { multiPart in
    //                    multiPart.append(imageData, withName: "pic", fileName: "\(imageName).jpg", mimeType: "image/jpg")
    //                }, to: urlString, method: .post, headers: httpHeader).uploadProgress(queue: .main) { progress in
    //
    //                }.responseJSON { res in
    //                    debugPrint(res)
    //                }
    //        upload(multipartFormData: { (multipartFormData) in
    //            multipartFormData.append(imageData, withName: "file",fileName: "1.jpg",mimeType: "image/jpeg")
    //        }, to: urlString, method: .post,headers: httpHeader, enc)
}



//    func post(img:UIImage){
//        print("post!")
//        guard let url=URL(string: "http://159.75.246.129/fatsnake/predict") else {return}
//        var request = URLRequest(url: url)
//        let boun="-------------------------123123"
//        request.addValue("multipart/form-data;boundary="+boun, forHTTPHeaderField: "Content-Type")
//        request.httpMethod="POST"
//        guard let image=img.jpegData(compressionQuality: 1.0) else {return}
//
//        var body=Data()
//
//        body.append("--\(boun)\r\n".data(using: .utf8)!)
//        body.append("Content-Disposition: form-data;name=\"picture\"; filename=\"file.jpg\\r\n".data(using: .utf8)!)
////        "
//        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
//        body.append(image)
//        body.append("\r\n--\(boun)--\r\n".data(using: .utf8)!)
//
//        request.addValue("\(body.count)", forHTTPHeaderField: "content-length")
//        request.httpBody=body;
//
//
//
//        print(request.httpBody?.description)
//        let task=URLSession.shared.dataTask(with: request) {data,response,error in guard let data=data,error == nil else{return}
////            print("\(response)")
////            print("\(data)")
//            if let response = response as? HTTPURLResponse{
//                print(response)
//            }
////            do{
////                let response = try JSONSerialization.jsonObject(with: data,options: .allowFragments)
////                print(response)
////            }catch{
////                print(error)
////            }
//        }
//        task.resume()
//        }








