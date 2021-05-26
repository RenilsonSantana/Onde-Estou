//
//  ViewController.swift
//  Onde Estou
//
//  Created by Renilson Santana on 25/05/21.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    // MARK: - Atributos
    
    var gerenciadorLocalizacao = CLLocationManager()
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var labelVelocidade: UILabel!
    @IBOutlet weak var labelLatitude: UILabel!
    @IBOutlet weak var labelLongitude: UILabel!
    @IBOutlet weak var labelEndereco: UILabel!
    @IBOutlet weak var mapa: MKMapView!

    // MARK: - Cycle Life
    
    override func viewDidLoad() {
        super.viewDidLoad()
        solicitaPermissao()
    }
    
    // MARK: - Metodos

    func solicitaPermissao(){
        gerenciadorLocalizacao.delegate = self
        gerenciadorLocalizacao.desiredAccuracy = kCLLocationAccuracyBest
        gerenciadorLocalizacao.requestWhenInUseAuthorization()
        gerenciadorLocalizacao.startUpdatingLocation()
    }
    
    func configuraEndereco(_ localizacaoUsuario: CLLocation){
        CLGeocoder().reverseGeocodeLocation(localizacaoUsuario) { (detalhesLocal, erro) in
            var rua = ""
            var numero = ""
            var cidade = ""
            var bairro = ""
            var cep = ""
            var pais = ""
            var estado = ""
            guard let dadosLocal = detalhesLocal?.first else {return}
            if dadosLocal.thoroughfare != nil{
                rua = dadosLocal.thoroughfare!
            }
            if dadosLocal.subThoroughfare != nil{
                numero = dadosLocal.subThoroughfare!
            }
            if dadosLocal.locality != nil {
                cidade = dadosLocal.locality!
            }
            if dadosLocal.subLocality != nil {
                bairro = dadosLocal.subLocality!
            }
            if dadosLocal.postalCode != nil {
                cep = dadosLocal.postalCode!
            }
            if dadosLocal.country != nil{
                pais = dadosLocal.country!
            }
            if dadosLocal.administrativeArea != nil {
                estado = dadosLocal.administrativeArea!
            }
            //guard let subAdministrativeArea = dadosLocal.subAdministrativeArea else{return}
            
            
            self.labelEndereco.text = rua + ", " + numero + " - " + bairro + " - " + cidade
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status != .authorizedWhenInUse{
            let alert = UIAlertController(title: "Permissão de localizacão", message: "Permissão de acesso a localizacão necessária para o aplicativo funcionar", preferredStyle: .alert)
            
            let acaoConfiguracoes = UIAlertAction(title: "Abrir Configuracões", style: .default) { acaoConfiguracoes in
                if let configuracoes = URL(string: UIApplication.openSettingsURLString){
                    UIApplication.shared.open(configuracoes)
                }
            }
            alert.addAction(acaoConfiguracoes)
            
            let cancelar = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
            alert.addAction(cancelar)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let localizacaoUsuario = locations.last else {return}
        
        let latitude = localizacaoUsuario.coordinate.latitude
        let longitude = localizacaoUsuario.coordinate.longitude
        let localizacao = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let regiao = MKCoordinateRegion(center: localizacao, span: span)
        
        mapa.setRegion(regiao, animated: true)
        
        labelLatitude.text = String(latitude)
        labelLongitude.text = String(longitude)
        
        if localizacaoUsuario.speed > 0{
            labelVelocidade.text = String(localizacaoUsuario.speed)
        }
        else{
            labelVelocidade.text = "0"
        }
        
        configuraEndereco(localizacaoUsuario)
    }
}

