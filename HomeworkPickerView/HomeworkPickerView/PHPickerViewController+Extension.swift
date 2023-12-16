//
//  UIViewController+Extension.swift
//  HomeworkPickerView
//
//  Created by Иван Знак on 17/12/2023.
//

import PhotosUI

extension PHPickerViewController {
    func showAlert(_ title: String, description: String, completion: ((Bool) -> Void)?) {
        let controller = UIAlertController(title: title, message: description, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            completion?(true)
        }))
        self.present(controller, animated: true)
    }
}
