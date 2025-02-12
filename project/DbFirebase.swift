//
//  DbFirebase.swift
//  project
//
//  Created by yhSuh on 2024/06/17.
//

import Foundation
import FirebaseFirestore

class DbFirebase: Database{
    // 데이터를 저장할 위치 설정
    var reference: CollectionReference = Firestore.firestore().collection("foods")
    
    // 데이터의 변화가 생기면 알려쥐 위한 클로즈
    var parentNotification: (([String: Any]?, DbAction?) -> Void)?
    var existQuery: ListenerRegistration?   // 이미 설정한 Query의 존재여부

    required init(parentNotification: (([String : Any]?, DbAction?) -> Void)?) {
        // 클로저를 보관
        self.parentNotification = parentNotification
    }
    
    func setQuery(from: Any, to: Any) {
        if let query = existQuery{
            query.remove()
        }
        
        let query = reference.whereField("id", isGreaterThanOrEqualTo: 0).whereField("id", isLessThanOrEqualTo: 10000)
        
        existQuery = query.addSnapshotListener(onChangingData)
    }
    
    func saveChange(key: String, object: [String : Any], action: DbAction) {
        if action == .detete{
            reference.document(key).delete()
            return
        }
        reference.document(key).setData(object)
    }
    
    func onChangingData(querySnapshot: QuerySnapshot?, error: Error?){
        guard let querySnapshot = querySnapshot else { return }
        if(querySnapshot.documentChanges.count == 0){
            return
        }
        
        for documentChange in querySnapshot.documentChanges{
            let dict = documentChange.document.data()
            var action: DbAction?
            switch(documentChange.type){
            case    .added: action = .add
            case    .modified: action = .modify
            case    .removed: action = .detete
            }
            
            if let parentNotification = parentNotification {parentNotification(dict, action)}
        }
    }
}
