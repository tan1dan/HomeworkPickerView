//
//  ViewController.swift
//  HomeworkPickerView
//
//  Created by Иван Знак on 16/12/2023.
//

import UIKit
import PhotosUI

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, PHPickerViewControllerDelegate {
   
    let imageView = UIImageView()
    let pickerView = UIPickerView()
    let button = UIButton(type: .system)
    var dataOfImages: [UIImage] = []
    lazy var phPicker: PHPickerViewController = {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.selectionLimit = 10
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        return picker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageViewParameters()
        pickerViewParameters()
        buttonParameters()
    }
    
    private func imageViewParameters(){
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            imageView.heightAnchor.constraint(equalToConstant: 200)
        ])
        imageView.image = UIImage(named: "log")
        imageView.contentMode = .scaleToFill
    }
    
    private func pickerViewParameters(){
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.layer.opacity = 0
        view.addSubview(pickerView)
        NSLayoutConstraint.activate([
            pickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            pickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            pickerView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 50),
            pickerView.heightAnchor.constraint(equalToConstant: 200)
        ])
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    private func buttonParameters(){
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Выбрать картинку", for: .normal)
        button.tintColor = .white
        view.addSubview(button)
        let titleLabel = button.titleLabel ?? UILabel()
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 50),
            button.heightAnchor.constraint(equalToConstant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -10)
        ])
        button.layer.cornerRadius = 10
        button.backgroundColor = .systemBlue
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc func buttonTapped(){
        present(phPicker, animated: true)
        dataOfImages = []
    }
    
    //MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        pickerView.frame.height
    }
    //MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        dataOfImages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: pickerView.frame.width, height: pickerView.frame.height))
        if dataOfImages.count != 0 {
            imageView.image = dataOfImages[row]
        }
        imageView.contentMode = .scaleToFill
        return imageView
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if dataOfImages.count != 0 {
            imageView.image = dataOfImages[row]
        }
        dataOfImages = []
        pickerView.layer.opacity = 0
        pickerView.reloadAllComponents()
    }
    //MARK: - PHPickerViewControllerDelegate
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        if results.count >= 2 {
            let itemProviders = results.map { $0.itemProvider }
            let lock = NSRecursiveLock()
            DispatchQueue.main.async{
                self.pickerView.layer.opacity = 1
            }
            for item in itemProviders {
                item.loadObject(ofClass: UIImage.self) { image, error in
                    let image = image as? UIImage
                    
                    DispatchQueue.main.async{
                        lock.lock()
                        self.dataOfImages.append(image ?? UIImage())
                        self.pickerView.reloadAllComponents()
                        
                        defer{ lock.unlock() }
                        print("Image added")
                    }
                    
                }
            }
            picker.dismiss(animated: true)
        }
        else if (results.count < 2) && (results.count > 0) {
            picker.showAlert("Ошибка", description: "Выберите минимум 2 картинки, чтобы продолжить", completion: nil)
        }
        else if results.count == 0 {
            picker.dismiss(animated: true)
        }
    }
    
}

