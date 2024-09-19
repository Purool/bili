//
//  BFCCommentListCell.swift
//  bili
//
//  Created by DJ on 2024/9/19.
//

import UIKit
import Kingfisher

class BFCCommentListCell: UITableViewCell {
    //row1
    lazy var avatarView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: "common_profile_default")
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .hexColor(str: "61666d")
        return label
    }()
    
    lazy var levelTagImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "misc_level_whiteLv2")
        return imageView
    }()
    
    var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .hexColor(str: "9499a0")
        return label
    }()
    //row2
    var centerSection: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 6
        label.textColor = .black
        return label
    }()
    //row3
    lazy var likeActionBtn: UIButton = {
        let button = HLImagePositionButton(type: .right, space: 4)
        button.setTitle("xxx", for: .normal)//(up+1)
        button.setTitleColor(.hexColor(str: "9499a0"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        button.tintColor = .hexColor(str: "9499a0")
        return button
    }()
    
    lazy var replyActionBtn: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "message.badge.waveform")
        imageView.tintColor = .hexColor(str: "9499a0")
        return imageView
    }()
    //row4
    var subCommentsView: UIView?
//    var subCommentsLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 10)
//        label.textColor = .hexColor(str: "9499a0")
//        return label
//    }()
//    
//    var subReplyLabel: UILabel = {
//        let label = UILabel()
//        label.font = UIFont.systemFont(ofSize: 10)
//        label.textColor = .hexColor(str: "9499a0")
//        return label
//    }()
    var videoModel: Replys.Reply? {
        didSet{
            guard let model = videoModel else { return }
            avatarView.kf.setImage(with: URL(string:model.member.avatar), options: [.processor(DownsamplingImageProcessor(size: CGSize(width: 30, height: 30))), .forceRefresh, .cacheOriginalImage])
            nameLabel.text = model.member.uname
            timeLabel.text = DateFormatter.stringFor(timestamp: model.ctime)
            levelTagImageView.image = UIImage(named: "misc_level_whiteLv\(model.member.level_info.current_level)")
            centerSection.text = model.content.message
            likeActionBtn.setTitle(model.like == 0 ? String(model.like) : "", for: .normal)
//            coverLeftIcon1.image = UIImage(systemName: "play.rectangle")
//            coverLeftIcon2.image = UIImage(systemName: "list.dash.header.rectangle")
//            descButton.setImage(UIImage(systemName: "person.circle"), for: .normal)
//            moreHandleButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        }
    }
    
    override init(style:  UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(avatarView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(levelTagImageView)
        contentView.addSubview(timeLabel)
        contentView.addSubview(centerSection)
        contentView.addSubview(likeActionBtn)
        contentView.addSubview(replyActionBtn)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func setupUI() {
        avatarView.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(12)
            make.width.height.equalTo(30)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarView)
            make.left.equalTo(avatarView.snp.right).offset(12)
        }
        
        levelTagImageView.snp.makeConstraints { make in
            make.top.equalTo(avatarView)
            make.left.equalTo(nameLabel.snp.right).offset(6)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarView)
            make.left.equalTo(levelTagImageView.snp.right).offset(12)
        }
        
        centerSection.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
            make.left.equalTo(nameLabel)
            make.right.equalToSuperview().offset(-12)
        }
        
        likeActionBtn.snp.makeConstraints { make in
            make.top.equalTo(centerSection.snp.bottom).offset(10)
            make.left.equalTo(nameLabel)
        }
        
        replyActionBtn.snp.makeConstraints { make in
            make.top.equalTo(centerSection.snp.bottom).offset(10)
            make.right.equalTo(centerSection)
            make.width.height.equalTo(20)
            make.bottom.equalToSuperview()
        }
    }
}

