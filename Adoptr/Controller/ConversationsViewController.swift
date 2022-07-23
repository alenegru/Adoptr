//
//  ConversationsViewController.swift
//  Adoptr
//
//  Created by Alexandra Negru on 07/05/2022.
//

import UIKit
import Firebase

class ConversationsViewController: UIViewController {
    @IBOutlet weak var conversationsView: UITableView!
    
    private var conversationsId: [String] = []
    
    var conversations = [Conversation]()
    
    private var result: [String: String] = [:]
    
    private var model: Conversation?
    
    private let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "No conversations yet"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noConversationsLabel)
        
        conversationsView.isHidden = true

        conversationsView.register(UINib(nibName: K.conversationCellNibname, bundle: nil), forCellReuseIdentifier: K.conversationCellIdentifier)
        conversationsView.delegate = self
        conversationsView.dataSource = self
        startListeningForConversations()
//        startListeningForConversations2()
        
        conversationsView.tableFooterView = UIView() 
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noConversationsLabel.frame = CGRect(x: 10,
                                            y: (view.bounds.height-100)/2,
                                            width: view.bounds.width-20,
                                            height: 100)
    }
    
    private func startListeningForConversations() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        print(safeEmail)
        DatabaseManager.shared.getAllConversations(for: safeEmail, completion: {[weak self] result in
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    print("no convos")
                    self?.conversationsView.isHidden = true
                    self?.noConversationsLabel.isHidden = false
                    return
                }
                print("got conversation")
                self?.noConversationsLabel.isHidden = true
                self?.conversationsView.isHidden = false
                self?.conversations = conversations
                DispatchQueue.main.async {
                    print("reload data")
                    self?.conversationsView.reloadData()
                }
            case .failure(let error):
                self?.conversationsView.isHidden = true
                self?.noConversationsLabel.isHidden = false
                print("failed to get convos: \(error)")
            }
        })
    }
    
//    private func startListeningForConversations2() {
//        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
//            return
//        }
//
//        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
//        print(safeEmail)
//        DatabaseManager.shared.getAllConversations2OnlyId(for: safeEmail, completion: {[weak self] result in
//            switch result {
//            case .success(let conversations):
//                guard !conversations.isEmpty else {
//                    print("no convos")
//                    self?.conversationsView.isHidden = true
//                    self?.noConversationsLabel.isHidden = false
//                    return
//                }
//                print("got conversationssss")
//                self?.noConversationsLabel.isHidden = true
//                self?.conversationsView.isHidden = false
//                self?.conversationsId = conversations
//                guard let strongSelf = self else {
//                    return
//                }
//
//                print("IDS FOR CONVERSATIONS")
//                print(conversations)
//
//                DatabaseManager.shared.getConversationsById(for: conversations, completion: { result in
//                    switch result {
//                        case .success(let conversations):
//                            print("ce pula mea se intampla")
//                            print(conversations)
//                            self?.conversations = conversations
//                            DispatchQueue.main.async {
//                                print("reload data")
//                                self?.conversationsView.reloadData()
//                            }
//                    case .failure(let error):
//                        print("failed to get convo \(error)")
//                    }
//                })
//            case .failure(let error):
//                self?.conversationsView.isHidden = true
//                self?.noConversationsLabel.isHidden = false
//                print("failed to get convos: \(error)")
//            }
//        })
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get a reference to the second view controller
        let chatViewController = segue.destination as! ChatViewController
        if model != nil {
            chatViewController.conversationId = model?.id ?? ""
            chatViewController.title = model?.otherUserName
            chatViewController.otherUserEmail = model?.otherUserEmail ?? ""
            chatViewController.otherUserName = model?.otherUserName ?? ""
        }
    }
}

extension ConversationsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning incomplete implementation, return the number of rows
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        print("Id: \(model.id)")
        print("latest message text: \(model.latestMessage.text)")
        print(conversations.count)
        let cell = tableView.dequeueReusableCell(withIdentifier: K.conversationCellIdentifier, for: indexPath) as! ConversationTableViewCell
        cell.latestMessageLabel.text = model.latestMessage.text
        cell.nameLabel.text = model.otherUserName
        let path = "images/\(model.otherUserEmail)/\(model.otherUserEmail)_profile_picture.png"
        print("Path for other user photo: \(path)")
        StorageManager.shared.downloadURL(for: path, completion: { result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    cell.profilePic.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print("Failed to get download url: \(error)")
            }
        })
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        model = conversations[indexPath.row]
        self.performSegue(withIdentifier: K.chatSegue, sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

}

