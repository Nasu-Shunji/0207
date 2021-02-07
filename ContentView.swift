//
//  ContentView.swift
//  FarmChatApp
//
//  Created by nasu shunji on 2021/02/02.
//

import SwiftUI
import CoreData
import UIKit

public class Informsave: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID?
    @NSManaged public var dataname: String?
    @NSManaged public var datapwd: String?
}

struct ContentView: View {
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink("sign up", destination: SignupView())
                NavigationLink("login", destination: LoginView())
            }
            .navigationBarTitle("Sign up/Login")   // << required, at least empty !!
        }
    }
}

struct SignupView: View {
    @State var SignupShow = false
    @State var name = ""
    @State var pwd = ""
    @Environment(\.managedObjectContext) var Data

    @FetchRequest(entity: Informsave.entity(), sortDescriptors: []) var informs: FetchedResults<Informsave>
    
    var body: some View {
        NavigationView {
        VStack{
            /*ForEach(self.informs, id: \.self) { inform in
                Text(inform.datapwd ?? "Unknown").onAppear{
                    print("")
                }
            }*/
            TextField("氏名を入力してください", text: $name)
            SecureField("パスワードを入力してください", text: $pwd)
            if name.isEmpty == false && pwd.isEmpty == false {
                Button("登録",action:{
                let inform = Informsave(context: self.Data)
                inform.id = UUID()
                inform.dataname = name
                inform.datapwd = pwd
                try! self.Data.save()
                self.SignupShow.toggle()
                    })
               /* Button(action: {
                                    self.Data.delete(self.informs[0])

                                    try! self.Data.save()

                                }) {
                Text("削除")
                Image(systemName: "trash")
            }*/
                if SignupShow{
                    Text("会員番号" + "\(informs.count)")
                    NavigationLink("次へ", destination: FarmView())
                    }
                }
            }
        }
    }
}
struct LoginView: View {
    @State var LoginShow1 = false
    @State var LoginShow2 = false
    @State var name = ""
    @State var pwd = ""
    @State var num = 0
    
    
    @Environment(\.managedObjectContext) var Data

    @FetchRequest(entity: Informsave.entity(), sortDescriptors: []) var informs: FetchedResults<Informsave>

    var body: some View {
        NavigationView{
        VStack{
            Text("会員番号を入力してください。0は例です。")
            TextField("会員番号(半角数字)",text: $num.IntToStrDef(0)).keyboardType(.numberPad)
            TextField("氏名を入力してください", text: $name)
            SecureField("パスワードを入力してください", text: $pwd)
            if (informs.count >= num){
                ForEach(0..<1, id: \.self) { inform in
            Button("ログイン",action:{
                if informs[num-1].dataname == name && informs[num-1].datapwd == pwd{
                    self.LoginShow1.toggle()
                }else{
                    self.LoginShow2.toggle()
                }
            })
            if LoginShow1{
                Text("ログイン完了")
                NavigationLink("次へ", destination: FarmView())
            }else if LoginShow2{
                Text("ログイン情報が違います").foregroundColor(Color.red)
            }
                    }
                }
            }
        }
    }
}
            
struct ListView: View{
    var title:String
    var type:String
    var note:String
    var body: some View{
        HStack{
            VStack{
                HStack(spacing: 0){
                    Image(systemName: "star.fill")
                    Image(systemName: "star.fill")
                    Image(systemName: "star.fill")
                    Image(systemName: "star")
                    Image(systemName: "star")
                }.foregroundColor(.yellow)
                Text(type)
            }
            VStack(alignment:.leading){
                Text(title).font(.largeTitle)
                Text(note).font(.subheadline)
            }
        }
    }
}
extension Binding where Value == Int {
    func IntToStrDef(_ def: Int) -> Binding<String> {
        return Binding<String>(get: {
            return String(self.wrappedValue)
        }) { value in
            self.wrappedValue = Int(value) ?? def
        }
    }
}

struct FarmView: View{
    @State var showingDetail1 = false
    var body: some View{
        VStack{
        List{
            Button(action: {
                self.showingDetail1.toggle()
            }) {
            ListView(title: "石川農家", type: "お米", note: "石川県の豊富な水分でお米を育てました。")
            }.sheet(isPresented: $showingDetail1) {
                UIView()
            }
            Button(action: {
                self.showingDetail1.toggle()
            }) {
            ListView(title: "富山農家", type: "野菜", note: "富山県の大自然からとれた野菜は絶品です！")
            }.sheet(isPresented: $showingDetail1) {
                UIView()
            }
            Button(action: {
                self.showingDetail1.toggle()
            }) {
            ListView(title: "滋賀農家", type: "お肉", note: "A5ランクの近江牛をあなたの家へ産地直送。")
            }.sheet(isPresented: $showingDetail1) {
                UIView()
            }
        }.navigationBarHidden(true)
    }
}
}
struct UIView: View {
    var body: some View {
          UIViewControllerViewWrapper {
                Text("")
        }
    }

}


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

class ViewControllerWithStoryboard: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    // View構築後の処理
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)

        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateInitialViewController() as! ViewController
        nextView.modalPresentationStyle = .fullScreen
        present(nextView, animated: false, completion: nil)

    }
    
}

struct UIViewControllerViewWrapper<Content: View>: UIViewControllerRepresentable {

    //The type of view controller to present.
    //Required.
    typealias UIViewControllerType = ViewControllerWithStoryboard

    var content: () -> Content

    func makeUIViewController(context: Context) -> ViewControllerWithStoryboard {
    //Creates the view controller object and configures its initial state.
    //Required.
        let viewControllerWithStoryboard = ViewControllerWithStoryboard()
        return viewControllerWithStoryboard
    }
    func updateUIViewController(_ uiviewController: ViewControllerWithStoryboard, context: Context) {
    }
    
}

