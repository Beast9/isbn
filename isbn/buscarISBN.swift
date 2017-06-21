//
//  buscarISBN.swift
//  isbn
//
//  Created by Ian Arvizu on 19/06/17.
//  Copyright © 2017 Ian Arvizu. All rights reserved.
//

import UIKit

class buscarISBN: UIViewController {

    @IBOutlet weak var etBuscar: UITextField!
    @IBOutlet weak var etJson: UITextView!
    @IBOutlet weak var ivPortada: UIImageView!
    var libro: String!
    var isbn: String? = nil
    var bandera: Bool? = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  
    @IBAction func btnBuscar(_ sender: Any) {
        if (self.etBuscar.text != "")
        {
            llamadaAsincrona()
        }
        else
        {
            self.showAlertMessage(title: "Advertencia", message: "Por favor digite el ISBN a buscar", owner: self)
            
            return
        }
    }
    
    func showAlertMessage (title: String, message: String, owner:UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{ (ACTION :UIAlertAction!)in
        }))
        self.present(alert, animated: true, completion: nil)
        
        self.bandera = false
    }

    
    func llamadaAsincrona() {
        let config = URLSessionConfiguration.default // Session Configuration
        let session = URLSession(configuration: config) // Load configuration into Session
        libro = etBuscar.text
        let url = URL(string: "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"+libro)!
        
        
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            
            if error != nil
            {
                
                let alert = UIAlertController(title: "Error 404", message: "Internet Problems...", preferredStyle: .alert)
                
                let cancelar = UIAlertAction(title: "OK", style: .cancel)
                
                alert.addAction(cancelar)
                
                self.present(alert, animated: true)
                
                self.bandera = false
                
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
                                    self.ivPortada.image = UIImage(data: dataImage!)
                                    
                                }
                                
                                let titulo = ISBN["title"] as! NSString as String
                                
                                let disco3 = ISBN["authors"] as! NSArray
                                
                                for i in 0 ..< disco3.count
                                {
                                    let disco4 = disco3[i] as! NSDictionary
                                    autores += disco4["name"] as! NSString as String + "\n"
                                    
                                }
                                
                                self.etJson.text = "TITULO: \n"
                                self.etJson.text = self.etJson.text + titulo+"\n\n"
                                
                                self.etJson.text = self.etJson.text + "AUTORES: \n"
                                self.etJson.text = self.etJson.text + autores
                                
                                self.bandera = true
                                self.isbn = self.libro
                            }
                            
                        }
                            
                        else
                        {
                            let alert = UIAlertController(title: "ISBN invalido", message: "No se encontro ISBN", preferredStyle: .alert)
                            
                            let cancelar = UIAlertAction(title: "OK", style: .cancel)
                            
                            alert.addAction(cancelar)
                            
                            self.present(alert, animated: true)
                            
                            self.bandera = false
                            
                        }
                        
                    }
                    
                    
                }
                
                
            }
            
        })
        task.resume()
        
    }

    
    @IBAction func addButton(_ sender: Any) {
        performSegue(withIdentifier: "agregar", sender: self)
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "agregar" {

            let controller = segue.destination as! MasterViewController
            controller.isbn = isbn
        }
    }
    

}
