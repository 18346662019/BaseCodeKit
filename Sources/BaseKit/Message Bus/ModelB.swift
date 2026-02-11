//
//  ModelB.swift
//  fff
//
//  Created by apple on 2026/2/6.
//

import Foundation
import Combine
import RealityKit

class ModelB: ObservableObject {
   
    private let subscriberId = SubscriberIdentifer(id: UUID(), type: "ModelB")
    
    init() {
        setupSubscriptions()
    }
    
    func setupSubscriptions() {
        MessageBus.shared.subscribe(subscriberId, to: .entityDidSelect) { [weak self] message in
            guard let self = self else {return}
            self.handleEntitySelection(entity: message.payload as? Entity)
        }
    }
    
    func handleEntitySelection(entity: Entity?) {
        print("ModelB 接到了消息", entity?.name ?? "")
    }
    
    func selectedEntity(_ entity: Entity) {
        MessageBus.shared.send(.entityDidUpdate, sender: subscriberId, payload: entity)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            MessageBus.shared.removeAllSubscribers()
            
            
//            MessageBus.shared.unsubscribeAll(self.subscriberId)
//            MessageBus.shared.unsubscribe(self.subscriberId, from: .entityDidSelect)
        })
    }
}
