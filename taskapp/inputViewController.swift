//
//  inputViewController.swift
//  taskapp
//
//  Created by 由上博之 on 2021/05/24.
//

import UIKit
import RealmSwift
import UserNotifications

class inputViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    let realm = try! Realm()
    var task: Task!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
          //タップジェスチャーによるキーボード非表示のインスタンスを作成
        self.view.addGestureRecognizer(tapGesture)
          //ビューにタップジェスチャーを設定する。
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        categoryTextField.text = task.category
        datePicker.date = task.date
          //ViewControllerから移動したtask内のデータを表示する。
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
          //キーボードを閉じる
    }
    
    override func viewWillDisappear(_ animated: Bool) {
          //遷移元に戻る際にタスクの内容をデータベースに保存する
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.category = self.categoryTextField.text!
            self.task.date = self.datePicker.date
              //入力された内容をtaskに書き込む
            self.realm.add(self.task, update: .modified)
              //realmへのデータの更新
        }
        setNotification(task: task)
        super.viewWillDisappear(animated)
    }
    
    func setNotification(task: Task) {
          //ローカル通知内容を設定
        let content = UNMutableNotificationContent()
        
        if task.title == ""{
            content.title = "（タイトルなし）"
    } else {
        content.title = task.title
    }
        if task.category == ""{
            content.body = "（カテゴリなし）"
        } else {
            content.body = task.category
        }
        content.sound = UNNotificationSound.default
          //プッシュ通知の音
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month,.day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in print(error ?? "ローカル通知登録　OK")}
        center.getPendingNotificationRequests{(requests: [UNNotificationRequest]) in for request in requests {
            print("/----------")
            print(request)
            print("----------/")
        }
        }
    }
}
