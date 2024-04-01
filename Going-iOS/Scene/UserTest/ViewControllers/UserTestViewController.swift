//
//  UserTestViewController.swift
//  Going-iOS
//
//  Created by 곽성준 on 1/5/24.
//

import UIKit

import SnapKit

final class UserTestViewController: UIViewController {
        
    private lazy var navigationBar = DOONavigationBar(self, type: .titleLabelOnly("나의 여행 캐릭터는?"))
    
    private var buttonIndexList: [Int] = []
    
    private var travelTypeRequsetBody = TravelTypeTestRequestDTO(result: [])
    
    private var index: Int = 0
    
    private var buttonIndex: Int = 0
    
    private let userTestDataStruct = UserTestQuestionStruct.dummy()
    
    private var selectedButton: UIButton?
    
    private let testProgressView: UIProgressView = {
        let progress = UIProgressView()
        progress.progressTintColor = UIColor(resource: .red500)
        progress.setProgress(0.1111111, animated: true)
        return progress
    }()
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .imgTest)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let testIndexLabel = DOOLabel(font: .pretendard(.head3), color: UIColor(resource: .gray300))
    private let questionLabel = DOOLabel(font: .pretendard(.head3), color: UIColor(resource: .gray700))
    
    private let questionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        return stackView
    }()
    
    private lazy var firstButton: UIButton = makeButton()
    private lazy var secondButton: UIButton = makeButton()
    private lazy var thirdButton: UIButton = makeButton()
    private lazy var fourthButton: UIButton = makeButton()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("다음", for: .normal)
        button.backgroundColor = UIColor(resource: .gray50)
        button.isEnabled = false
        button.titleLabel?.font = .pretendard(.body1_bold)
        button.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setHierarchy()
        setLayout()
        setStyle()
        updateNextButtonState()
        updateLabel()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hideTabbar()
    }

    
}

private extension UserTestViewController {
    func hideTabbar() {
        self.navigationController?.tabBarController?.tabBar.isHidden = true

    }
    func makeButton() -> UIButton {
        let button = UIButton()
        button.backgroundColor = UIColor(resource: .gray50)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .pretendard(.body3_medi)
        button.setTitleColor(UIColor(resource: .gray500), for: .normal)
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        return button
    }
    
    func setHierarchy() {
        view.addSubviews(navigationBar, testProgressView, testIndexLabel, questionLabel, questionStackView, nextButton, backgroundImageView)
        self.questionStackView.addArrangedSubviews(firstButton, secondButton, thirdButton, fourthButton)
    }
    
    func setLayout() {
        
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.getHeight(50))
        }
        testProgressView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.trailing.leading.equalToSuperview()
            $0.height.equalTo(ScreenUtils.getHeight(8))
        }
        
        testIndexLabel.snp.makeConstraints {
            $0.top.equalTo(testProgressView.snp.bottom).offset(40)
            $0.leading.equalToSuperview().inset(24)
        }
        
        questionLabel.snp.makeConstraints {
            $0.top.equalTo(testIndexLabel.snp.bottom).offset(ScreenUtils.getHeight(8))
            $0.leading.equalTo(testIndexLabel.snp.leading)
        }
        
        questionStackView.snp.makeConstraints {
            $0.top.equalTo(questionLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        firstButton.snp.makeConstraints {
            $0.width.equalTo(ScreenUtils.getWidth(327))
            $0.height.equalTo(ScreenUtils.getHeight(60))
        }
        
        nextButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.getHeight(68))
        }
        
        backgroundImageView.snp.makeConstraints {
            $0.bottom.equalTo(nextButton.snp.top)
            $0.trailing.equalToSuperview()
        }
    }
    
    func setStyle() {
        view.backgroundColor = UIColor(resource: .white000)
    }
    
}

private extension UserTestViewController {
    
    func updateLabel() {
        testIndexLabel.text = "\(userTestDataStruct[index].testIndex) / 9"
        questionLabel.text = "\(userTestDataStruct[index].testTitle)"
        
        firstButton.setTitle("\(userTestDataStruct[index].testText.firstQuest)", for: .normal)
        secondButton.setTitle("\(userTestDataStruct[index].testText.secondQuest)", for: .normal)
        thirdButton.setTitle("\(userTestDataStruct[index].testText.thirdQuest)", for: .normal)
        fourthButton.setTitle("\(userTestDataStruct[index].testText.fourthQuest)", for: .normal)
    }
    
    func updateNextButtonState() {
        // 선택된 버튼이 있는지 확인하고 nextButton의 활성화 여부를 결정
        nextButton.isEnabled = selectedButton == nil ? false : true
        nextButton.backgroundColor = nextButton.isEnabled ? UIColor(resource: .gray500) : UIColor(resource: .gray50)
        if nextButton.isEnabled {
            nextButton.setTitleColor(UIColor(resource: .white000), for: .normal)
        } else {
            nextButton.setTitleColor(UIColor(resource: .gray200), for: .normal)
        }

        }
    
    func setAnimation() {
        
        let questButton = [firstButton, secondButton,
                           thirdButton, fourthButton]
        questButton.forEach {
            $0.isEnabled = false
        }
        UIView.animate(withDuration: 0.5, animations: {
            questButton.forEach {
                $0.titleLabel?.alpha = 0.0
            }

        }) { [self] _ in
            
            // fade out 애니메이션 종료 후 실행될 코드
            if index < 9 {
                updateLabel()
            }
            UIView.animate(withDuration: 0.5) {
                questButton.forEach {
                    $0.titleLabel?.alpha = 1.0
                }
                questButton.forEach {
                    $0.isEnabled = true
                }
            }
        }
    }

    
    @objc
    func buttonTapped(_ sender: UIButton) {
        guard let buttonIndex = questionStackView.arrangedSubviews.firstIndex(of: sender) else {
            return
        }
        print("Button Tapped: \(sender.title(for: .normal) ?? ""), Index: \(buttonIndex)")
        self.buttonIndex = buttonIndex
        
        // 클릭안된 다른 버튼들의 색상 변경
        for case let button as UIButton in questionStackView.arrangedSubviews {
            button.backgroundColor = UIColor(resource: .gray50)
            button.layer.borderWidth = 0
            button.titleLabel?.font = .pretendard(.body3_medi)

        }
        
        // 클릭된 버튼의 색상 변경
        sender.backgroundColor = UIColor(resource: .white000)
        sender.layer.borderColor = UIColor(resource: .red500).cgColor
        sender.layer.borderWidth = 1
        sender.titleLabel?.textColor = UIColor(resource: .gray700)
        sender.titleLabel?.font = .pretendard(.body3_bold)
        
        selectedButton = sender
        
        // nextButton 상태 갱신
        if selectedButton == nil {
            nextButton.isEnabled = false
            nextButton.backgroundColor = UIColor(resource: .gray50)
            nextButton.setTitleColor(UIColor(resource: .gray200), for: .normal)

        } else {
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor(resource: .gray500)
            nextButton.setTitleColor(UIColor(resource: .white000), for: .normal)
        }
    }
    
    
    @objc
    func nextButtonTapped() {
        
        selectedButton?.backgroundColor = UIColor(resource: .gray50)
        selectedButton?.setTitleColor(UIColor(resource: .gray500), for: .normal)
        selectedButton?.layer.borderWidth = 0
        selectedButton?.titleLabel?.font = .pretendard(.body3_medi)
        selectedButton = nil

        if index < userTestDataStruct.count - 1 {
            buttonIndexList.append(self.buttonIndex)
            // 질문이 마지막이 아닌 경우
            if index == 7 {
                nextButton.setTitle("결과보기", for: .normal)
            }
            testProgressView.setProgress(testProgressView.progress + 0.1111111, animated: true)
            
            setAnimation()
            index += 1

            // nextButton 상태 초기화
            if selectedButton == nil {
                nextButton.isEnabled = false
                nextButton.backgroundColor = UIColor(resource: .gray50)
                nextButton.setTitleColor(UIColor(resource: .gray200), for: .normal)
            }
        } else if index == 8 {
            buttonIndexList.append(self.buttonIndex)
            travelTypeRequsetBody.result = buttonIndexList
            patchTravelTypeTestResult()
            index += 1

        }

    }
}

extension UserTestViewController {
    
    func patchTravelTypeTestResult() {
        travelTypeRequsetBody.result = buttonIndexList
        
        Task {
            do {
                
                try await OnBoardingService.shared.patchTravelTypeTest(requestDTO: travelTypeRequsetBody)
                let nextVC = UserTestResultViewController()
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
            catch {
                guard let error = error as? NetworkError else { return }
                handleError(error)
            }
        }
    }
}

extension UserTestViewController: ViewControllerServiceable {
    func handleError(_ error: NetworkError) {
        switch error {
        case .serverError:
            DOOToast.show(message: "서버오류", insetFromBottom: 80)
        case .unAuthorizedError, .reIssueJWT:
            DOOToast.show(message: "토큰만료, 재로그인필요", insetFromBottom: 80)
            let nextVC = LoginViewController()
            self.navigationController?.pushViewController(nextVC, animated: true)
        case .userState(let code, let message):
            DOOToast.show(message: "\(code) : \(message)", insetFromBottom: 80)
        default:
            DOOToast.show(message: error.description, insetFromBottom: 80)
        }
    }
}
