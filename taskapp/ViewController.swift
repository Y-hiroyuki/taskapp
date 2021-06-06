//
//  ViewController.swift
//  taskapp
//
//  Created by 由上博之 on 2021/05/24.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var search: UISearchBar!
    
    let realm = try! Realm()
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    var task : Task!
      //objectsで一覧を取得、"date"でソート分けして、昇順に並べる
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        search.delegate = self
        let tapGesture = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return taskArray.count
          //既に入力済みのデータ数を返す
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
          //キューからデータを取り出す。スクロール時のパフォーマンスの低下を避けるため、cellの再利用をする。
        
        let task = taskArray[indexPath.row]
          //配列：indexPath[section,row]を全て実行
        cell.textLabel?.text = task.category
          //セルに値を設定：『タイトル』
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
          //DataFormatterのインタンスを作成
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
          //セルに値を設定：『日付』
        
        return cell
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        search.endEditing(true)
        let searchResult = searchBar.text
        if searchResult == "" {
            taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
        } else {
        taskArray = try! Realm().objects(Task.self).filter("category contains[c] '\(searchResult!)'")
        }
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        performSegue(withIdentifier: "cellSegue", sender: nil)
          //＋のタップとセルのタップを感知し、画面遷移先にデータを受け渡す
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputVC:inputViewController = segue.destination as! inputViewController
          // 遷移先のinputViewControllerの情報を得る
        if segue.identifier == "cellSegue"{
            let indexPath = self.tableView.indexPathForSelectedRow
              //選択したsectionとrowの配列を取得
            inputVC.task = taskArray[indexPath!.row]
              //rowの位置のデータ(タイトル・内容・日時)を遷移先のinputViewControllerに渡す
        } else {
              //"+"ボタンを押した時
            let task = Task()
            let allTasks = realm.objects(Task.self)
              //データベースのデータを取得
            if allTasks.count != 0 {
                  //既に入力済みのデータがある時
                task.id = allTasks.max(ofProperty: "id")! + 1
                  //最終row番号に1を足す。
            }
            inputVC.task = task
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
          //inputViewControllerから戻って画面が表示される前に再度データを読み込む
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle{
    return .delete
          //セルが削除可能なことを伝えるメソッド　削除を可能にするため.deleteを返す
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
          //deleteボタンが押された時に呼ばれるメソッド
        
        if editingStyle == .delete{
            let task = self.taskArray[indexPath.row]
            let center = UNUserNotificationCenter.current()
              //古い通知が削除されて新しい通知が登録される：インスタンス化
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
              //指定した通知を削除
            
            try! realm.write{
                self.realm.delete(self.taskArray[indexPath.row])
                tableView.deleteRows(at: [indexPath],with: .bottom)
                  //データベースから削除
            }
            center.getPendingNotificationRequests{(requests: [UNNotificationRequest]) in for request in requests{
                  //未配信の通信の一覧を取得
                print("/----------")
                print(request)
                print("----------/")
                }
            }
        }
    }
}

