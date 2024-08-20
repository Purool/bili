//
//  RecommendActivityCell.swift
//  U17
//
//  Created by lyw on 2020/5/14.
//  Copyright © 2020 胡智钦. All rights reserved.
//

import UIKit


class RecommendActivityCell: UICollectionViewCell {
    
    //coverBottomView
        //coverLeftIcon1,coverLeftLabel1  coverLeftIcon2,coverLeftLabel2  coverRightLabel
    //titleLabel
    //bottomTagView
        //descButton  moreHandleButton
    
    private lazy var coverBgImgView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var coverLeftIcon1: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()
    private lazy var coverLeftLabel1: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .white
        return label
    }()
    
    private lazy var coverLeftIcon2: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()
    private lazy var coverLeftLabel2: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .white
        return label
    }()
    
    private lazy var coverRightLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .white
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .hexColor(str: "18191c")
        return label
    }()
    
    private lazy var descButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.backgroundColor = .hexColor(str: "9499a0")
        return button
    }()
    private lazy var moreHandleButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.backgroundColor = .hexColor(str: "9499a0")
        return button
    }()
    
    var videoModel: Any? {
        didSet{
            if let model = videoModel as? RecVideoItemModel {
                model
            } else {
                if let model = videoModel as? RecVideoItemAppModel{
                    model
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(coverBgImgView)
        contentView.addSubview(coverLeftIcon1)
        contentView.addSubview(coverLeftLabel1)
        contentView.addSubview(coverLeftIcon2)
        contentView.addSubview(coverLeftLabel2)
        contentView.addSubview(coverRightLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descButton)
        contentView.addSubview(moreHandleButton)
        
        self.backgroundColor = kHomeBackColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupUI()
    }
    
    private func setupUI() {
        coverBgImgView.snp.makeConstraints { make in
//            make.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            make.left.right.top.equalToSuperview()
        }
        
    }
    
}

