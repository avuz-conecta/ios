// SPDX-FileCopyrightText: Nextcloud GmbH
// SPDX-FileCopyrightText: 2019 Marino Faggiana
// SPDX-FileCopyrightText: 2019 Philippe Weidmann
// SPDX-License-Identifier: GPL-3.0-or-later

import UIKit

private enum IntroLayout {
    static let backgroundColor = UIColor(red: 241.0 / 255.0, green: 241.0 / 255.0, blue: 241.0 / 255.0, alpha: 1.0) // #f1f1f1
    static let foregroundColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)    // #333333
    static let buttonColor: UIColor = .black
    static let buttonTextColor: UIColor = .white
    static let folderSizePhone: CGFloat = 140
    static let folderSizePad: CGFloat = 220
    static let titleSizePhone: CGFloat = 18
    static let titleSizePad: CGFloat = 24
    static let buttonHeight: CGFloat = 50
    static let horizontalMargin: CGFloat = 32
    static let folderToTitleGap: CGFloat = 24
    static let titleToButtonGap: CGFloat = 40
}

class NCIntroViewController: UIViewController {
    // Controller
    var controller: NCMainTabBarController?

    private var isPad: Bool { traitCollection.userInterfaceIdiom == .pad }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        overrideUserInterfaceStyle = .light
        view.backgroundColor = IntroLayout.backgroundColor

        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithTransparentBackground()
        navBarAppearance.shadowColor = .clear
        navBarAppearance.shadowImage = UIImage()
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.tintColor = IntroLayout.foregroundColor
        navigationController?.view.backgroundColor = IntroLayout.backgroundColor
        navigationController?.overrideUserInterfaceStyle = .light

        if !NCManageDatabase.shared.getAllTableAccount().isEmpty {
            let cancel = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(actionCancel(_:)))
            cancel.tintColor = IntroLayout.foregroundColor
            navigationItem.rightBarButtonItem = cancel
        }

        buildLayout()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }

    // MARK: - Layout

    private func buildLayout() {
        let folder = UIImageView()
        folder.translatesAutoresizingMaskIntoConstraints = false
        folder.contentMode = .scaleAspectFit
        folder.image = UIImage(named: "folderIntro")?.withRenderingMode(.alwaysTemplate)
        folder.tintColor = IntroLayout.foregroundColor

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.numberOfLines = 0
        title.textAlignment = .center
        title.textColor = IntroLayout.foregroundColor
        title.font = .systemFont(ofSize: isPad ? IntroLayout.titleSizePad : IntroLayout.titleSizePhone, weight: .regular)
        title.text = NSLocalizedString("_intro_title_", value: "Armazene, organize e compartilhe arquivos no Drive", comment: "")

        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = IntroLayout.buttonColor
        button.setTitleColor(IntroLayout.buttonTextColor, for: .normal)
        button.setTitle(NSLocalizedString("_log_in_", comment: ""), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = IntroLayout.buttonHeight / 2
        button.accessibilityIdentifier = "login"
        button.addTarget(self, action: #selector(login(_:)), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [folder, title])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = IntroLayout.folderToTitleGap

        view.addSubview(stack)
        view.addSubview(button)

        let folderSize = isPad ? IntroLayout.folderSizePad : IntroLayout.folderSizePhone

        NSLayoutConstraint.activate([
            folder.widthAnchor.constraint(equalToConstant: folderSize),
            folder.heightAnchor.constraint(equalToConstant: folderSize),

            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: IntroLayout.horizontalMargin),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -IntroLayout.horizontalMargin),

            title.widthAnchor.constraint(lessThanOrEqualToConstant: isPad ? 480 : 320),

            button.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: IntroLayout.titleToButtonGap),
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: IntroLayout.horizontalMargin),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -IntroLayout.horizontalMargin),
            button.heightAnchor.constraint(equalToConstant: IntroLayout.buttonHeight)
        ])
    }

    // MARK: - Action

    @objc func actionCancel(_ sender: Any?) {
        dismiss(animated: true) { }
    }

    @objc func login(_ sender: Any) {
        if let viewController = UIStoryboard(name: "NCLogin", bundle: nil).instantiateViewController(withIdentifier: "NCLogin") as? NCLogin {
            viewController.controller = self.controller
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

extension UINavigationController {
    open override var childForStatusBarStyle: UIViewController? {
        return topViewController?.childForStatusBarStyle ?? topViewController
    }
}
