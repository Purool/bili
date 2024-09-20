//
//  VDSectionControllerCell.swift
//  bili
//
//  Created by DJ on 2024/9/13.
//

import UIKit

class VDSectionControllerCell: UITableViewCell {
    
    var expanded: Bool = false {
        didSet{
            if expanded {
                titleLabel.numberOfLines = 0
                descLabel.isHidden = false
                expandBtn.setImage(UIImage(systemName: "chevron.down"), for: .normal)
                coverLeftIcon3.snp.remakeConstraints { make in
                    make.top.equalTo(playLabel.snp.bottom).offset(2)
                    make.width.height.equalTo(playLabel.snp.height)
                    make.left.equalTo(titleLabel)
                }
            }else {
                titleLabel.numberOfLines = 1
                descLabel.isHidden = true
                expandBtn.setImage(UIImage(systemName: "chevron.up"), for: .normal)
                coverLeftIcon3.snp.remakeConstraints { make in
                    make.top.equalTo(playLabel.snp.bottom).offset(2)
                    make.width.height.equalTo(playLabel.snp.height)
                    make.left.equalTo(titleLabel)
                    make.bottom.equalToSuperview().offset(-12)
                }
            }
        }
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.textColor = .black
        return label
    }()
    
    lazy var expandBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.tintColor = .hexColor(str: "9499a0")
        return button
    }()
    
    lazy var coverLeftIcon1: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "play.rectangle")
        imageView.tintColor = .hexColor(str: "9499a0")
        imageView.contentMode = .center
        return imageView
    }()
    lazy var playLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .hexColor(str: "9499a0")
        return label
    }()
    
    lazy var coverLeftIcon2: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "list.dash.header.rectangle")
        imageView.tintColor = .hexColor(str: "9499a0")
        imageView.contentMode = .center
        return imageView
    }()
    lazy var danmakuLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .hexColor(str: "9499a0")
        return label
    }()
    
    var pubDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.textColor = .hexColor(str: "9499a0")
        return label
    }()
    
    lazy var coverLeftIcon3: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.and.background.dotted")
        imageView.tintColor = .hexColor(str: "9499a0")
        imageView.contentMode = .center
        return imageView
    }()
    lazy var onlineLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .hexColor(str: "9499a0")
        return label
    }()
    
    lazy var idLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.textColor = .hexColor(str: "9499a0")
        return label
    }()
    
    lazy var descLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.textColor = .hexColor(str: "9499a0")
        return label
    }()
    
    override init(style:  UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(titleLabel)
        contentView.addSubview(expandBtn)
        contentView.addSubview(coverLeftIcon1)
        contentView.addSubview(playLabel)
        contentView.addSubview(coverLeftIcon2)
        contentView.addSubview(danmakuLabel)
        contentView.addSubview(pubDateLabel)
        contentView.addSubview(coverLeftIcon3)
        contentView.addSubview(onlineLabel)
        contentView.addSubview(idLabel)
        contentView.addSubview(descLabel)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func setupUI() {
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(6)
        }
        
        expandBtn.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right).offset(6)
            make.right.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(9)
            make.height.width.equalTo(16)
        }
        
        coverLeftIcon1.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.width.height.equalTo(playLabel.snp.height)
            make.left.equalTo(titleLabel)
        }
        
        playLabel.snp.makeConstraints { make in
            make.centerY.equalTo(coverLeftIcon1)
            make.left.equalTo(coverLeftIcon1.snp.right)
        }
        
        coverLeftIcon2.snp.makeConstraints { make in
            make.centerY.equalTo(coverLeftIcon1)
            make.left.equalTo(playLabel.snp.right).offset(6)
            make.width.height.equalTo(coverLeftIcon1)
        }
        
        danmakuLabel.snp.makeConstraints { make in
            make.centerY.equalTo(coverLeftIcon1)
            make.left.equalTo(coverLeftIcon2.snp.right)
        }
        
        pubDateLabel.snp.makeConstraints { make in
            make.centerY.equalTo(coverLeftIcon1)
            make.left.equalTo(danmakuLabel.snp.right).offset(6)
        }
        
        expanded = false
        
        onlineLabel.snp.makeConstraints { make in
            make.centerY.equalTo(coverLeftIcon3)
            make.left.equalTo(coverLeftIcon3.snp.right)
        }
        
        idLabel.snp.makeConstraints { make in
            make.left.equalTo(onlineLabel.snp.right).offset(6)
            make.top.equalTo(onlineLabel)
        }
        
        descLabel.snp.makeConstraints { make in
            make.top.equalTo(coverLeftIcon3.snp.bottom).offset(2)
            make.left.equalTo(titleLabel)
            make.right.equalTo(expandBtn)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
    
}

