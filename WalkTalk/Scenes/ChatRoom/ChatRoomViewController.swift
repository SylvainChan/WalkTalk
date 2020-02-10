//
//  ChatRoomViewController.swift
//  WalkTalk
//
//  Created by Sylvain Chan on 9/2/2020.
//  Copyright (c) 2020 Sylvain. All rights reserved.
//

/*
 There should have no extra businees logic in view controller
 - control view state
 - receive view models and place it at right views
 
 - for interaction, create request and send to interactor
 */

import UIKit
import MultipeerConnectivity

// MARK: - Display logic, receive view model from presenter and present
protocol ChatRoomDisplayLogic: class {
    
    func prepareNavigationItem()
    func quitChat()
    func displaySearchPeer()
    func dismissViewController(viewModel: ChatRoom.ViewModel.DismissViewController)
    func displayPredefinedMessage(viewModel: ChatRoom.ViewModel.PredefinedMessage)
    func displayEmptyInputField()
    func displayBottom()
    func displayLatestMessage(messages: [ChatRoom.Response.IncomingMessage.ClassifiedMessage])
    func displayNavMessage(viewModel: ChatRoom.ViewModel.NavigationMessage)
    func displayUserInteractiveElements(viewModel: ChatRoom.ViewModel.UserInteractiveElements)
}

// MARK: - View Controller body
class ChatRoomViewController: ViewController, ChatRoomDisplayLogic {
    
    // VIP
    var interactor: ChatRoomBusinessLogic?
    var router: (NSObjectProtocol & ChatRoomRoutingLogic & ChatRoomDataPassing)?
    
    // state
    private var messages: [ChatRoom.Response.IncomingMessage.ClassifiedMessage] = []
    private var predefinedMessageButtons: [UIButton] = []
    
    // view elements
    @IBOutlet weak var viewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var predefinedMessageStackView: UIStackView!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var sendbutton: UIButton!
    
    // Cell
    enum TableViewCell: String, TableViewCellConfiguration {
        case myText = "MyMessageTableViewCell"
        case theirText = "TheirMessageTableViewCell"
        case notice = "NoticeTableViewCell"
    }
}

// MARK: - View Lifecycle
extension ChatRoomViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveTokenUpdateNotification), name: NSNotification.Name.init(WTNotification.pushTokenUpdated.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // static view preparation
        self.prepareNavigationItem()
        self.interactor?.requestHandleViewInit()
        
        // table view
        self.messageTableView.estimatedRowHeight = UITableView.automaticDimension
        self.messageTableView.separatorStyle = .none
        self.messageTableView.bounces = true
        self.messageTableView.delegate = self
        self.messageTableView.dataSource = self
        self.messageTableView.allowsSelection = false
        self.messageTableView.register(TableViewCell.myText.nib, forCellReuseIdentifier: TableViewCell.myText.reuseId)
        self.messageTableView.register(TableViewCell.theirText.nib, forCellReuseIdentifier: TableViewCell.theirText.reuseId)
        self.messageTableView.register(TableViewCell.notice.nib, forCellReuseIdentifier: TableViewCell.notice.reuseId)
    }
    
    // setup nav bar items
    func prepareNavigationItem() {
        let quitButton = UIBarButtonItem.init(title: "Exit", style: .plain, target: self, action: #selector(self.barBackButtonDidPress))
        self.navigationItem.leftBarButtonItems = [quitButton]
        
        let searchButton = UIBarButtonItem.init(title: "Search", style: .plain, target: self, action: #selector(self.barSearchButtonDidPress))
        self.navigationItem.rightBarButtonItems = [searchButton]
    }
}

// MARK: - Table view
extension ChatRoomViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = self.messages[indexPath.row]
        
        switch message {
        case let .myText(_, sender, message):
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.myText.reuseId, for: indexPath) as! MyMessageTableViewCell
            
            cell.nameLabel.text = "You"
            cell.nameLabel.textColor = sender.color
            cell.messageLabel.text = message
            
            return cell
            
        case let .text(_, sender, message):
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.theirText.reuseId, for: indexPath) as! TheirMessageTableViewCell
            
            cell.nameLabel.text = sender.name
            cell.nameLabel.textColor = sender.color
            cell.messageLabel.text = message
            
            return cell
            
        case let .newJoiner(message), let .leaver(message):
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.notice.reuseId, for: indexPath) as! NoticeTableViewCell
            
            cell.noticeLabel.text = message
            
            return cell
            
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
}

// MARK: - User interaction
extension ChatRoomViewController {
    @objc func barBackButtonDidPress() {
        self.interactor?.requestHandleBarBackButtonDidPress()
    }
    
    @objc func barSearchButtonDidPress() {
        self.interactor?.requestHandleBarSearchButtonDidPress()
    }
    
    @IBAction func buttonDidPress(_ sender: UIButton) {
        switch sender {
        case self.sendbutton:
            self.interactor?.requestHandleSendAction(request: ChatRoom.Request.SendAction(textFieldText: self.inputTextField.text))
        default:
            if let idx = self.predefinedMessageButtons.firstIndex(of: sender) {
                self.interactor?.requestHandlePredefinedMessageDidSelect(request: ChatRoom.Request.PredefinedMessageSelect(index: idx))
            }
        }
    }
}

// MARK: - View routing
extension ChatRoomViewController {
    
    func quitChat() {
        self.router?.routeBack()
    }
    
    func displaySearchPeer() {
        self.router?.routeToMCBrowser()
    }
    
    func dismissViewController(viewModel: ChatRoom.ViewModel.DismissViewController) {
        viewModel.viewcontroller.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Generate view model display
extension ChatRoomViewController {
    func displayPredefinedMessage(viewModel: ChatRoom.ViewModel.PredefinedMessage) {
        self.predefinedMessageButtons.removeAll()
        
        for string in viewModel.all {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle(string, for: .normal)
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.systemBlue.cgColor
            button.layer.cornerRadius = 15
            
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
            
            button.addTarget(self, action: #selector(self.buttonDidPress(_:)), for: .touchUpInside)
            
            self.predefinedMessageButtons.append(button)
            self.predefinedMessageStackView.addArrangedSubview(button)
        }
    }
    
    func displayUserInteractiveElements(viewModel: ChatRoom.ViewModel.UserInteractiveElements) {
        DispatchQueue.main.async {
            self.sendbutton.isUserInteractionEnabled = viewModel.enable
            self.predefinedMessageStackView.isUserInteractionEnabled = viewModel.enable
            self.inputTextField.isUserInteractionEnabled = viewModel.enable
        }
    }
}

// MARK: - Message display handle
extension ChatRoomViewController {
    func displayEmptyInputField() {
        DispatchQueue.main.async {
            self.inputTextField.text = nil
        }
    }
    
    func displayLatestMessage(messages: [ChatRoom.Response.IncomingMessage.ClassifiedMessage]) {
        DispatchQueue.main.async {
            self.messages = messages
            self.messageTableView.reloadData()
            self.messageTableView.layoutIfNeeded()
            
            if self.messageTableView.contentSize.height > self.messageTableView.bounds.height {
                self.displayBottom()
            }
        }
    }
    
    // Scroll the chat view to bottom (latest message)
    func displayBottom() {
        DispatchQueue.main.async {
            self.messageTableView.setContentOffset(CGPoint(
            x: 0,
            y: self.messageTableView.contentSize.height - self.messageTableView.bounds.height), animated: true)
        }
    }
    
    func displayNavMessage(viewModel: ChatRoom.ViewModel.NavigationMessage) {
        DispatchQueue.main.async {
            self.title = viewModel.message
        }
    }
}

// MARK: - notification
extension ChatRoomViewController {
    @objc private func didReceiveTokenUpdateNotification() {
        self.interactor?.requestHandleTokenUpdateNotification()
    }
    
    // Correct the input view frame so as to not blocked by keyboard
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height - self.view.safeAreaInsets.bottom
            self.viewBottomConstraint.constant = keyboardHeight
            
            UIView.animate(withDuration: 0.24) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    // reset input view to normal
    @objc func keyboardWillHide(_ notification: Notification) {
        self.viewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.24) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - browser view delegate
extension ChatRoomViewController: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true) {
            self.interactor?.requestHandleMCSearcherFinish(request: ChatRoom.Request.MCSearcher(viewcontroller: browserViewController))
        }
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true) {
            self.interactor?.requestHandleMCSearcherFinish(request: ChatRoom.Request.MCSearcher(viewcontroller: browserViewController))
        }
    }
}
