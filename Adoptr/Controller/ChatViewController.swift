//
//  ChatViewController.swift
//  Adoptr
//
//  Created by Alexandra Negru on 07/05/2022.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {
    private var messages = [Message]()
    public var isNewConversation = false
    public var otherUserEmail: String = ""
    public var otherUserName: String = ""
    public var conversationId: String = ""
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    private var sender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        return Sender(senderId: safeEmail,
               displayName: "Me")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        listenForMessages(id: conversationId, shouldScrollToBottom: true)
    }
    
    private func listenForMessages(id: String, shouldScrollToBottom: Bool) {
        DatabaseManager.shared.getAllMessagesForConversation(with: id, completion: { [weak self] result in
            print("Conversation ID")
            print(self?.conversationId)
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                self?.isNewConversation = false
                self?.messages = messages
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToBottom {
                        print("scroll to bottom")
                        self?.messagesCollectionView.scrollToItem(at: IndexPath(row: 0, section: (self?.messages.count)! - 1), at: .top, animated: true)
                    }
                }
            case .failure(let error):
                self?.isNewConversation = true
                print("failed to get messages: \(error)")
            }
        })
    }
    

}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let sender = self.sender,
              let messageId = createMessageId() else {
            return
        }
        
        let message = Message(sender: sender,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .text(text))
        print("MESSAGE -----------------")
        print(message)
        print("Is new convo?")
        print(isNewConversation)
        if isNewConversation {
            print("Conversatie noua")
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, otherUserName: otherUserName, firstMessage: message, completion: { [weak self] success, conversationId in
                if success {
                    print("message sent")
                    self?.isNewConversation = false
                    self?.messageInputBar.inputTextView.text = nil
                    self?.conversationId = conversationId
                    self?.listenForMessages(id: conversationId,shouldScrollToBottom: true)
                } else {
                    print("failed to send")
                }
            })
        } else {
            print("Sending message....")
            print(self.conversationId)
            DatabaseManager.shared.sendMessage(to: self.conversationId, otherUserEmail: otherUserEmail, otherUserName: otherUserName, newMessage: message, completion: { success in
                if success {
                    self.messageInputBar.inputTextView.text = nil
                    print("message sent")
                } else {
                    print("failed to send")
                }
                
            })
        }
    }
    
    private func createMessageId() -> String? {
        return NSUUID().uuidString
    }

}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        if let sender = self.sender {
            return sender
        }
        fatalError("Sender is nil")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageTopLabelAttributedText(
      for message: MessageType,
      at indexPath: IndexPath
    ) -> NSAttributedString? {
      let name = message.sender.displayName
      return NSAttributedString(
        string: name,
        attributes: [
          .font: UIFont.preferredFont(forTextStyle: .caption1),
          .foregroundColor: UIColor(white: 0.3, alpha: 1)
        ])
    }
    
    func footerViewSize(
      for message: MessageType,
      at indexPath: IndexPath,
      in messagesCollectionView: MessagesCollectionView
    ) -> CGSize {
      return CGSize(width: 0, height: 8)
    }

    // 2
    func messageTopLabelHeight(
      for message: MessageType,
      at indexPath: IndexPath,
      in messagesCollectionView: MessagesCollectionView
    ) -> CGFloat {
      return 20
    }
    
    func backgroundColor(
      for message: MessageType,
      at indexPath: IndexPath,
      in messagesCollectionView: MessagesCollectionView
    ) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor(named: K.accentColor)! : UIColor.systemGray6
    }

    // 2
    func shouldDisplayHeader(
      for message: MessageType,
      at indexPath: IndexPath,
      in messagesCollectionView: MessagesCollectionView
    ) -> Bool {
      return false
    }

    // 3
    func configureAvatarView(
      _ avatarView: AvatarView,
      for message: MessageType,
      at indexPath: IndexPath,
      in messagesCollectionView: MessagesCollectionView
    ) {
      avatarView.isHidden = true
    }

    // 4
    func messageStyle(
      for message: MessageType,
      at indexPath: IndexPath,
      in messagesCollectionView: MessagesCollectionView
    ) -> MessageStyle {
      let corner: MessageStyle.TailCorner =
        isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
      return .bubbleTail(corner, .curved)
    }
    
    
}
