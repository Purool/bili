//
//  BBMediaDescUniteFeatureCell.swift
//  bili
//
//  Created by DJ on 2024/9/14.
//

import UIKit

class BBMediaDescUniteFeatureCell: UITableViewCell {
    
    var btnInfo = ["hand.thumbsup.fill", "hand.thumbsdown.fill", "bitcoinsign.circle.fill", "star.fill", "arrowshape.turn.up.forward.fill"]
    var subView: UIStackView!
    
    override init(style:  UITableViewCell.CellStyle, reuseIdentifier: String?) {
        subView = UIStackView(frame: CGRectMake(12, 0, kScreenWidth - 24, 40))
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        subView.alignment = .center
        subView.distribution = .fillEqually
        contentView.addSubview(subView)
        btnInfo.forEach { subView.addArrangedSubview(getBtn(imageName: $0)) }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func getBtn(imageName: String) -> UIButton {
        let button = HLImagePositionButton(type: .top, space: 4)
        button.setTitle("xxx", for: .normal)
        button.setTitleColor(.hexColor(str: "9499a0"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setImage(UIImage(systemName: imageName), for: .normal)
        button.tintColor = .hexColor(str: "9499a0")
        return button
    }
    
    func setBtnTitle(_ title: String, index: Int){
        (subView.arrangedSubviews[index] as! UIButton).setTitle(title, for: .normal)
    }
    
}
