//
//  ViewController.swift
//  ImageAI
//
//  Created by 梅北文仁 on 2018/05/29.
//  Copyright © 2018年 梅北文仁. All rights reserved.
//

import UIKit
import CoreML
import Vision
import AVFoundation

class ViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate{

    @IBOutlet weak var photoImage : UIImageView!
    @IBOutlet weak var photoInfoDispay: UITextView!
    
    var imagePicker : UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func takePhoto(_ sender: Any) {
        present(imagePicker,animated: true,completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        photoImage.image = info[UIImagePickerControllerOriginalImage] as?
        UIImage
        imagePicker.dismiss(animated: true, completion: nil)
        imageInferrence(image: (info[UIImagePickerControllerOriginalImage] as?
            UIImage)!)
    }
    func imageInferrence(image:UIImage){
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model)else{
            fatalError("モデルをロードできません")
        }
        let request = VNCoreMLRequest(model:model){
            [weak self] request,error in
            
            guard let results = request.results as? [VNClassificationObservation],
                let firstResult = results.first else{
                    fatalError("判定をできません")
        }
            DispatchQueue.main.async{
                self?.photoInfoDispay.text = "accracy = \(Int(firstResult.confidence*100))% ,\n\n \((firstResult.identifier))"
                let utterwords = AVSpeechUtterance(string:(self?.photoInfoDispay.text)!)
                utterwords.voice = AVSpeechSynthesisVoice(language: "en-us")
                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterwords)
                
            }
    }
        guard let ciImage = CIImage(image: image)else{
            fatalError("画像を変換できません")
        }
        let imageHandler = VNImageRequestHandler(ciImage : ciImage)
        
        DispatchQueue.global(qos: .userInteractive).async {
            do{
            try imageHandler.perform([request])
        }catch{
            print("エラー\(error)")
        }
}
}
}
