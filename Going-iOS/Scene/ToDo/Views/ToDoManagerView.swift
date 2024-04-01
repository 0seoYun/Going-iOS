//
//  ToDoManagerCollectionView.swift
//  Going-iOS
//
//  Created by 윤희슬 on 1/24/24.
//

import UIKit

protocol ToDoManagerViewDelegate: AnyObject {
    func tapToDoManagerButton(_ sender: UIButton)
}

class ToDoManagerView: UIView {
    
    private let managerLabel: UILabel = DOOLabel(
        font: .pretendard(.body2_bold),
        color: UIColor(resource: .gray700),
        text: StringLiterals.ToDo.allocation
    )
    
    let todoManagerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.register(ToDoManagerCollectionViewCell.self, forCellWithReuseIdentifier: ToDoManagerCollectionViewCell.identifier)
        return collectionView
    }()

    var name: String = ""
    
    var emojiCount: Int = 0
    
    var textWidth: CGFloat = 0

    var fromOurTodoParticipants: [Participant] = []
    
    var allParticipants: [DetailAllocators] = []
    
    var allocators: [DetailAllocators] = []
    
    var beforeVC: String = ""
    
    var navigationBarTitle: String = ""
    
    lazy var isSecret: Bool = false
    
    weak var delegate: ToDoManagerViewDelegate?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setHierarchy()
        setLayout()
        setDelegate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 담당자 버튼 클릭 시 버튼 스타일 변경해주는 메소드
    func changeButtonConfig(isSelected: Bool, btn: UIButton) {
        if beforeVC == "my" {
            let text = btn.titleLabel?.text ?? ""
            var config = UIButton.Configuration.plain()
            var attributedTitle = AttributedString(text)
            attributedTitle.font = .pretendard(.detail2_regular)
            if !isSelected {
                if btn.tag == 0 {
                    setConfigButtonStyle(type: "allocatorRed", name: text, button: btn)
                } else {
                    setConfigButtonStyle(type: "allocatorGray", name: text, button: btn)
                }
            } else {
                setConfigButtonStyle(type: "gray", name: text, button: btn)
            }
        } else {
            if !isSelected {
                if btn.tag == 0 {
                    setButtonStyle(type: "filledRed", button: btn)
                } else {
                    setButtonStyle(type: "filledGray", button: btn)
                }
            } else {
                setButtonStyle(type: "gray", button: btn)
            }
        }
    }
    
    // 담당자 버튼 탭 시 버튼 색상 변경 & 배열에 담아주는 메서드
    @objc
    func didTapToDoManagerButton(_ sender: UIButton) {
        self.delegate?.tapToDoManagerButton(sender)
    }
}

private extension ToDoManagerView {
    
    func setHierarchy() {
        self.addSubviews(managerLabel, todoManagerCollectionView)
    }
    
    func setLayout() {
        managerLabel.snp.makeConstraints{
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.getHeight(23))
        }
        
        todoManagerCollectionView.snp.makeConstraints{
            $0.top.equalTo(managerLabel.snp.bottom).offset(ScreenUtils.getHeight(8))
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.getHeight(24))
        }
    }
    
    func setDelegate() {
        todoManagerCollectionView.delegate = self
        todoManagerCollectionView.dataSource = self
    }
    
    func getTextSize(label: String) -> CGFloat {
        // 이모지를 고려하여 예상되는 텍스트의 크기를 얻기
        let textSize = (label as NSString?)?.boundingRect(with:
                                                            CGSize(width: CGFloat.greatestFiniteMagnitude, height: 20),
                                                            options: .usesLineFragmentOrigin,
                                                            attributes: [NSAttributedString.Key.font: UIFont.pretendard(.detail2_regular)],
                                                            context: nil).size

        let textWidth = textSize?.width ?? 0
        
        return textWidth
    }
    
    func setButtonStyle(type: String, button: UIButton) {
        
        switch type {
        case "filledRed":
            button.backgroundColor = UIColor(resource: .red500)
            button.setTitleColor(UIColor(resource: .white000), for: .normal)
            button.layer.borderColor = UIColor(resource: .red500).cgColor
        case "filledGray":
            button.backgroundColor = UIColor(resource: .gray400)
            button.setTitleColor(UIColor(resource: .white000), for: .normal)
            button.layer.borderColor = UIColor(resource: .gray400).cgColor
        case "gray":
            button.backgroundColor = UIColor(resource: .white000)
            button.setTitleColor(UIColor(resource: .gray300), for: .normal)
            button.layer.borderColor = UIColor(resource: .gray300).cgColor
        default:
            return
        }
    }
    
    func setConfigButtonStyle(type: String, name: String, button: UIButton) {
            
            var config = UIButton.Configuration.plain()

            var attributedTitle = AttributedString(name)
            attributedTitle.font = .pretendard(.detail2_regular)
            
            switch type {
            case "secretInfoLabel" :
                config.background.backgroundColor = .white000
                attributedTitle.foregroundColor = UIColor.gray200
                button.layer.borderColor = UIColor(resource: .white000).cgColor
            case "labelWithImage" :
                attributedTitle.foregroundColor = .red500
                config.image = UIImage(resource: .icLock)
                config.imagePlacement = .leading
                config.imagePadding = 1
                config.background.backgroundColor = .white000
                button.layer.borderColor = UIColor(resource: .red500).cgColor
            case "allocatorRed" :
                config.background.backgroundColor = .red500
                attributedTitle.foregroundColor = UIColor.white000
                button.layer.borderColor = UIColor(resource: .red500).cgColor
            case "allocatorGray":
                config.background.backgroundColor = .gray400
                attributedTitle.foregroundColor = UIColor.white000
                button.layer.borderColor = UIColor(resource: .gray400).cgColor
            case "gray":
                config.background.backgroundColor = .white000
                attributedTitle.foregroundColor = UIColor.gray300
                button.layer.borderColor = UIColor(resource: .gray300).cgColor
            default: return
            }

            config.background.cornerRadius = 4
            config.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
            config.attributedTitle = attributedTitle
            button.configuration = config
        }
}


// MARK: - Extension

extension ToDoManagerView: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 마이투두 - 할일추가 - 1로 픽스
        
        if beforeVC == "our" {
            if navigationBarTitle == StringLiterals.ToDo.add {
                return self.fromOurTodoParticipants.count
            }
            return self.allParticipants.count
        }
        else {
            //'혼자 할일' 추가 및 조회의 경우
            if navigationBarTitle == StringLiterals.ToDo.edit && !self.isSecret{
                return self.allParticipants.count
            } else {
                return self.allocators.count
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let managerCell = collectionView.dequeueReusableCell(withReuseIdentifier: ToDoManagerCollectionViewCell.identifier, for: indexPath) as? ToDoManagerCollectionViewCell else {return UICollectionViewCell()}
        
        var config = UIButton.Configuration.plain()
        
        var name = ""
        
        //아워투두
        if beforeVC == "our" {
            if navigationBarTitle == StringLiterals.ToDo.add {
                name = fromOurTodoParticipants[indexPath.row].name
            } else {
                name = allParticipants[indexPath.row].name
            }
            managerCell.managerButton.setTitle(name, for: .normal)
        }
        //마이투두
        else {
            //마이투두 -> '혼자 할 일'이거나 추가 작업인 경우
            if navigationBarTitle == StringLiterals.ToDo.add || isSecret {
                name = allocators[indexPath.row].name
            }
            else {
                name = allParticipants[indexPath.row].name
            }
        }
        
        managerCell.managerButton.isEnabled = true
        managerCell.managerButton.tag = indexPath.row
        managerCell.managerButton.addTarget(self, action: #selector(didTapToDoManagerButton(_:)), for: .touchUpInside)
        
        //아워투두 -> 조회
        //다 선택된 옵션
        //마이투두 -> 조회
        //혼자할일 + 라벨
        
        //아워투두
        if beforeVC == "our" {
            //아워투두 -> 추가
            if self.navigationBarTitle == StringLiterals.ToDo.add {
                setButtonStyle(type: "gray", button: managerCell.managerButton)
            }
            //아워투두 -> 수정 & 조회
            else {
                //담당자로 배정되어 있는 경우
                if self.allParticipants[indexPath.row].isAllocated {
                    managerCell.managerButton.isSelected = true
                    
                    //담당자이면서 owner인 경우
                    if self.allParticipants[indexPath.row].isOwner {
                        setButtonStyle(type: "filledRed", button: managerCell.managerButton)
                    }
                    //담당자이면서 owner가 아닌 경우
                    else {
                        setButtonStyle(type: "filledGray", button: managerCell.managerButton)
                    }
                }
                //담당자로 배정되어 있지 않은 경우
                else {
                    setButtonStyle(type: "gray", button: managerCell.managerButton)
                }
            }
        }
        //마이투두
        else {
            managerCell.managerButton.isEnabled = false
            
            //마이투두 -> 조회
            if self.navigationBarTitle == StringLiterals.ToDo.inquiry {
                managerCell.managerButton.isSelected = true
                
                //'혼자 할 일'을 조회할 경우
                if self.isSecret {
                    //설명라벨 세팅
                    if allocators[indexPath.row].name == "나만 볼 수 있는 할일이에요" {
                        setConfigButtonStyle(type: "secretInfoLabel", 
                                             name: name, 
                                             button: managerCell.managerButton)
                    } else {
                        setConfigButtonStyle(type: "labelWithImage", 
                                             name: name,
                                             button: managerCell.managerButton)
                    }
                    config.contentInsets = NSDirectionalEdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 0)
                }
                //그 외의 경우
                else{
                    if self.allocators[indexPath.row].isAllocated {
                        //담당자이면서 owner인 경우
                        if self.allocators[indexPath.row].isOwner {
                            setConfigButtonStyle(type: "allocatorRed", 
                                                 name: name,
                                                 button: managerCell.managerButton)
                        }
                        //담당자이면서 owner가 아닌 경우
                        else {
                            setConfigButtonStyle(type: "allocatorGray", 
                                                 name: name,
                                                 button: managerCell.managerButton)
                        }
                    }
                    else {
                        setConfigButtonStyle(type: "gray", 
                                             name: name,
                                             button: managerCell.managerButton)
                    }
                }
            }
            //마이투두 -> 추가 작업이거나 '혼자 할 일'을 수정하려는 작업인 경우
            else if self.navigationBarTitle == StringLiterals.ToDo.add ||
                        (self.navigationBarTitle == StringLiterals.ToDo.edit && isSecret) {
                //설명라벨 세팅
                if allocators[indexPath.row].name == "나만 볼 수 있는 할일이에요" {
                    managerCell.managerButton.isEnabled = false
                    setConfigButtonStyle(type: "secretInfoLabel", 
                                         name: name,
                                         button: managerCell.managerButton)
                } else {
                    managerCell.managerButton.isUserInteractionEnabled = false
                    setConfigButtonStyle(type: "labelWithImage", 
                                         name: name,
                                         button: managerCell.managerButton)
                }
            }
            //마이투두 -> '혼자 할 일'을 제외한 수정 작업
            else {
                managerCell.managerButton.isEnabled = true
                
                //담당자인 경우
                if self.allParticipants[indexPath.row].isAllocated {
                    managerCell.managerButton.isSelected = true
                    //담당자이면서 owner인 경우
                    if self.allParticipants[indexPath.row].isOwner {
                        setConfigButtonStyle(type: "allocatorRed", 
                                             name: name,
                                             button: managerCell.managerButton)
                    }
                    //담당자이면서 owner가 아닌 경우
                    else {
                        setConfigButtonStyle(type: "allocatorGray", 
                                             name: name,
                                             button: managerCell.managerButton)
                    }
                }
                //담당자가 아닌 경우
                else {
                    setConfigButtonStyle(type: "gray", 
                                         name: name,
                                         button: managerCell.managerButton)
                }
            }
        }
        return managerCell
    }
}

extension ToDoManagerView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return ScreenUtils.getWidth(3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return ScreenUtils.getWidth(3)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if (isSecret) ||
            (beforeVC == "my"  && navigationBarTitle == StringLiterals.ToDo.add ) {
            if indexPath.row == 0 {
                return CGSize(width: ScreenUtils.getWidth(66), height: ScreenUtils.getHeight(20))
            } else {
                return CGSize(width: ScreenUtils.getWidth(127), height: ScreenUtils.getHeight(20))
            }
        } else {
            
            //아워투두
            if beforeVC == "our" {
                if navigationBarTitle == StringLiterals.ToDo.add {
                    name = fromOurTodoParticipants[indexPath.row].name
                }else {
                    name = allParticipants[indexPath.row].name
                }
            }
            //마이투두
            else {
                //마이투두 -> '혼자 할 일'이거나 추가 작업인 경우
                if navigationBarTitle == StringLiterals.ToDo.add || isSecret {
                    name = allocators[indexPath.row].name
                }
                else {
                    name = allParticipants[indexPath.row].name
                }
            }
        
            if name.containsEmoji() {
                textWidth = getTextSize(label: name)
                emojiCount = name.getEmojiCount()
                
                if emojiCount >= 0 {
                    return CGSize(width: ScreenUtils.getWidth(textWidth + 14), height: ScreenUtils.getHeight(20))
                }
                
            } else {
                return CGSize(width: ScreenUtils.getWidth(42), height: ScreenUtils.getHeight(20))
            }
        }
        return CGSize(width: ScreenUtils.getWidth(textWidth + 14), height: ScreenUtils.getHeight(20))
    }
}

