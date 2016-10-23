//
//  ViewController.swift
//  openLibrary
//
//  Created by Walter Llano on 23/10/16.
//  Copyright © 2016 Walter Llano. All rights reserved.
//

import UIKit

class ViewController: UIViewController ,UITextFieldDelegate{
    //Conexiones de interfaz necesarias
    @IBOutlet weak var inputISBN: UITextField!
    @IBOutlet var textoResultado: UITextView!
    let direccionServicio = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
    
    @IBOutlet weak var imagenPortada: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Acción al buscar
    @IBAction func botonBuscar(sender: AnyObject) {
        if let isbnABuscar = inputISBN.text {
            realizarConexion(isbnABuscar)
        }
        
    }
    
    //Para quitar el texto cuando toca cualquier parte de la pantalla
    @IBAction func tocaronFondo(sender: UIControl){
        print( "tocaron el fondo")
        inputISBN.resignFirstResponder()
    }
    
    
    //Función para realizar la conexión al servidor
    func realizarConexion (ISBN : String){
        let urlCompleta = direccionServicio + ISBN
        print(urlCompleta)
        let urlAConsultar = NSURL(string: urlCompleta)
        let sesionConexion = NSURLSession.sharedSession()
        
        let bloqueConsulta = {(datos : NSData?, respuesta : NSURLResponse?, error : NSError?) -> Void in
            
            
            dispatch_async(dispatch_get_main_queue()) {
                if((respuesta) != nil){
                    self.mostrarResultadoDesdeJSON(datos,ISBN: ISBN)

                }else{
                    self.textoResultado.text = "Hubo un error al consultar el servicio, posiblemente no tiene acceso a internet o el servidor de OpenLibrary está presentando fallas."
                }
            }
            
        }
        
        let dt = sesionConexion.dataTaskWithURL(urlAConsultar!, completionHandler: bloqueConsulta)
        dt.resume()
    }
    
    
    
    
    func mostrarResultadoDesdeJSON(datos : NSData?,ISBN : String){
        do{
            var resultadoAImprimir = ""
            let json = try NSJSONSerialization.JSONObjectWithData(datos!, options: NSJSONReadingOptions.MutableLeaves)
            let diccionarioPadre = json as! NSDictionary
            if let nodoISBN = diccionarioPadre["ISBN:"+ISBN]{
                let diccionarioISBN = nodoISBN as! NSDictionary
                
                
                //Impresión título
                resultadoAImprimir += "Título:\n"
                let tituloString = diccionarioISBN["title"] as! String
                resultadoAImprimir += tituloString + "\n"
                
                //Impresión autores
                let arregloAutores = diccionarioISBN["authors"] as! NSArray
                
                if arregloAutores.count == 1{
                 resultadoAImprimir += "Autor:\n"
                }else if arregloAutores.count > 1{
                 resultadoAImprimir += "Autores:\n"
                }
                for esteAutor in arregloAutores{
                    let diccionarioAutor = esteAutor as! NSDictionary
                    let nombreAutor = diccionarioAutor["name"]
                    let nombreAutorString = nombreAutor as! String
                    resultadoAImprimir += nombreAutorString + "\n"
                }
                
                var direccionPortada : String? = nil
                //Captura de la imagen portada
                if let portada = diccionarioISBN["cover"]{
                    let diccionarioPortada = portada as! NSDictionary
                    if let portadaMediana = diccionarioPortada["medium"]{
                        direccionPortada = portadaMediana as? String
                    }
                }
                
                //Muestra de los resultados
                textoResultado.text = resultadoAImprimir
                self.imagenPortada.image = nil
                if direccionPortada != nil {
                    cargarImagen(direccionPortada!)
                }
            }else if diccionarioPadre.allValues.count == 0{
                self.imagenPortada.image = nil
                self.textoResultado.text = "No existe ningún libro con el ISBN: \(ISBN)"
            }
            
            
            
            
        }catch let e{
            print("Hubo un problema al parse el JSON error: \(e)" )
        }
    }
    
    
    func cargarImagen(urlString:String)
    {
        let imgURL: NSURL = NSURL(string: urlString)!
        let request: NSURLRequest = NSURLRequest(URL: imgURL)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request){
            (data, response, error) -> Void in
            
            if (error == nil && data != nil)
            {
                func display_image()
                {
                    self.imagenPortada.image = UIImage(data: data!)
                }
                
                dispatch_async(dispatch_get_main_queue(), display_image)
            }
            
        }
        
        task.resume()
    }
    
}







