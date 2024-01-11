//
//  TestResultTicketView.swift
//  Going-iOS
//
//  Created by 곽성준 on 1/5/24.
//

import UIKit

import SnapKit

final class TestResultTicketView: UIView {
    
    var firstString: String = "" {
        didSet {
            let imageAttachment = NSTextAttachment(image: ImageLiterals.TestResult.dotImage)
            imageAttachment.bounds = .init(x: 0, y: ScreenUtils.getHeight(2), width: ScreenUtils.getWidth(4), height: ScreenUtils.getHeight(4))
            firstDescLabel.labelWithImg(composition: NSAttributedString(attachment: imageAttachment), NSAttributedString(string: firstString))
        }
    }
    
    var secondString: String = "" {
        didSet {
            let imageAttachment = NSTextAttachment(image: ImageLiterals.TestResult.dotImage)
            imageAttachment.bounds = .init(x: 0, y: ScreenUtils.getHeight(2), width: ScreenUtils.getWidth(4), height: ScreenUtils.getHeight(4))
            secondDescLabel.labelWithImg(composition: NSAttributedString(attachment: NSTextAttachment(image: ImageLiterals.TestResult.dotImage)), NSAttributedString(string: secondString))
        }
    }
    var thirdString: String = "" {
        didSet {
            let imageAttachment = NSTextAttachment(image: ImageLiterals.TestResult.dotImage)
            imageAttachment.bounds = .init(x: 0, y: ScreenUtils.getHeight(2), width: ScreenUtils.getWidth(4), height: ScreenUtils.getHeight(4))
            thirdDescLabel.labelWithImg(composition: NSAttributedString(attachment: NSTextAttachment(image: ImageLiterals.TestResult.dotImage)), NSAttributedString(string: thirdString))
        }
    }
    
    
    private let wholeStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .center
        return stack
    }()
    
    let titleLabel = DOOLabel(font: .pretendard(.detail2_bold), color: .gray700, numberOfLine: 2, alignment: .center)
    
    private let vertiLineImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = ImageLiterals.TestResult.verticalLine
        return imageView
    }()
    
    private let descStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.backgroundColor = .clear
        stack.distribution = .equalSpacing
        return stack
    }()
    
    lazy var firstDescLabel = DOOLabel(font: .pretendard(.detail3_regular), color: .gray700, numberOfLine: 2)
    lazy var secondDescLabel = DOOLabel(font: .pretendard(.detail3_regular), color: .gray700, numberOfLine: 2)
    lazy var thirdDescLabel = DOOLabel(font: .pretendard(.detail3_regular), color: .gray700, numberOfLine: 2)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setHierarchy()
        setLayout()
        setStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension TestResultTicketView {
    
    func setHierarchy() {
        self.addSubviews(wholeStackView)
        wholeStackView.addArrangedSubviews(titleLabel, vertiLineImageView, descStackView)
        descStackView.addArrangedSubviews(firstDescLabel, secondDescLabel, thirdDescLabel)
    }
    
    func setLayout() {
        wholeStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(14)
            $0.top.bottom.equalToSuperview().inset(16)
            $0.height.equalTo(ScreenUtils.getHeight(110))
        }
        
        vertiLineImageView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(1)
        }
        
        titleLabel.snp.makeConstraints {
            $0.width.equalTo(ScreenUtils.getWidth(52))
            $0.height.equalTo(ScreenUtils.getHeight(36))
        }
        
        descStackView.snp.makeConstraints {
            $0.centerY.equalTo(vertiLineImageView)
            $0.width.equalTo(ScreenUtils.getWidth(213))
        }
    }
    
    func setStyle() {
        self.backgroundColor = .white
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 6
        self.layer.borderColor = UIColor.gray100.cgColor
    }
}
