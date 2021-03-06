//
//  DetailViewController.swift
//  isbn
//
//  Created by Ian Arvizu on 13/06/17.
//  Copyright © 2017 Ian Arvizu. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    
    @IBOutlet weak var codigoISBN: UILabel!

    @IBOutlet weak var tituloLibro: UILabel!
    @IBOutlet weak var autoresLibro: UILabel!
    @IBOutlet weak var portadaLibro: UIImageView!
    
    
    var libro: String!

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let label = codigoISBN {
                label.text = detail.timestamp!.description
                libro = detail.timestamp!.description
                cargarLibro()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var detailItem: Event? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    
    
    func cargarLibro() {
        let config = URLSessionConfiguration.default // Session Configuration
        let session = URLSession(configuration: config) // Load configuration into Session
        let url = URL(string: "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"+libro)!
        
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
            if error != nil
            {
                
                let alert = UIAlertController(title: "Error 404", message: "Internet Problems...", preferredStyle: .alert)
                
                let cancelar = UIAlertAction(title: "OK", style: .cancel)
                
                alert.addAction(cancelar)
                
                self.present(alert, animated: true)
                
            }
            else
            {
                
                DispatchQueue.main.async {
                    
                    
                    //let texto = NSString(data: data! as Data, encoding: String.Encoding.utf8.rawValue)
                    
                    var autores: String = ""
                    
                    
                    if let Datos = data,
                        let json = try? JSONSerialization.jsonObject(with: Datos, options: []) as? [String: Any]
                    {
                        
                        if ((json?.keys.count)!>0)
                        {
                            if let ISBN = json?["ISBN:"+self.libro] as? [String: Any]
                            {
                                
                                if let cover = ISBN["cover"] as? [String: Any]
                                {
                                    let discoPortada = cover["medium"] as! NSString? as String?
                                    let imagen = URL(string: discoPortada!)
                                    let dataImage = try? Data(contentsOf: imagen!)
                                    self.portadaLibro.image = UIImage(data: dataImage!)
                                    
                                }
                                
                                let titulo = ISBN["title"] as! NSString as String
                                
                                let disco3 = ISBN["authors"] as! NSArray
                                
                                for i in 0 ..< disco3.count
                                {
                                    let disco4 = disco3[i] as! NSDictionary
                                    autores += disco4["name"] as! NSString as String + "\n"
                                    
                                }
                                
                                
                                self.tituloLibro.text = titulo
                                
                                self.autoresLibro.text = autores
                            }
                            
                        }
                            
                        else
                        {
                            let alert = UIAlertController(title: "ISBN invalido", message: "No se encontro ISBN", preferredStyle: .alert)
                            
                            let cancelar = UIAlertAction(title: "OK", style: .cancel)
                            
                            alert.addAction(cancelar)
                            
                            self.present(alert, animated: true)
                            
                        }
                        
                    }
                    
                    
                }
                
                
            }
            
        })
        task.resume()
        
    }

}

