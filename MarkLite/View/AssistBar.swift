//
//  AssistBar.swift
//  MarkLite
//
//  Created by zhubch on 2017/7/11.
//  Copyright © 2017年 zhubch. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift

protocol ButtonConvertiable {
    func makeButton() -> UIButton
}

extension UIImage: ButtonConvertiable {
    func makeButton() -> UIButton {
        let button = UIButton(type: UIButtonType.system)
        button.setImage(self, for: .normal)
        button.contentEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15)
        return button
    }
}

extension String: ButtonConvertiable {
    func makeButton() -> UIButton {
        let button = UIButton(type: UIButtonType.system)
        button.setTitle(self, for: .normal)
        button.titleLabel?.font = UIFont.font(ofSize: 16, bold: true)
        return button
    }
}

fileprivate let uploadURL = ""
class AssistBar: UIView {
    let scrollView = UIScrollView()
    var endButton: UIButton!
    
    let items: [(ButtonConvertiable,Selector)] = [
        (#imageLiteral(resourceName: "bar_image"), #selector(tapImage(_:))),
        (#imageLiteral(resourceName: "bar_link"), #selector(tapLink)),
        (#imageLiteral(resourceName: "bar_header"), #selector(tapHeader)),
        (#imageLiteral(resourceName: "bar_bold"), #selector(tapBold)),
        (#imageLiteral(resourceName: "bar_italic"), #selector(tapItalic)),
        (#imageLiteral(resourceName: "bar_deleteLine"), #selector(tapDeletion)),
        (#imageLiteral(resourceName: "bar_quote"), #selector(tapQuote)),
        (#imageLiteral(resourceName: "bar_code"), #selector(tapCode)),
        ("@", #selector(tapChar(_:))),
        ("\"", #selector(tapChar(_:))),
        ("`", #selector(tapChar(_:))),
        ("(", #selector(tapChar(_:))),
        (")", #selector(tapChar(_:))),
        ("[", #selector(tapChar(_:))),
        ("]", #selector(tapChar(_:))),
        ("|", #selector(tapChar(_:))),
        ("#", #selector(tapChar(_:))),
        ("*", #selector(tapChar(_:))),
        ("=", #selector(tapChar(_:))),
        ("+", #selector(tapChar(_:))),
        ("-", #selector(tapChar(_:))),
        ("/", #selector(tapChar(_:))),
        ("?", #selector(tapChar(_:))),
        ("<", #selector(tapChar(_:))),
        (">", #selector(tapChar(_:))),
        ]
    
    weak var textView: UITextView?
    weak var viewController: UIViewController?
    
    let disposeBag = DisposeBag()
    var imagePicker: ImagePicker?
    var textField: UITextField?
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, w: windowWidth, h: 50))

        self.backgroundColor = rgb("f2f2f2")
        
        items.forEachEnumerated { (index, item) in
            let button = item.0.makeButton()
            button.addTarget(self, action: item.1, for: .touchUpInside)
            button.tintColor = .gray
            button.tag = index
            button.frame = CGRect(x: CGFloat(index * 50), y: 0, w: 50, h: 50)
            self.scrollView.addSubview(button)
        }
        scrollView.contentSize = CGSize(width: items.count * 50, height: 50)
        addSubview(scrollView)
        
        endButton = #imageLiteral(resourceName: "bar_keyboard").makeButton()
        endButton.tintColor = .gray
        endButton.addTarget(self, action: #selector(hideKeyboard), for: .touchUpInside)
        addSubview(endButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = CGRect(x: 0, y: 0, w: w - 50, h: 50)
        endButton.frame = CGRect(x: w - 50, y: 0, w: 50, h: 50)
    }
    
    func hideKeyboard() {
        textView?.resignFirstResponder()
    }
    
    func tapChar(_ sender: UIButton) {
        let char = sender.currentTitle ?? ""
        textView?.insertText(char)
    }

    func tapImage(_ sender: UIButton) {
        guard let vc = viewController else { return }
        imagePicker = ImagePicker(viewController: vc, completionHanlder: { (image) in
            self.didPickImage(image)
        })
        imagePicker?.pickImage(sender)
    }
    
    func tapLink() {
        guard let vc = viewController else { return }
        vc.showAlert(title: /"InsertHref", message: "", actionTitles: [/"Cancel",/"OK"], textFieldconfigurationHandler: { (textField) in
            textField.text = "http://example.com"
            textField.font = UIFont.font(ofSize: 13)
            textField.setTextColor(.primary)
            self.textField = textField
        }) { (index) in
            if index == 1 {
                self.insertLink()
            }
        }
    }
    
    func insertLink() {
        guard let textView = self.textView else { return }
        let link = textField?.text ?? ""
        let currentRange = textView.selectedRange
        let insertText = /"EnterLink"
        textView.insertText("[\(insertText)](\(link))")
        textView.selectedRange = NSMakeRange(currentRange.location + 1, insertText.length)
    }
    
    func tapCode() {
        guard let textView = self.textView else { return }

        let currentRange = textView.selectedRange
        let text = textView.text.substring(with: currentRange)
        let isEmpty = text.length == 0
        let insertText = isEmpty ? /"EnterCode": text
        textView.insertText("`\(insertText)`")
        if isEmpty {
            textView.selectedRange = NSMakeRange(currentRange.location + 1, insertText.length)
        }
    }
    func tapHeader(_ sender: UIButton) {
        guard let textView = self.textView else { return }

        let pos = sender.convert(sender.center, to: sender.window)
        MenuView(items: [/"Header1",/"Header2",/"Header3",/"Header4"],
                 postion: CGPoint(x: pos.x - 100, y: pos.y - 190)) { (index) in
                    let currentRange = textView.selectedRange
                    let insertText = ("#" * (index+1)) + " " + /"Header"
                    textView.insertText("\n\(insertText)\n")
                    textView.selectedRange = NSMakeRange(currentRange.location + index + 3, (/"Header").length)
        }.show()
    }
    func tapDeletion() {
        guard let textView = self.textView else { return }

        let currentRange = textView.selectedRange
        let text = textView.text.substring(with: currentRange)
        let isEmpty = text.length == 0
        let insertText = isEmpty ? /"Delection": text
        textView.insertText("~~\(insertText)~~")
        if isEmpty {
            textView.selectedRange = NSMakeRange(currentRange.location + 2, insertText.length)
        }
    }
    
    func tapQuote() {
        guard let textView = self.textView else { return }

        let currentRange = textView.selectedRange
        let insertText = /"Blockquote"
        textView.insertText("\n> \(insertText)\n")
        textView.selectedRange = NSMakeRange(currentRange.location + 3, insertText.length)
    }
    
    func tapBold() {
        guard let textView = self.textView else { return }

        let currentRange = textView.selectedRange
        let text = textView.text.substring(with: currentRange)
        let isEmpty = text.length == 0
        let insertText = isEmpty ? /"StrongText": text
        textView.insertText("**\(insertText)**")
        if isEmpty {
            textView.selectedRange = NSMakeRange(currentRange.location + 2, insertText.length)
        }
    }
    func tapItalic() {
        guard let textView = self.textView else { return }

        let currentRange = textView.selectedRange
        let text = textView.text.substring(with: currentRange)
        let isEmpty = text.length == 0
        let insertText = isEmpty ? /"EmphasizedText": text
        textView.insertText("*\(insertText)*")
        if isEmpty {
            textView.selectedRange = NSMakeRange(currentRange.location + 1, insertText.length)
        }
    }
    
    func didPickImage(_ image: UIImage) {
        imagePicker = nil
        guard let textView = self.textView, var data = UIImageJPEGRepresentation(image, 0.9) else { return }
        if data.count > 3000000 {
            if let newData = UIImageJPEGRepresentation(image, 0.7) {
                data = newData
            }
        }
        viewController?.view.startLoadingAnimation()
        upload(multipartFormData: { (formData) in
            formData.append(data, withName: "smfile", fileName: "temp", mimeType: "image/jpg")
        }, to: imageUploadUrl) { (result) in
            switch result {
            case .success(let upload,_, _):
                upload.responseJSON(completionHandler: { (response) in
                    if case .success(let json) = response.result {
                        if let dict = json as? [String:Any],
                            let data = dict["data"] as? [String:Any],
                            let url = data["url"] as? String {
                            
                            let currentRange = textView.selectedRange
                            
                            let insertText = /"EnterPlaceholder"
                            textView.insertText("![\(insertText)](\(url))")
                            textView.selectedRange = NSMakeRange(currentRange.location + 2, insertText.length)
                            self.viewController?.view.stopLoadingAnimation()
                        }
                    } else if case .failure(let error) = response.result {
                        print(error.localizedDescription)
                        self.viewController?.view.stopLoadingAnimation()
                    }
                })
            case .failure(let error):
                print(error.localizedDescription)
                self.viewController?.view.stopLoadingAnimation()
            }
        }
    }
}
