//
//  PaperView.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/10/1.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation
import SDWebImage

class PaperView: UIView {
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet var contentView: UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    func commonInit() {
        Bundle.main.loadNibNamed("PaperView", owner: self, options: nil)
        self.contentView.fixInView(self)
    }
    
    var problem: Problem? = nil
    var problems: [Problem] = []
    var current: [URL] = []
    
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
    
    func setImageView(url: URL?) {
        if let url = url {
            let imageView = UIImageView()
            imageView.sd_setImage(with: url, completed: nil)
            imageView.contentMode = .scaleAspectFit
            self.stackView.addArrangedSubview(imageView)
        }
    }
    
    func getImageUrls() {
        self.getMasterProblem(self.problem)
        self.getSubProblem(self.problem?.subProblems ?? [])
        for url in self.current {
            self.setImageView(url: url)
        }
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
