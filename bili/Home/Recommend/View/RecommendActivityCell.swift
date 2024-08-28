//
//  RecommendActivityCell.swift
//  U17
//
//  Created by lyw on 2020/5/14.
//  Copyright © 2020 胡智钦. All rights reserved.
//

import UIKit
import Kingfisher

class RecommendActivityCell: UICollectionViewCell {
    
    //coverBottomView
        //coverLeftIcon1,coverLeftLabel1  coverLeftIcon2,coverLeftLabel2  coverRightLabel
    //titleLabel
    //bottomTagView
        //descButton  moreHandleButton
    
    private lazy var coverBgImgView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "default_img")
        return imageView
    }()
    
    private lazy var coverLeftIcon1: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
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
        imageView.tintColor = .white
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
        button.tintColor = .hexColor(str: "9499a0")
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.setTitleColor(.hexColor(str: "9499a0"), for: .normal)
        button.contentHorizontalAlignment = .left
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        return button
    }()
    private lazy var moreHandleButton: UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = .hexColor(str: "9499a0")
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.setTitleColor(.hexColor(str: "9499a0"), for: .normal)
        return button
    }()
    
    let coverBottomView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth*0.46, height: 26))
    
    var videoModel: Any? {
        didSet{
            if let model = videoModel as? RecVideoItemModel {
//                coverBgImgView.kf.setImage(with: URL(string:model.pic))
                var coverText = model.stat?.view
                coverLeftLabel1.text = QUtils.numFormat(coverText)
                coverText = model.stat?.danmaku
                coverLeftLabel2.text = QUtils.numFormat(coverText)
                coverRightLabel.text = QUtils.timeFormat(model.duration)
                titleLabel.text = model.title
                descButton.setTitle(model.owner?.name ?? "-", for: .normal)
            } else if let model = videoModel as? RecVideoItemAppModel{
//                coverBgImgView.kf.setImage(with: URL(string:model.cover))
                var coverText = model.cover_left_text_2
                coverText.removeLast(2)
                coverLeftLabel1.text = coverText
                coverText = model.cover_left_text_3
                coverText.removeLast(2)
                coverLeftLabel2.text = coverText
                coverRightLabel.text = QUtils.timeFormat(model.player_args?.duration ?? "")
                titleLabel.text = model.title
                descButton.setTitle(model.args?.up_name ?? "-", for: .normal)
            }
            coverLeftIcon1.image = UIImage(systemName: "play.rectangle")
            coverLeftIcon2.image = UIImage(systemName: "list.dash.header.rectangle")
            descButton.setImage(UIImage(systemName: "person.circle"), for: .normal)
            moreHandleButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
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
        contentView.insertSubview(coverBottomView, aboveSubview: coverBgImgView)
        coverBottomView.setupGradientShadow()
        
        self.layer.cornerRadius = 6
        self.layer.masksToBounds = true
        self.backgroundColor = .white
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func setupUI() {
        coverBgImgView.snp.makeConstraints { make in
//            make.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            make.left.right.top.equalToSuperview()
            make.height.equalTo(kScreenWidth*0.29)
        }
        
        coverBottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(coverBgImgView)
            make.height.equalTo(26)
        }
        
        coverLeftIcon1.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.centerY.equalTo(coverBottomView)
            make.width.height.equalTo(18)
        }
        
        coverLeftLabel1.snp.makeConstraints { make in
            make.left.equalTo(coverLeftIcon1.snp.right).offset(3)
            make.centerY.equalTo(coverBottomView)
            make.height.equalTo(coverLeftIcon1)
        }
        
        coverLeftIcon2.snp.makeConstraints { make in
            make.left.equalTo(coverLeftLabel1.snp.right).offset(12)
            make.centerY.equalTo(coverBottomView)
            make.width.height.equalTo(coverLeftIcon1)
        }
        
        coverLeftLabel2.snp.makeConstraints { make in
            make.left.equalTo(coverLeftIcon2.snp.right).offset(3)
            make.centerY.equalTo(coverBottomView)
            make.height.equalTo(coverLeftIcon1)
        }
        
        coverRightLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-8)
            make.centerY.equalTo(coverBottomView)
            make.height.equalTo(coverLeftIcon1)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(coverBgImgView.snp.bottom).offset(8)
            make.left.equalTo(coverBgImgView).offset(8)
            make.right.equalTo(coverBgImgView).offset(-8)
//            make.height.equalTo(32)
        }
        
        descButton.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-30)
            make.height.equalTo(30)
        }
        
        moreHandleButton.snp.makeConstraints { make in
            make.top.bottom.equalTo(descButton)
            make.left.equalTo(descButton.snp.right)
            make.width.height.equalTo(30)
        }
        
        //cell_height = kScreenWidth*0.29+32+30
    }
    
}

