//
//  NextContentView.swift
//  FarmChatApp
//
//  Created by nasu shunji on 2021/02/02.
//

import UIKit
import MessageKit
import MessageInputBar
import InputBarAccessoryView
import FirebaseDatabase

class ChatViewController: MessagesViewController, InputBarAccessoryViewDelegate{

    var messageList: [MockMessage] = []
    var databaseRef: DatabaseReference!
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        databaseRef = Database.database().reference()
        DispatchQueue.main.async {
            self.databaseRef.observe(.childAdded, with: { snapshot in
                        if let obj = snapshot.value as? [String : AnyObject], let datas = obj["sample"] as? String {
                            let attributedText = NSAttributedString(string: datas, attributes: [.font: UIFont.systemFont(ofSize: 15),
                                                                                               .foregroundColor: UIColor.white])
                            let message = MockMessage(attributedText: attributedText, sender: self.currentSender(), messageId: UUID().uuidString, date: Date())
                            self.messageList.append(message)
                            //messagelistの最後の追加
                            self.messagesCollectionView.insertSections([self.messageList.count - 1])
                        }
                    })
            // messagesCollectionViewをリロードして
            self.messagesCollectionView.reloadData()
            // 一番下までスクロールする
            self.messagesCollectionView.scrollToLastItem()
        }
        

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self

        messageInputBar.delegate = self
        messageInputBar.sendButton.tintColor = UIColor.lightGray


//        // メッセージ入力欄の左に画像選択ボタンを追加
//        // 画像選択とかしたいときに
//        let items = [
//            makeButton(named: "clip.png").onTextViewDidChange { button, textView in
//                button.tintColor = UIColor.lightGray
//                button.isEnabled = textView.text.isEmpty
//            }
//        ]
//        items.forEach { $0.tintColor = .lightGray }
//        messageInputBar.setStackViewItems(items, forStack: .left, animated: false)
//        messageInputBar.setLeftStackViewWidthConstant(to: 45, animated: false)


        // メッセージ入力時に一番下までスクロール
        //scrollsToBottomOnKeybordBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
    }

//    // ボタンの作成
//    func makeButton(named: String) -> InputBarButtonItem {
//        return InputBarButtonItem()
//            .configure {
//                $0.spacing = .fixed(10)
//                $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
//                $0.setSize(CGSize(width: 30, height: 30), animated: true)
//            }.onSelected {
//                $0.tintColor = UIColor.gray
//            }.onDeselected {
//                $0.tintColor = UIColor.lightGray
//            }.onTouchUpInside { _ in
//                print("Item Tapped")
//        }
//    }
   /* databaseRef = Database.database().reference()
    
    databaseRef.observe(.childAdded, with: { snapshot in
                if let obj = snapshot.value as? [String : AnyObject],  let datas = obj["sample"] {
    func createMessage() -> MockMessage {
            let attributedText = NSAttributedString(string: datas, attributes: [.font: UIFont.systemFont(ofSize: 15),
                                                                               .foregroundColor: UIColor.black])
            return MockMessage(attributedText: attributedText, sender: otherSender(), messageId: UUID().uuidString, date: Date())
        }*/
    func getMessages(){
        
        }
    func createMessage(text: String) -> MockMessage {
            let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15),
                                                                               .foregroundColor: UIColor.black])
            return MockMessage(attributedText: attributedText, sender: otherSender(), messageId: UUID().uuidString, date: Date())
        }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension ChatViewController: MessagesDataSource {

    func currentSender() -> SenderType {
        return Sender(senderId: "123", displayName: "自分")
    }

    func otherSender() -> SenderType {
        return Sender(senderId: "456", displayName: "知らない人")
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }

    // メッセージの上に文字を表示
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(
                string: MessageKitDateFormatter.shared.string(from: message.sentDate),
                attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                             NSAttributedString.Key.foregroundColor: UIColor.darkGray]
            )
        }
        return nil
    }

    // メッセージの上に文字を表示（名前）
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }

    // メッセージの下に文字を表示（日付）
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
}

// メッセージのdelegate
extension ChatViewController: MessagesDisplayDelegate {

    // メッセージの色を変更（デフォルトは自分：白、相手：黒）
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }

    // メッセージの背景色を変更している（デフォルトは自分：緑、相手：グレー）
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ?
            UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1) :
            UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }

    // メッセージの枠にしっぽを付ける
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }

    // アイコンをセット
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        // message.sender.displayNameとかで送信者の名前を取得できるので
        // そこからイニシャルを生成するとよい
        let avatar = Avatar(initials: "人")
        avatarView.set(avatar: avatar)
    }
}


// 各ラベルの高さを設定（デフォルト0なので必須）
extension ChatViewController: MessagesLayoutDelegate {

    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 { return 10 }
        return 0
    }

    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
}

extension ChatViewController: MessageCellDelegate {
    // メッセージをタップした時の挙動
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
}

extension ChatViewController: MessageInputBarDelegate{
    // メッセージ送信ボタンをタップした時の挙動
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String){
        for component in inputBar.inputTextView.components {
            if component is String {
                
                view.endEditing(true)
                let datas = ["sample": component]
                databaseRef.childByAutoId().setValue(datas)
                

            } /*else if let image = component as? UIImage {
                
                let imageMessage = MockMessage(image: image, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                messageList.append(imageMessage)
                messagesCollectionView.insertSections([messageList.count - 1])
            }*/
        }
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToLastItem()
    }
}
