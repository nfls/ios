//
//  PaperView.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/10/1.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import SDWebImage
import AVFoundation

class ProblemCell: UITableViewCell {

    @IBOutlet weak var question: ScaledHeightImageView!
    var problem: Problem? = nil
    var problems: [Problem] = []
    var current: [URL] = []
    var constraint: NSLayoutConstraint? = nil
    var images: [UIImage?] = []
    
    func setProblem(_ problem: Problem) {
        self.problem = problem
        self.getImageUrls()
    }
    
    func getMasterProblem(_ problem: Problem?) {
        if let problem = problem {
            current.insert(problem.contentImageUrl, at: 0)
            self.getMasterProblem(problem.masterProblem)
        }
    }
    
    func getSubProblem(_ problems: [Problem]) {
        if problems.count > 0 {
            let problem = problems[0]
            current.append(problem.contentImageUrl)
            self.getSubProblem(problem.subProblems)
        }
    }
    /*
    func setImageView(url: URL?) {
        if let url = url {
            let imageView = UIImageView()
            imageView.sd_setImage(with: url) { (_, _, _, _) in
                //self.constrain()
            }
            imageView.contentMode = .scaleAspectFit
            self.stackView.addArrangedSubview(imageView)

            
        }
    }
    
    func constrain() {
        for imageView in self.stackView.arrangedSubviews {
            var height: CGFloat = 0
            var width: CGFloat = 0
            if let imageView = imageView as? UIImageView {
                if let constraint = self.constraint {
                    self.stackView.removeConstraint(constraint)
                    self.constraint = nil
                }
                if let image = imageView.image {
                    height += image.size.height
                    width = image.size.width
                }
            }
            if width > 0 && height > 0 {
                self.constraint = NSLayoutConstraint(item: self.stackView, attribute: .height, relatedBy: .equal, toItem: self.stackView, attribute: .width, multiplier: height/width, constant: 0)
                self.stackView.addConstraint(self.constraint!)
            }
            
        }
        
    }
    */
    func getImageUrls() {
        self.getMasterProblem(self.problem)
        self.getSubProblem(self.problem?.subProblems ?? [])
        while (self.current.count > self.images.count) {
            self.images.append(nil)
        }
        for (key, url) in self.current.enumerated() {
            SDWebImageManager.shared().loadImage(with: url, options: .highPriority, progress: nil) { (image, _, _, _, _, _) in
                self.images[key] = image
                self.load()
            }
        }
    }
    
    func load() {
        var images: [UIImage] = []
        for image in self.images {
            if let image = image {
                images.append(image)
            } else {
                return
            }
        }
        DispatchQueue.main.async {
            let image = self.stitchImages(images: images, isVertical: true)
            //print(image.size.height)
            self.question.image = image
        }
    }
    
    func stitchImages(images: [UIImage], isVertical: Bool) -> UIImage {
        var stitchedImages : UIImage!
        if images.count > 0 {
            var maxWidth = CGFloat(0), maxHeight = CGFloat(0)
            for image in images {
                if image.size.width > maxWidth {
                    maxWidth = image.size.width
                }
                if image.size.height > maxHeight {
                    maxHeight = image.size.height
                }
            }
            var totalSize : CGSize
            let maxSize = CGSize(width: maxWidth, height: maxHeight)
            if isVertical {
                totalSize = CGSize(width: maxSize.width, height: maxSize.height * (CGFloat)(images.count))
            } else {
                totalSize = CGSize(width: maxSize.width  * (CGFloat)(images.count), height:  maxSize.height)
            }
            UIGraphicsBeginImageContext(totalSize)
            for image in images {
                let offset = (CGFloat)(images.index(of: image)!)
                let rect =  AVMakeRect(aspectRatio: image.size, insideRect: isVertical ?
                    CGRect(x: 0, y: maxSize.height * offset, width: maxSize.width, height: maxSize.height) :
                    CGRect(x: maxSize.width * offset, y: 0, width: maxSize.width, height: maxSize.height))
                image.draw(in: rect)
            }
            stitchedImages = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return stitchedImages
    }
    
}
class ScaledHeightImageView: UIImageView {
    
    override var intrinsicContentSize: CGSize {
        if let myImage = self.image {
            let myImageWidth = myImage.size.width
            let myImageHeight = myImage.size.height
            let myViewWidth = self.frame.size.width
            
            let ratio = myViewWidth/myImageWidth
            let scaledHeight = myImageHeight * ratio
            
            return CGSize(width: myViewWidth, height: scaledHeight)
        }
        return CGSize(width: -1.0, height: -1.0)
    }
}
extension UIView
{
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}
