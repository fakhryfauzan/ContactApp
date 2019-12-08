//
//  ViewController.swift
//  ContactApp
//
//  Created by fakhry fauzan on 08/12/19.
//  Copyright © 2019 fakhry fauzan. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
class contact {
    var imageLink:String
    var first: String
    var last: String
    var umur: String
    
    init(imageLink: String, first: String, last: String, umur: String) {
        self.imageLink = imageLink
        self.first = first
        self.last = last
        self.umur = umur
    }
}
class ViewController: UIViewController {
    var contactArray: [Int : contact] = [:]
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var ageText: UITextField!
    let photoURL = "http://vignette1.wikia.nocookie.net/lotr/images/6/68/Bilbo_baggins.jpg/revision/latest?cb=20130202022550"
    override func viewDidLoad() {
        super.viewDidLoad()
        getContact()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func getContact(){
        let jsonURL = "https://simple-contact-crud.herokuapp.com/contact"
        guard let url = URL(string: jsonURL) else{
            return
        }
        Alamofire.request(url).responseJSON { response in
            if response.error != nil {
            }
            let json = try! JSON(data: response.data!)
            guard let items = json["data"].array else{
                return
            }
            for item in items {
                let idName = item["id"].intValue
                let firstName = item["firstName"].stringValue
                let lastName = item["lastName"].stringValue
                let age = item["age"].stringValue
                let photo = item["photo"].stringValue
                self.contactArray.updateValue(contact(imageLink: photo, first: firstName, last: lastName, umur: age), forKey: idName)
                
                
            }
//            for value in self.contactArray.values {
//                print(value.first)
//            }
             self.tableView.reloadData()
        }
        
       
    }
    @IBAction func postAction(_ sender: Any) {
        if firstName.text!.isEmpty || lastName.text!.isEmpty || ageText.text!.isEmpty {
            
        }else {
            
            let parameters = ["id" : UUID().uuidString, "firstName": firstName.text!, "lastName": lastName.text!, "age": ageText.text!, "photo": photoURL] as [String : String]
            let url = URL(string: "https://simple-contact-crud.herokuapp.com/contact")!
            Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON {
                response in
                switch response.result {
                case .success:
                    print(response)
                    break
                case .failure(let error):
                    print(error)
                }
                
            }
        }
    }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        print(contactArray.keys.count)
        return contactArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! cell
        let isiContact = Array(contactArray.values)[indexPath.row]
        let url = URL(string: isiContact.imageLink)
        cell.gambar.downloadImage(from: url!)
        cell.gambar?.contentMode = .scaleAspectFill
        cell.firstName.text = isiContact.first
        cell.lastName.text = isiContact.last
        cell.umurName.text = isiContact.umur
        return cell
    }
    
}

class cell: UITableViewCell{
    @IBOutlet weak var gambar: UIImageView!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var umurName: UILabel!
    
}
extension UIImageView {
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    func downloadImage(from url: URL) {
        getData(from: url) {
            data, response, error in
             DispatchQueue.main.async() {
            guard let data = data, error == nil else {
                self.image = UIImage(named: "pictureNA")
                return
            }
           
                self.image = UIImage(data: data)
            }
        }
    }
}

extension UIImage {
    func resizeImage(_ dimension: CGFloat, opaque: Bool, contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImage {
        var width: CGFloat
        var height: CGFloat
        var newImage: UIImage
        
        let size = self.size
        let aspectRatio =  size.width/size.height
        
        switch contentMode {
        case .scaleAspectFit:
            if aspectRatio > 1 {                            // Landscape image
                width = dimension
                height = dimension / aspectRatio
            } else {                                        // Portrait image
                height = dimension
                width = dimension * aspectRatio
            }
            
        default:
            fatalError("UIIMage.resizeToFit(): FATAL: Unimplemented ContentMode")
        }
        
        if #available(iOS 10.0, *) {
            let renderFormat = UIGraphicsImageRendererFormat.default()
            renderFormat.opaque = opaque
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: renderFormat)
            newImage = renderer.image {
                (context) in
                self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), opaque, 0)
            self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }
        
        return newImage
    }
}


