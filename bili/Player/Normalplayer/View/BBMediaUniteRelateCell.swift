//
//  BBMediaUniteRelateCell.swift
//  bili
//
//  Created by DJ on 2024/9/14.
//

import UIKit

class BBMediaUniteRelateCell: UITableViewCell {
    var expanded = false
    
    lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 3
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "default_img")
        return imageView
    }()
    
    lazy var topLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 2
        label.textColor = .hexColor(str: "18191c")
        return label
    }()
    
    lazy var middleLabel: UIButton = {
        let button = HLImagePositionButton(type: .right, space: 4)
        button.setTitle("xxx", for: .normal)
        button.setTitleColor(.hexColor(str: "9499a0"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setImage(UIImage(systemName: "person.circle"), for: .normal)
        button.tintColor = .hexColor(str: "9499a0")
        return button
    }()
    
    lazy var bottomLabel1: UIButton = {
        let button = HLImagePositionButton(type: .right, space: 4)
        button.setTitle("xxx", for: .normal)
        button.setTitleColor(.hexColor(str: "9499a0"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setImage(UIImage(systemName: "play.rectangle"), for: .normal)
        button.tintColor = .hexColor(str: "9499a0")
        return button
    }()
    lazy var bottomLabel2: UIButton = {
        let button = HLImagePositionButton(type: .right, space: 4)
        button.setTitle("xxx", for: .normal)
        button.setTitleColor(.hexColor(str: "9499a0"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setImage(UIImage(systemName: "list.dash.header.rectangle"), for: .normal)
        button.tintColor = .hexColor(str: "9499a0")
        return button
    }()
    
    override init(style:  UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(coverImageView)
        contentView.addSubview(topLabel)
        contentView.addSubview(middleLabel)
        contentView.addSubview(bottomLabel1)
        contentView.addSubview(bottomLabel2)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func update(data: VideoDetail.Info) {
        topLabel.text = data.title
        coverImageView.kf.setImage(with: data.pic)
        middleLabel.setTitle(data.ownerName, for: .normal)
        bottomLabel1.setTitle(QUtils.numFormat(data.stat.view), for: .normal)
        bottomLabel2.setTitle(QUtils.numFormat(data.stat.danmaku), for: .normal)
    }
    
    private func setupUI() {
        coverImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(72)
            make.width.equalTo(coverImageView.snp.height).multipliedBy(16.0/9.0)
        }
        
        topLabel.snp.makeConstraints { make in
            make.left.equalTo(coverImageView.snp.right).offset(6)
            make.top.equalTo(coverImageView)
            make.right.equalToSuperview().offset(-12)
        }
        
        bottomLabel1.snp.makeConstraints { make in
            make.bottom.equalTo(coverImageView)
            make.left.equalTo(topLabel)
        }
        
        bottomLabel2.snp.makeConstraints { make in
            make.centerY.equalTo(bottomLabel1)
            make.left.equalTo(bottomLabel1.snp.right).offset(10)
        }
        
        middleLabel.snp.makeConstraints { make in
            make.left.equalTo(topLabel)
            make.bottom.equalTo(bottomLabel1.snp.top).offset(-1)
        }
    }
}
