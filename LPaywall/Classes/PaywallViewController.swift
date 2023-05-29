//
//  PaywallViewController.swift
//  SleepSentry
//
//  Created by Selina on 18/5/2023.
//

import UIKit
import Foundation
import SnapKit

public extension PaywallViewController {
    struct PaywallListItem {
        let image: UIImage
        let text: String
        let tintColor: UIColor
    }
}

public protocol PaywallViewControllerDelegate: NSObject {
    func paywallControllerDidTapBuyBtn(_ sender: PaywallViewController)
    func paywallControllerDidTapRestoreBtn(_ sender: PaywallViewController)
}

public class PaywallViewController: UIViewController {
    public weak var delegate: PaywallViewControllerDelegate?
    public var backgroundColor: UIColor = .systemBackground
    public var themeColor: UIColor = .orange
    
    public lazy var iconImageView: UIImageView = {
        let view = UIImageView(image: appIcon)
        view.clipsToBounds = true
        view.layer.cornerRadius = cornerRadius
        return view
    }()
    
    public lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = PaywallViewController.fontMedium(size: 17)
        view.textColor = .label
        view.text = self.mainText
        return view
    }()
    
    public lazy var descLabel: UILabel = {
        let view = UILabel()
        view.font = PaywallViewController.fontLight(size: 15)
        view.textColor = .secondaryLabel
        view.numberOfLines = 0
        view.textAlignment = .center
        view.text = self.descText
        return view
    }()
    
    public lazy var buyBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setBackgroundImage(PaywallViewController.imageByColor(themeColor), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = PaywallViewController.fontMedium(size: 17)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = cornerRadius
        btn.isEnabled = false
        btn.setTitle("", for: .normal)
        btn.addTarget(self, action: #selector(onBuyBtnAction), for: .touchUpInside)
        return btn
    }()
    
    public lazy var restoreBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitleColor(.systemGray, for: .normal)
        btn.titleLabel?.font = PaywallViewController.fontLight(size: 15)
        btn.setTitle(restoreBtnTitle, for: .normal)
        btn.isEnabled = false
        btn.addTarget(self, action: #selector(onRestoreBtnAction), for: .touchUpInside)
        return btn
    }()
    
    private lazy var listView: ListView = {
        let view = ListView(items: listItem)
        return view
    }()
    
    public lazy var termsBtn: UIButton = {
        let view = UIButton(type: .custom)
        view.setTitle("Terms", for: .normal)
        view.setTitleColor(themeColor, for: .normal)
        view.titleLabel?.font = PaywallViewController.fontLight(size: 15)
        
        view.addTarget(self, action: #selector(onTermsBtnAction), for: .touchUpInside)
        return view
    }()
    
    public lazy var privacyBtn: UIButton = {
        let view = UIButton(type: .custom)
        view.setTitle("Privacy", for: .normal)
        view.setTitleColor(themeColor, for: .normal)
        view.titleLabel?.font = PaywallViewController.fontLight(size: 15)
        
        view.addTarget(self, action: #selector(onPrivacyBtnAction), for: .touchUpInside)
        return view
    }()
    
    public lazy var andLabel: UILabel = {
        let view = UILabel()
        view.text = "&"
        view.textColor = .secondaryLabel
        view.font = PaywallViewController.fontLight(size: 15)
        return view
    }()
    
    public var naviTitle: String = "Upgrade" {
        didSet {
            self.title = naviTitle
        }
    }
    public var closeBtnText: String = "Done" {
        didSet {
            if let item = self.navigationItem.leftBarButtonItem {
                item.title = closeBtnText
            }
        }
    }
    public var appIcon: UIImage?
    public var mainText: String = ""
    public var descText: String = ""
    public var listItem: [PaywallListItem] = []
    public var termsURL: String = ""
    public var privacyURL: String = ""
    public var restoreBtnTitle: String = "Restore Purchase"
    public var cornerRadius: CGFloat = 16
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        isModalInPresentation = true
        modalPresentationStyle = .formSheet
        initNaviItem()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initNaviItem() {
        self.title = naviTitle
        let doneBtn = UIBarButtonItem(title: closeBtnText, style: .done, target: self, action: #selector(onCloseBtnAction))
        self.navigationItem.leftBarButtonItem = doneBtn
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        initViews()
    }
    
    private func initViews() {
        view.backgroundColor = backgroundColor
        
        view.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconImageView.snp.bottom).offset(15)
        }
        
        view.addSubview(descLabel)
        descLabel.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.right.equalTo(-12)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
        }
        
        view.addSubview(restoreBtn)
        restoreBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
        
        view.addSubview(buyBtn)
        buyBtn.snp.makeConstraints { make in
            if PaywallViewController.isiPad() {
                make.centerX.equalToSuperview()
                make.width.equalTo(view.snp.width).multipliedBy(0.8)
            } else {
                make.left.equalTo(12)
                make.right.equalTo(-12)
            }
            
            make.height.equalTo(50)
            make.bottom.equalTo(restoreBtn.snp.top).offset(-10)
        }
        
        view.addSubview(andLabel)
        andLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(buyBtn.snp.top).offset(-10)
        }
        
        view.addSubview(termsBtn)
        termsBtn.snp.makeConstraints { make in
            make.centerY.equalTo(andLabel)
            make.right.equalTo(andLabel.snp.left).offset(-5)
        }
        
        view.addSubview(privacyBtn)
        privacyBtn.snp.makeConstraints { make in
            make.centerY.equalTo(andLabel)
            make.left.equalTo(andLabel.snp.right).offset(5)
        }
        
        view.addSubview(listView)
        listView.snp.makeConstraints { make in
            make.top.equalTo(descLabel.snp.bottom).offset(10)
            make.bottom.equalTo(andLabel.snp.top).offset(-10)
            
            if PaywallViewController.isiPad() {
                make.centerX.equalToSuperview()
                make.width.equalTo(view.snp.width).multipliedBy(0.8)
            } else {
                make.left.equalTo(12)
                make.right.equalTo(-12)
            }
        }
    }
}

public extension PaywallViewController {
    /// call this method will update `buyBtn` and set buttons enabled.
    func updateProductInfo(_ title: String) {
        buyBtn.setTitle(title, for: .normal)
        updateBtnEnabled(enabled: true)
    }
    
    func buyCompleted(titleOnBuyButton: String) {
        updateBtnEnabled(enabled: false)
        buyBtn.setTitle(titleOnBuyButton, for: .normal)
    }
    
    func wrapWithNavi() -> UINavigationController {
        let naviVC = UINavigationController(rootViewController: self)
        naviVC.modalPresentationStyle = .formSheet
        return naviVC
    }
}

extension PaywallViewController {
    
    public override var shouldAutorotate: Bool {
        return true
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if PaywallViewController.isiPad() {
            return .all
        } else {
            return .portrait
        }
    }
    
    private func updateBtnEnabled(enabled: Bool) {
        restoreBtn.isEnabled = enabled
        buyBtn.isEnabled = enabled
    }
    
    @objc private func onCloseBtnAction() {
        presentingViewController?.dismiss(animated: true)
    }
    
    @objc private func onBuyBtnAction() {
        delegate?.paywallControllerDidTapBuyBtn(self)
    }
    
    @objc private func onRestoreBtnAction() {
        delegate?.paywallControllerDidTapRestoreBtn(self)
    }
    
    @objc private func onTermsBtnAction() {
        if termsURL.isEmpty {
            return
        }
        
        if let url = URL(string: termsURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc private func onPrivacyBtnAction() {
        if privacyURL.isEmpty {
            return
        }
        
        if let url = URL(string: privacyURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Components
extension PaywallViewController {
    private class ListViewCell: UITableViewCell {
        static let inset: CGSize = CGSizeMake(12, 9)
        static let iconWidth: CGFloat = 23
        
        private lazy var iconImageView: UIImageView = {
            let view = UIImageView()
            view.clipsToBounds = true
            view.contentMode = .scaleAspectFit
            return view
        }()
        
        private lazy var titleLabel: UILabel = {
            let view = UILabel()
            view.numberOfLines = 0
            view.font = PaywallViewController.fontMedium(size: 15)
            view.textColor = .label
            return view
        }()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            setup()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setup() {
            backgroundColor = .clear
            contentView.backgroundColor = .clear
            
            contentView.addSubview(iconImageView)
            iconImageView.snp.makeConstraints { make in
                make.left.equalTo(ListViewCell.inset.width)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(ListViewCell.iconWidth)
            }
            
            contentView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { make in
                make.left.equalTo(ListViewCell.iconWidth + ListViewCell.inset.width * 2)
                make.centerY.equalToSuperview()
                make.right.equalTo(-ListViewCell.inset.width)
            }
        }
        
        func config(_ item: PaywallListItem) {
            iconImageView.image = item.image
            titleLabel.text = item.text
            iconImageView.tintColor = item.tintColor
        }
        
        class func height(forString string: String, width: CGFloat) -> CGFloat {
            let maxWidth = width - ListViewCell.inset.width * 2 - ListViewCell.iconWidth - ListViewCell.inset.width
            if maxWidth <= 0 || string.isEmpty {
                return 0
            }
            
            let constraintRect = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
            let boundingBox = string.boundingRect(
                with: constraintRect,
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [.font: PaywallViewController.fontMedium(size: 15)],
                context: nil
            )
            return boundingBox.height + ListViewCell.inset.height * 2
        }
    }
    
    private class ListView: UIView, UITableViewDelegate, UITableViewDataSource {
        private let items: [PaywallListItem]
        
        private lazy var tableView: UITableView = {
            let view = UITableView(frame: bounds, style: .plain)
            view.delegate = self
            view.dataSource = self
            view.backgroundColor = .clear
            view.alwaysBounceVertical = false
            view.separatorStyle = .none
            view.register(ListViewCell.self, forCellReuseIdentifier: "ListViewCell")
            return view
        }()
        
        init(items: [PaywallListItem]) {
            self.items = items
            super.init(frame: .zero)
            setup()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setup() {
            backgroundColor = .clear
            addSubview(tableView)
            tableView.snp.makeConstraints { make in
                make.edges.equalTo(0)
            }
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return items.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let item = items[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ListViewCell") as! ListViewCell
            cell.config(item)
            return cell
        }
        
        func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
            return false
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            let item = items[indexPath.row]
            return ListViewCell.height(forString: item.text, width: tableView.bounds.width)
        }
    }
}

// MARK: - Helper
extension PaywallViewController {
    class func isiPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    class func fontMedium(size: CGFloat = 16) -> UIFont {
        return UIFont(name: "Avenir-Medium", size: size)!
    }
    
    class func fontLight(size: CGFloat = 14) -> UIFont {
        return UIFont(name: "Avenir-Light", size: size)!
    }
    
    class func fontBold(size: CGFloat = 20) -> UIFont {
        return UIFont(name: "Avenir-Black", size: size)!
    }
    
    class func imageByColor(_ color: UIColor) -> UIImage? {
        let size = CGSize(width: 1, height: 1)
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill([rect])
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}
