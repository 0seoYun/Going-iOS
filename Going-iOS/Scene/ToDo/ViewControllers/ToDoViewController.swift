import UIKit

import SnapKit

final class ToDoViewController: UIViewController {
    
    // MARK: - 데이트피커에서 받은 데이트
    
    var selectedDate: Date?
    
    // MARK: - Network
    
    var tripId: Int = 0
    
    var myId: Int = 0

    private var toDorequestData = CreateToDoRequestStruct(title: "", endDate: "", allocators: [], memo: "", secret: false)
    
    // MARK: - UI Components
    
    var idSet: [Int] = []
    
    var fromOurTodoParticipants: [Participant] = []
    
    private lazy var navigationBarView = DOONavigationBar(self, type: .backButtonWithTitle(StringLiterals.ToDo.inquiryToDo), backgroundColor: .white000)
    private let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray100
        return view
    }()
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white000
        return scrollView
    }()
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white000
        return view
    }()
    private let todoLabel: UILabel = DOOLabel(font: .pretendard(.body2_bold), color: .gray700, text: StringLiterals.ToDo.todo)
    private lazy var todoTextfield: UITextField = {
        let tf = UITextField()
        tf.setTextField(forPlaceholder: "", forBorderColor: .gray200, forCornerRadius: 6)
        tf.font = .pretendard(.body3_medi)
        tf.setPlaceholderColor(.gray700)
        tf.textColor = .gray700
        tf.backgroundColor = .white000
        tf.setLeftPadding(amount: 12)
        tf.addTarget(self, action: #selector(todoTextFieldDidChange), for: .editingChanged)
        return tf
    }()
    private var todoTextFieldCount: Int = 0
    private let countToDoCharacterLabel: UILabel = DOOLabel(font: .pretendard(.detail2_regular), color: .gray200, text: "0/15")
    private let deadlineLabel: UILabel = DOOLabel(font: .pretendard(.body2_bold), color: .gray700, text: StringLiterals.ToDo.deadline)
    private lazy var deadlineTextfieldLabel: DOOLabel = {
        let label = DOOLabel(font: .pretendard(.body3_medi), color: .gray200, alignment: .left, padding: UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0))
        let gesture = UITapGestureRecognizer(target: self, action: #selector(presentToDatePicker) )
        label.backgroundColor = .white000
        label.layer.borderColor = UIColor.gray200.cgColor
        label.layer.cornerRadius = 6
        label.layer.borderWidth = 1
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(gesture)
        return label
    }()
    private let bottomSheetVC = DatePickerBottomSheetViewController()
    private let dropdownContainer: UIView = UIView()
    private lazy var dropdownButton: UIButton = {
        let btn = UIButton()
        btn.setImage(ImageLiterals.ToDo.disabledDropdown, for: .normal)
        btn.backgroundColor = .white000
        btn.addTarget(self, action: #selector(presentToDatePicker), for: .touchUpInside)
        return btn
    }()
    private let managerLabel: UILabel = DOOLabel(font: .pretendard(.body2_bold), color: .gray700, text: StringLiterals.ToDo.allocation)
    private lazy var todoManagerCollectionView: UICollectionView = {
        setCollectionView()
    }()
    private let memoLabel: UILabel = DOOLabel(font: .pretendard(.body2_bold), color: .gray700, text: StringLiterals.ToDo.memo)
    private var memoTextViewCount: Int = 0
    private let memoTextView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .white000
        tv.textContainerInset = UIEdgeInsets(top: ScreenUtils.getHeight(12), left: ScreenUtils.getWidth(12), bottom: ScreenUtils.getHeight(12), right: ScreenUtils.getWidth(12))
        tv.font = .pretendard(.body3_medi)
        tv.textColor = .gray200
        tv.layer.borderColor = UIColor.gray200.cgColor
        tv.layer.cornerRadius = 6
        tv.layer.borderWidth = 1
        return tv
    }()
    private let countMemoCharacterLabel: UILabel = DOOLabel(font: .pretendard(.detail2_regular), color: .gray200, text: "0/1000")
    private let buttonView: UIView = UIView()
    private lazy var singleButtonView: DOOButton = {
        let singleBtn = DOOButton(type: .unabled, title: StringLiterals.ToDo.toSave)
        singleBtn.addTarget(self, action: #selector(saveToDo), for: .touchUpInside)
        return singleBtn
    }()
    private lazy var doubleButtonView = DoubleButtonView()
    
    // MARK: - Properties
    
    var peopleCount: Int = 0
    
    var buttonIndex: [Int] = []
    
    var todoId: Int = 0
    
    lazy var beforeVC: String = "" {
        didSet {
            if navigationBarTitle == "추가" && beforeVC == "my" {
                self.manager = [.init(name: "혼자할일", isOwner: true)]
                peopleCount = 1
            } 
//            else if navigationBarTitle == "추가" && beforeVC == "our" {
////                self.fromOurTodoParticipants
//                self.manager =
//            }
        }
    }
    
    lazy var navigationBarTitle: String = ""
    var manager: [Allocators] = []
    private var memoTextviewPlaceholder: String = ""
    private var todoTextfieldPlaceholder: String = ""
    private var saveToDoData: CreateToDoRequestStruct = .init(title: "", endDate: "", allocators: [], memo: "", secret: false)
    
    var data: GetDetailToDoResponseStuct? {
        didSet {
            guard let data else {return}
            todoTextfield.text = data.title
            deadlineTextfieldLabel.text = data.endDate
            manager = data.allocators
            if data.secret == true {
                self.manager[0].name = "혼자할일"
                self.manager.append(Allocators.EmptyData)
            }
            if navigationBarTitle == "조회" {
                navigationBarView.titleLabel.text = "할일 조회"
                setDefaultValue = [data.title, data.endDate, self.manager , data.memo]
                setInquiryStyle()
            }
            memoTextView.text = data.memo
            
            self.todoManagerCollectionView.reloadData()
        }
    }
    var setDefaultValue: [Any]? {
        didSet {
            guard let value = setDefaultValue else {return}
            todoTextfieldPlaceholder = value[0] as! String
            todoTextfield.placeholder = todoTextfieldPlaceholder
            deadlineTextfieldLabel.text = value[1] as? String
            manager = value[2] as! [Allocators]
            memoTextviewPlaceholder = value[3] as! String
            memoTextView.text = memoTextviewPlaceholder
        }
    }
    
    var isActivateView: Bool? = false {
        didSet {
            guard let isActivateView else {return}
            self.todoTextfield.isUserInteractionEnabled = isActivateView ? true : false
            self.deadlineTextfieldLabel.isUserInteractionEnabled = isActivateView ? true : false
            self.todoManagerCollectionView.isUserInteractionEnabled = isActivateView ? true : false
            self.memoTextView.isUserInteractionEnabled = isActivateView ? true : false
        }
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setHierachy()
        setLayout()
        setDelegate()
        setStyle()
        registerCell()
        
        if navigationBarTitle == "추가" {
            navigationBarView.titleLabel.text = "할일 추가"
            setDefaultValue = ["할일을 입력해주세요.", "날짜를 선택해주세요.", self.manager, "메모를 입력해주세요."]
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationBarView.backgroundColor = .gray50
        self.tabBarController?.tabBar.isHidden = false
        self.removeNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if navigationBarTitle == StringLiterals.ToDo.inquiry {
            setInquiryStyle()
        }
        if navigationBarTitle == "조회" {
            self.getDetailToDoData(todoId: self.todoId)
        }
        addNotification()
    }
    
    func setNaviTitle() {
        switch navigationBarTitle {
            
        case "수정":
            navigationBarView.titleLabel.text = "할일 수정"
            setDefaultValue = ["수정", "수정", self.manager , "수정"]
        default:
            return
        }
    }
    
    // 키보드 관련 알림 등록
    func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // 키보드 관련 알림 등록
    func removeNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification , object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /// 키보드내리기
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    // MARK: - @objc Methods
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        if memoTextView.isFirstResponder {
            // memoTextView가 FirstResponder인 경우 contentInset을 조절
            let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.size.height - ScreenUtils.getHeight(60), right: 0)
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset
            
            // 버튼 뷰의 위치 조절
            buttonView.snp.remakeConstraints {
                $0.top.equalTo(countMemoCharacterLabel.snp.bottom).offset(10)
                $0.leading.trailing.equalToSuperview().inset(ScreenUtils.getWidth(18))
                $0.height.equalTo(ScreenUtils.getHeight(50))
            }
            
            // memoTextView가 가려지지 않도록 자동으로 스크롤
            let rect = buttonView.convert(buttonView.bounds, to: scrollView)
            scrollView.scrollRectToVisible(rect, animated: true)
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        } else if todoTextfield.isFirstResponder {
            let height = keyboardFrame.size.height
            
            //scrollView의 contentInset 초기화
            scrollView.contentInset = UIEdgeInsets.zero
            scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
            
            // 컴포넌트의 Auto Layout 조절
            // 버튼 뷰의 위치 조절
            buttonView.snp.remakeConstraints {
                $0.leading.trailing.equalToSuperview().inset(ScreenUtils.getWidth(18))
                $0.bottom.equalTo(contentView.snp.bottom).offset(-height)
                $0.height.equalTo(ScreenUtils.getHeight(50))
            }
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        // 컴포넌트의 Auto Layout 초기 상태로 복원
        
        // 키보드가 사라질 때 scrollView의 contentInset 초기화
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
        
        // 버튼 뷰의 위치를 원래대로 조절.
        buttonView.snp.remakeConstraints {
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.getWidth(18))
            $0.bottom.equalTo(contentView.snp.bottom).inset(ScreenUtils.getHeight(40))
            $0.height.equalTo(ScreenUtils.getHeight(50))
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc
    func presentToDatePicker(for button: UIButton) {
        showDatePicker(for: button)
        dropdownButton.setImage(ImageLiterals.ToDo.tappedDropdown, for: .normal)
    }
    
    // 담당자 버튼 탭 시 버튼 색상 변경 & 배열에 담아주는 메서드
    @objc
    func didTapToDoManagerButton(_ sender: UIButton) {
        guard let isActivateView = self.isActivateView else {return}
        if isActivateView {
            
            changeButtonConfig(isSelected: sender.isSelected, btn: sender)
                    
            
            // 아워투두의 할일 추가의 경우
            
            if beforeVC == "our" {
                if sender.isSelected {
                    // 이미 선택된 셀을 또 선택한 경우
                    print("이미 선택된 셀을 또 선택했습니다.")
                    buttonIndex.removeAll(where: { $0 == sender.tag })
                    
                    // 여기에서 필요한 작업을 수행할 수 있습니다.
                } else {
                    // 새로운 셀을 선택한 경우
                    print("셀이 탭되었습니다.")
                    
                    // 여기에서 필요한 작업을 수행할 수 있습니다.
                    buttonIndex.append(sender.tag)

                }
            }
            updateSingleButtonState()
            sender.isSelected = !sender.isSelected
            
        }
    }
    
    
    @objc func viewTapped(sender: UITapGestureRecognizer) {
        // 화면을 탭하면 키보드가 닫히도록 함
        view.endEditing(true)
    }
    
    // 저장 버튼 탭 시 데이터를 배열에 담아주고 아워투두 뷰로 돌아가는 메서드
    @objc
    func saveToDo() {
        let todo = todoTextfield.text ?? ""
        let deadline = (deadlineTextfieldLabel.text == "날짜를 선택해주세요." ? "" : deadlineTextfieldLabel.text) ?? ""
        let memo = (memoTextView.text == memoTextviewPlaceholder ? "" : memoTextView.text) ?? ""
        let secret = beforeVC == "our" ? false : true
        if !todo.isEmpty && !deadline.isEmpty {
            if !buttonIndex.isEmpty {
                for i in buttonIndex {
                    idSet.append(fromOurTodoParticipants[i].participantId)
                }
            }
            if beforeVC == "my" {
                idSet = [myId]
            } else {
                
            }
            
            self.saveToDoData = CreateToDoRequestStruct(title: todo, endDate: deadline, allocators: idSet, memo: memo, secret: secret)
            print(self.saveToDoData)
            postToDoData()
            //통신
        }
    }
    
    @objc
    func todoTextFieldDidChange() {
        guard let text = todoTextfield.text else { return }
        todoTextFieldCount = text.count
        countToDoCharacterLabel.text = "\(todoTextFieldCount) / 15"
        todoTextFieldBlankCheck()
        updateSingleButtonState()
    }
}

// MARK: - Prviate Methods

private extension ToDoViewController {
    
    func setHierachy() {
        self.view.addSubviews(navigationBarView, underlineView, scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubviews(
            todoLabel,
            todoTextfield,
            countToDoCharacterLabel,
            deadlineLabel,
            deadlineTextfieldLabel,
            managerLabel,
            todoManagerCollectionView,
            memoLabel,
            memoTextView,
            countMemoCharacterLabel,
            buttonView
        )
        deadlineTextfieldLabel.addSubview(dropdownButton)
        
    }
    
    func setLayout() {
        navigationBarView.snp.makeConstraints{
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(ScreenUtils.getHeight(50))
        }
        underlineView.snp.makeConstraints{
            $0.top.equalTo(navigationBarView.snp.bottom)
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview()
        }
        scrollView.snp.makeConstraints{
            $0.top.equalTo(underlineView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        contentView.snp.makeConstraints{
            $0.top.equalTo(scrollView)
            $0.width.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(scrollView.snp.height).priority(.low)
        }
        guard let isActivateView else {return}
        isActivateView ? setButtonView(button: singleButtonView) : setButtonView(button: doubleButtonView)
        todoLabel.snp.makeConstraints{
            $0.top.equalTo(contentView).inset(ScreenUtils.getHeight(40))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.getWidth(18))
            $0.height.equalTo(ScreenUtils.getHeight(19))
        }
        todoTextfield.snp.makeConstraints{
            $0.top.equalTo(todoLabel.snp.bottom).offset(ScreenUtils.getHeight(8))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.getWidth(18))
            $0.height.equalTo(ScreenUtils.getHeight(48))
        }
        countToDoCharacterLabel.snp.makeConstraints{
            $0.top.equalTo(todoTextfield.snp.bottom).offset(4)
            $0.trailing.equalToSuperview().inset(ScreenUtils.getWidth(22))
        }
        deadlineLabel.snp.makeConstraints{
            $0.top.equalTo(todoTextfield.snp.bottom).offset(ScreenUtils.getHeight(28))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.getWidth(18))
            $0.height.equalTo(ScreenUtils.getHeight(19))
        }
        deadlineTextfieldLabel.snp.makeConstraints{
            $0.top.equalTo(deadlineLabel.snp.bottom).offset(ScreenUtils.getHeight(8))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.getWidth(18))
            $0.height.equalTo(ScreenUtils.getHeight(48))
        }
        dropdownButton.snp.makeConstraints{
            $0.trailing.equalToSuperview().inset(ScreenUtils.getWidth(12))
            $0.centerY.equalToSuperview()
            $0.size.equalTo(ScreenUtils.getHeight(22))
        }
        managerLabel.snp.makeConstraints{
            $0.top.equalTo(deadlineTextfieldLabel.snp.bottom).offset(ScreenUtils.getHeight(28))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.getWidth(18))
            $0.height.equalTo(ScreenUtils.getHeight(19))
        }
        todoManagerCollectionView.snp.makeConstraints{
            $0.top.equalTo(managerLabel.snp.bottom).offset(ScreenUtils.getHeight(8))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.getWidth(18))
            $0.height.equalTo(ScreenUtils.getHeight(20))
        }
        memoLabel.snp.makeConstraints{
            $0.top.equalTo(todoManagerCollectionView.snp.bottom).offset(ScreenUtils.getHeight(28))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.getWidth(18))
            $0.height.equalTo(ScreenUtils.getHeight(19))
        }
        memoTextView.snp.makeConstraints{
            $0.top.equalTo(memoLabel.snp.bottom).offset(ScreenUtils.getHeight(8))
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.getWidth(18))
            $0.height.equalTo(ScreenUtils.getHeight(143))
        }
        countMemoCharacterLabel.snp.makeConstraints{
            $0.top.equalTo(memoTextView.snp.bottom).offset(4)
            $0.trailing.equalToSuperview().inset(ScreenUtils.getWidth(22))
        }
        buttonView.snp.makeConstraints{
            $0.leading.trailing.equalToSuperview().inset(ScreenUtils.getWidth(18))
            $0.height.equalTo(ScreenUtils.getHeight(50))
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(6)
        }
    }
    
    // TODO: - 할일 조회 일 경우 placeholder 값이 이전에 세팅된 값이어야 함
    
    func setStyle() {
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = true
        self.view.backgroundColor = .white000
        
        // 탭 제스처 등록
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
        navigationBarView.backgroundColor = .white000
        dropdownContainer.backgroundColor = .white
    }
    
    func setDelegate() {
        todoTextfield.delegate = self
        todoManagerCollectionView.dataSource = self
        todoManagerCollectionView.delegate = self
        memoTextView.delegate = self
        bottomSheetVC.delegate = self
        doubleButtonView.delegate = self
    }
    
    func setCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        return collectionView
    }
    
    func registerCell() {
        self.todoManagerCollectionView.register(ToDoManagerCollectionViewCell.self, forCellWithReuseIdentifier: ToDoManagerCollectionViewCell.identifier)
    }
    
    /// 담당자 버튼 클릭 시 버튼 스타일 변경해주는 메소드
    func changeButtonConfig(isSelected: Bool, btn: UIButton) {
        if !isSelected {
            btn.setTitleColor(.white000, for: .normal)
            btn.backgroundColor = btn.tag == 0 ? UIColor.red500 : UIColor.gray400
            btn.layer.borderColor = btn.tag == 0 ? UIColor.red500.cgColor : UIColor.gray400.cgColor
        }else {
            btn.setTitleColor(.gray300, for: .normal)
            btn.backgroundColor = .white000
            btn.layer.borderColor = UIColor.gray300.cgColor
        }
    }
    
    // 추가, 조회 뷰에 따라 하단 버튼을 세팅해주는 메서드
    func setButtonView(button: UIView) {
        isActivateView = navigationBarTitle != "조회" ? true : false
        buttonView.addSubview(button)
        button.snp.makeConstraints{
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    // 조회 뷰 스타일 세팅 메서드
    // TODO: - 서버 통신 할 때 버튼 색상 변경 로직 추가 + placeholder랑 비교해서 빈값인지 확인
    func setInquiryStyle() {
        guard let todotext = todoTextfield.placeholder?.count else {return}
        guard let memotext = memoTextView.text?.count else {return}
        todoTextfield.layer.borderColor = UIColor.gray700.cgColor
        todoTextfield.setPlaceholderColor(.gray700)
        countToDoCharacterLabel.textColor = .gray700
        countToDoCharacterLabel.text = "\(todotext)/15"
        deadlineTextfieldLabel.layer.borderColor = UIColor.gray700.cgColor
        deadlineTextfieldLabel.textColor = .gray700
        dropdownButton.setImage(ImageLiterals.ToDo.enabledDropdown, for: .normal)
        memoTextView.layer.borderColor = memoTextView.text == "메모를 입력해주세요." ? UIColor.gray200.cgColor : UIColor.gray700.cgColor
        memoTextView.textColor = memoTextView.text == "메모를 입력해주세요." ? UIColor.gray200 : UIColor.gray700
        countMemoCharacterLabel.text = "\(memotext)/1000"
        countMemoCharacterLabel.textColor = .gray700
    }
    
    /// 텍스트 필드에 들어갈 텍스트를 DateFormatter로  변환하는 메서드
    func dateFormat(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        
        return formatter.string(from: date)
    }
    
    /// DatePicker Presnet 하는 메서드
    func showDatePicker(for button: UIButton) {
        bottomSheetVC.modalPresentationStyle = .overFullScreen
        self.present(bottomSheetVC, animated: false, completion: nil)
    }
    
    func todoTextFieldBlankCheck() {
        guard let textEmpty = todoTextfield.text?.isEmpty else { return }
        if textEmpty {
            todoTextfield.layer.borderColor = UIColor.gray200.cgColor
            self.countToDoCharacterLabel.textColor = .gray200
        } else {
            todoTextfield.layer.borderColor = UIColor.gray700.cgColor
            self.countToDoCharacterLabel.textColor = .gray400
        }
    }
    
    func memoTextViewBlankCheck() {
        guard let textEmpty = memoTextView.text?.isEmpty else { return }
        if textEmpty {
            memoTextView.layer.borderColor = UIColor.gray200.cgColor
            self.countMemoCharacterLabel.textColor = .gray200
        } else {
            memoTextView.layer.borderColor = UIColor.gray700.cgColor
            self.countMemoCharacterLabel.textColor = .gray400
        }
    }
    
    func compareDate(userDate: Date) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 32400)
        
        //유저가 입력한 날짜를 스트링으로 바꿈
        let formattedDateString = dateFormatter.string(from: userDate)
        deadlineTextfieldLabel.text = formattedDateString
        
        //유저가 선택한 날짜
        let userPickedDate = userDate
        
        //유저의 위치 날짜
        let today = Date()
        let timezone = TimeZone.autoupdatingCurrent
        
        // 정확한 비교를 위해 시-분-초 절삭한 시간대
        let calendar = Calendar.current
        let deletedUser = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: userPickedDate)
        let deletedToday = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: today)
        
        // 두 날짜 비교
        if let deletedUser = deletedUser, let deletedToday = deletedToday, deletedUser < deletedToday {
            return false
        } else {
            return true
        }
    }
}

// MARK: - Extension

extension ToDoViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 마이투두 - 할일추가 - 1로 픽스
        
        if beforeVC == "our" {
            if navigationBarTitle == "추가" {
                return self.fromOurTodoParticipants.count
            } else {
                return self.manager.count
            }
        }
        else {
            return self.manager.count
        }
        // 조회할때 - isprivate이면 -> 나만보기
        // 조회할때 - isprivate이 false -> 그냥 받은거 뿌려주고 왼쪽 주황색
        
        // 아워투두 - 내가 없음(isowner)
        
        // 아워투두 - 할일추가 - 전체인원나오기
        
        //        return self.manager.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let managerCell = collectionView.dequeueReusableCell(withReuseIdentifier: ToDoManagerCollectionViewCell.identifier, for: indexPath) as? ToDoManagerCollectionViewCell else {return UICollectionViewCell()}
        
        var name = ""
        if beforeVC == "our" {
            if navigationBarTitle == "추가" {
                name = fromOurTodoParticipants[indexPath.row].name
            } else {
                name = manager[indexPath.row].name
            }
        } else {
            name = manager[indexPath.row].name
        }
        
        managerCell.managerButton.isEnabled = true
        managerCell.managerButton.setTitle(name, for: .normal)
        managerCell.managerButton.tag = indexPath.row
        managerCell.managerButton.addTarget(self, action: #selector(didTapToDoManagerButton(_:)), for: .touchUpInside)
        //아워투두 -> 조회
        //다 선택된 옵션
        //마이투두 -> 조회
        //혼자할일 + 라벨
        //아워투두
        if beforeVC == "our" {
            //조회
            if isActivateView == false {
                managerCell.managerButton.isSelected = true
                managerCell.managerButton.setTitleColor(.white000, for: .normal)
                if manager[indexPath.row].isOwner {
                    managerCell.managerButton.backgroundColor = .red500
                    managerCell.managerButton.layer.borderColor = UIColor.red500.cgColor
                } else {
                    managerCell.managerButton.backgroundColor = .gray400
                    managerCell.managerButton.layer.borderColor = UIColor.gray400.cgColor
                }
            } // 추가
            else {
                managerCell.managerButton.backgroundColor = .white000
                managerCell.managerButton.setTitleColor(.gray300, for: .normal)
                managerCell.managerButton.layer.borderColor = UIColor.gray300.cgColor
            }
        }// 마이투두
        else {
            // 조회
            if isActivateView == false {
                managerCell.managerButton.isSelected = true
                // 혼자 할 일
                if data?.secret == true {
                    //설명라벨 세팅
                    if manager[indexPath.row].name == "나만 볼 수 있는 할일이에요" {
                        managerCell.managerButton.isEnabled = false
                        managerCell.managerButton.backgroundColor = .white000
                        managerCell.managerButton.layer.borderColor = UIColor.white000.cgColor
                        
                        managerCell.managerButton.setTitleColor(.gray200, for: .normal)
                    } else {
                        managerCell.managerButton.setImage(ImageLiterals.ToDo.orangeLock, for: .normal)
                        managerCell.managerButton.setTitleColor(.red500, for: .normal)
                        managerCell.managerButton.layer.borderColor = UIColor.red500.cgColor
                        managerCell.managerButton.backgroundColor = .white000
                    }
                } else{
                    managerCell.managerButton.setTitleColor(.white000, for: .normal)
                    if manager[indexPath.row].isOwner { //owner
                        managerCell.managerButton.backgroundColor = UIColor.red500
                        managerCell.managerButton.layer.borderColor = UIColor.red500.cgColor
                    }else {
                        managerCell.managerButton.backgroundColor = UIColor.gray400
                        managerCell.managerButton.layer.borderColor = UIColor.gray400.cgColor
                    }
                }
            }// 추가
            else {
                //설명라벨 세팅
                if manager[indexPath.row].name == "나만 볼 수 있는 할일이에요" {
                    managerCell.managerButton.isEnabled = true
                    managerCell.managerButton.backgroundColor = .white000
                    managerCell.managerButton.layer.borderColor = UIColor.white000.cgColor
                    managerCell.managerButton.setTitleColor(.white000, for: .normal)
                } else {
                    managerCell.managerButton.setImage(ImageLiterals.ToDo.orangeLock, for: .normal)
                    managerCell.managerButton.setTitleColor(.red500, for: .normal)
                    managerCell.managerButton.layer.borderColor = UIColor.red500.cgColor
                    managerCell.managerButton.backgroundColor = .white000
                    managerCell.managerButton.isUserInteractionEnabled = false
                }
            }
        }
        return managerCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension ToDoViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing (_ textView: UITextView) {
        todoTextfield.resignFirstResponder()
        textView.becomeFirstResponder()
        
        if textView.text == memoTextviewPlaceholder {
            textView.text = ""
            textView.textColor = .gray700
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let char = text.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92 {
                return true
            }
        }
        
        if text == "\n" { // 엔터 키 감지
            textView.resignFirstResponder()
            return false
        }
        
        let maxLength = 1000
        let oldText = textView.text ?? "" // 입력하기 전 textField에 표시되어있던 text 입니다.
        let addedText = text // 입력한 text 입니다.
        let newText = oldText + addedText // 입력하기 전 text와 입력한 후 text를 합칩니다.
        let newTextLength = newText.count // 합쳐진 text의 길이 입니다.
        
        if newTextLength <= maxLength {
            return true
        }
        
        //여기는 "곽성ㅈ" 처럼 3번째에 하나라도 뭔가 있으면 위의 If문을 무시하고 넘어온다.
        let lastWordOfOldText = String(oldText[oldText.index(before: oldText.endIndex)]) // 입력하기 전 text의 마지막 글자 입니다.
        let separatedCharacters = lastWordOfOldText.decomposedStringWithCanonicalMapping.unicodeScalars.map{ String($0) } // 입력하기 전 text의 마지막 글자를 자음과 모음으로 분리해줍니다.
        let separatedCharactersCount = separatedCharacters.count // 분리된 자음, 모음의 개수입니다.
        
        //입력되어 있는 마지막 글자의 자음 + 모음 개수가 1개이고, 새로 입력되는 글자가 자음이 아닐 경우 입력이 됨
        // ex)"곽성ㅈ" 에서 입력할 때!
        if separatedCharactersCount == 1 && !addedText.isConsonant {
            return true
        }
        
        //입력되어 있는 마지막 글자의 자음 + 모음 개수가 2개이고, 새로 입력되는 글자가 자음 혹은 모음일 경우 입력이 되도록 함
        // ex) "곽성주" 에서 입력할 때!
        if separatedCharactersCount == 2 {
            return true
        }
        
        //입력되어 있는 마지막 글자의 자음 + 모음 개수가 3개이고, 새로 입력되는 글자가 자음일 경우 입력이 되도록 함, 예를 들어 받침에 자음이 두개 들어가는 경우 밑에서 처리해줘야 됨
        // ex) "곽성준" 에서 입력할 때!
        if separatedCharactersCount == 3 && addedText.isConsonant {
            return true
        }
        return false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = memoTextviewPlaceholder
            textView.textColor = .gray200
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == memoTextView {
            let memoTextViewCount = textView.text.count
            countMemoCharacterLabel.text = "\(memoTextViewCount) / 1000"
            memoTextViewBlankCheck()
            updateSingleButtonState()
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        let text = textView.text ?? ""
        let maxLength = 1000
        
        if text.count > maxLength {
            let startIndex = text.startIndex
            let endIndex = text.index(startIndex, offsetBy: maxLength - 1)
            let fixedText = String(text[startIndex...endIndex])
            textView.text = fixedText
            return
        }
    }
}

extension ToDoViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing (_ textField: UITextField) {
        memoTextView.resignFirstResponder()
        textField.placeholder = ""
        textField.becomeFirstResponder()
        updateSingleButtonState()
    }
    
    /// 상단의 textView Delegate와 같은 로직
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92 {
                return true
            }
        }
        
        let maxLength = 15
        let oldText = textField.text ?? ""
        let addedText = string
        let newText = oldText + addedText
        let newTextLength = newText.count
        if newTextLength <= maxLength {
            return true
        }
        
        let lastWordOfOldText = String(oldText[oldText.index(before: oldText.endIndex)])
        let separatedCharacters = lastWordOfOldText.decomposedStringWithCanonicalMapping.unicodeScalars.map{ String($0) }
        let separatedCharactersCount = separatedCharacters.count //
        if separatedCharactersCount == 1 && !addedText.isConsonant {
            return true
        }
        if separatedCharactersCount == 2 {
            return true
        }
        if separatedCharactersCount == 3 && addedText.isConsonant {
            return true
        }
        return false
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let text = textField.text ?? ""
        let maxLength = 15
        
        if text.count > maxLength {
            let startIndex = text.startIndex
            let endIndex = text.index(startIndex, offsetBy: maxLength - 1)
            let fixedText = String(text[startIndex...endIndex])
            textField.text = fixedText
            return
        }
    }
    
    /// 엔터 키 누르면 키보드 내리는 메서드
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ToDoViewController {
    func updateSingleButtonState() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        let isAllocatorFilled = ((beforeVC == "our") && (buttonIndex.isEmpty == false)) || (beforeVC == "my")
        let isTodoTextFieldEmpty = todoTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let isDateSet = deadlineTextfieldLabel.text != "날짜를 선택해주세요."

        var isEndDateNotPast = true

        guard let date = self.selectedDate else { return }
        isEndDateNotPast = compareDate(userDate: date)

        singleButtonView.currentType = ( !isTodoTextFieldEmpty
                                         && isDateSet
                                         && isEndDateNotPast
                                         && isAllocatorFilled) ? .enabled : .unabled
        

    }
}


extension ToDoViewController: BottomSheetDelegate {
    
    func datePickerDidChanged(date: Date) {
        self.selectedDate = date
        // 두 날짜 비교
        if compareDate(userDate: date) {
            updateSingleButtonState()
        } else {
            DOOToast.show(message: "앞으로 할 일을 등록해주세요!", insetFromBottom: ScreenUtils.getHeight(374))
            singleButtonView.currentType = .unabled
            deadlineTextfieldLabel.layer.borderColor = UIColor.gray200.cgColor
        }
    }
    
    func didSelectDate(date: Date) {
        self.selectedDate = date

        let formattedDate = dateFormat(date: date)
        deadlineTextfieldLabel.text = formattedDate
        deadlineTextfieldLabel.textColor = .gray700
        deadlineTextfieldLabel.layer.borderColor = UIColor.gray700.cgColor
        dropdownButton.setImage(ImageLiterals.ToDo.enabledDropdown, for: .normal)
        
        if compareDate(userDate: date) {
            updateSingleButtonState()
        }
    }
}

extension ToDoViewController: DoubleButtonDelegate {
    func tapEditButton() {
        DOOToast.show(message: "해당 기능은 추후 업데이트 예정이에요 :)", insetFromBottom: ScreenUtils.getHeight(107))
    }
    
    func tapDeleteButton() {
        deleteTodo()
    }
}

extension ToDoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {return CGSize()}
        
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = ScreenUtils.getWidth(4)
        layout.minimumLineSpacing = ScreenUtils.getWidth(4)
        
        if beforeVC == "my" {
            let stringLength = data?.secret == true
            ? manager[indexPath.row].name.size(withAttributes: [NSAttributedString.Key.font : UIFont.pretendard(.detail2_regular)]).width + ScreenUtils.getWidth(12)
            : self.manager[indexPath.row].name.size(withAttributes: [NSAttributedString.Key.font : UIFont.pretendard(.detail2_regular)]).width
            return CGSize(width: stringLength + ScreenUtils.getWidth(24), height: ScreenUtils.getHeight(20))
            
        } else {
            return CGSize(width: ScreenUtils.getWidth(42), height: ScreenUtils.getHeight(20))
        }
    }
}

extension ToDoViewController: ViewControllerServiceable {
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

extension ToDoViewController {
    func getDetailToDoData(todoId: Int) {
        Task {
            do {
                self.data = try await ToDoService.shared.getDetailToDoData(todoId: todoId)
            }
            catch {
                guard let error = error as? NetworkError else { return }
                handleError(error)
            }
        }
    }
    
    func postToDoData() {
        Task {
            do {
                try await ToDoService.shared.postCreateToDo(tripId: tripId, requestBody: saveToDoData)
                self.navigationController?.popViewController(animated: true)
            }
            DOOToast.show(message: "할 일이 추가되었어요.", insetFromBottom: ScreenUtils.getHeight(106))
        }
    }
    
    func deleteTodo() {
        Task {
            do {
                try await ToDoService.shared.deleteTodo(todoId: self.todoId)
                self.navigationController?.popViewController(animated: true)
            }
            DOOToast.show(message: "할 일이 삭제되었어요.", insetFromBottom: ScreenUtils.getHeight(106))
        }
    }
}

extension Date {
    func convertToTimeZone(initTimeZone: TimeZone, timeZone: TimeZone) -> Date {
        let delta = TimeInterval(initTimeZone.secondsFromGMT(for: self) - timeZone.secondsFromGMT(for: self))
        return addingTimeInterval(delta)
    }
}
