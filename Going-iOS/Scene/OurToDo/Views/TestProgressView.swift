//
//  TestProgressView.swift
//  Going-iOS
//
//  Created by 윤영서 on 1/11/24.
//

import UIKit

import SnapKit

final class TestProgressView: UIView {
    
    private let questionLabel = DOOLabel(font: .pretendard(.body3_bold), color: .gray700, text: "여행 스타일")
    private let progressBarView: UIProgressView = {
        let view = UIProgressView()
        view.progress = 0.4
        view.trackTintColor = .gray50
        view.progressTintColor = .red500
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()
    private let leftOption = DOOLabel(font: .pretendard(.detail2_regular), color: .gray700, text: "휴식")
    private let rightOption = DOOLabel(font: .pretendard(.detail2_regular), color: .gray700, text: "관광")
    
    // MARK: - Life Cycle

    override init(frame: CGRect) {
        super.init(frame: frame)
                
        setStyle()
        setHierarchy()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension TestProgressView {
    func setStyle() {
        self.backgroundColor = .white000
    }
    
    func setHierarchy() {
        self.addSubviews(questionLabel, progressBarView, leftOption, rightOption)
    }
    
    func setLayout() {
        questionLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.height.equalTo(ScreenUtils.getHeight(21))
            $0.centerX.equalToSuperview()
        }
        
        progressBarView.snp.makeConstraints {
            $0.top.equalTo(questionLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.getHeight(16))
        }
        
        leftOption.snp.makeConstraints {
            $0.top.equalTo(progressBarView.snp.bottom).offset(6)
            $0.leading.equalToSuperview()
        }
        
        rightOption.snp.makeConstraints {
            $0.top.equalTo(progressBarView.snp.bottom).offset(6)
            $0.trailing.equalToSuperview()
        }
    }
}
