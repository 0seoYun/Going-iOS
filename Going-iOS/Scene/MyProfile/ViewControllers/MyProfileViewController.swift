//
//  MyProfileViewController.swift
//  Going-iOS
//
//  Created by 윤영서 on 1/11/24.
//

import UIKit

import SnapKit
import Photos

final class MyProfileViewController: UIViewController {
    
    private lazy var navigationBar = DOONavigationBar(self, type: .backButtonWithTitle("내 여행 프로필"))
    private lazy var saveButton: UIButton = {
        let btn = UIButton()
        btn.setImage(ImageLiterals.NavigationBar.buttonSave, for: .normal)
        btn.addTarget(self, action: #selector(saveImageButtonTapped), for: .touchUpInside)
        return btn
    }()
    private let naviUnderLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray100
        return view
    }()
    
    private let myProfileScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    private let contentView = UIView()
    
    private let profileImageView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.image = ImageLiterals.Profile.imgSnowmanSRI
        img.layer.cornerRadius = 55
        img.clipsToBounds = true
        img.layer.borderColor = UIColor.gray100.cgColor
        img.layer.borderWidth = 1
        return img
    }()
    
    private let nickNameLabel = DOOLabel(font: .pretendard(.head2), color: .red500, text: "두릅티비")
    private let descriptionLabel = DOOLabel(font: .pretendard(.detail1_regular), color: .gray500, text: "나는 두릅이 좋다.")
    
    private let dividingBarView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray50
        return view
    }()
    
    private let myResultView = MyResultView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setStyle()
        setHierarchy()
        setLayout()
    }
}

private extension MyProfileViewController {
    func setStyle() {
        contentView.backgroundColor = .white000
        view.backgroundColor = .white000
    }
    
    func setHierarchy() {
        view.addSubviews(navigationBar, saveButton, naviUnderLineView, myProfileScrollView)
        navigationBar.addSubview(saveButton)
        myProfileScrollView.addSubviews(contentView)
        contentView.addSubviews(profileImageView,
                                nickNameLabel,
                                descriptionLabel,
                                dividingBarView,
                                myResultView)
    }
    
    func setLayout() {
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.getHeight(50))
        }
        
        saveButton.snp.makeConstraints {
            $0.centerY.equalTo(navigationBar)
            $0.trailing.equalToSuperview().inset(10)
        }
        
        naviUnderLineView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        myProfileScrollView.snp.makeConstraints {
            $0.top.equalTo(naviUnderLineView.snp.bottom)
            $0.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(myProfileScrollView.frameLayoutGuide)
            $0.height.greaterThanOrEqualTo(view.snp.height).priority(.low)
        }
        
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(36)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(ScreenUtils.getWidth(110))
        }
        
        nickNameLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(profileImageView.snp.bottom).offset(12)
            $0.height.equalTo(ScreenUtils.getHeight(33))
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(nickNameLabel.snp.bottom).offset(4)
        }
        
        dividingBarView.snp.makeConstraints {
            $0.bottom.equalTo(myResultView.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.getHeight(8))
        }
        
        myResultView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(contentView.snp.bottom)
        }
    }
    
    func saveImage() {
        UIImageWriteToSavedPhotosAlbum(UIImage(systemName: "pencil")!, self, nil, nil)
        // TODO: - height 다시 잡기
        DOOToast.show(message: "이미지로 저장되었어요\n친구에게 내 캐릭터를 공유해 보세요", insetFromBottom: 70)
    }
    
    func showPermissionAlert() {
        // PHPhotoLibrary.requestAuthorization() 결과 콜백이 main thread로부터 호출되지 않기 때문에
        // UI처리를 위해 main thread내에서 팝업을 띄우도록 함.
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: nil, message: "설정으로 이동하여 권한을 허용해주세요. 내 여행 프로필에서 다시 저장할 수 있어요.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default, handler: { _ in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }))
            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
            
        }
    }
    
    @objc
    func saveImageButtonTapped() {
        checkAccess()
    }
}

extension MyProfileViewController: CheckPhotoAccessProtocol {
    func checkAccess() {
        switch PHPhotoLibrary.authorizationStatus(for: .addOnly) {
            
        case .notDetermined, .denied:
            UserDefaults.standard.set(false, forKey: "photoPermissionKey")
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
                switch status {
                case .authorized, .limited:
                    UserDefaults.standard.set(true, forKey: "photoPermissionKey")
                    print("권한설정됐다는 토스트? 띄우면 좋을듯")
                case .denied:
                    DispatchQueue.main.async {
                        self?.showPermissionAlert()
                    }
                default:
                    print("그 밖의 권한이 부여 되었습니다.")
                }
                
            }
        case .restricted, .limited, .authorized:
            saveImage()
            UserDefaults.standard.set(true, forKey: "photoPermissionKey")
        @unknown default:
            print("unKnown")
        }
    }
}