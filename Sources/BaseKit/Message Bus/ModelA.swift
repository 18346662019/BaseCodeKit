//
//  ModelA.swift
//  fff
//
//  Created by apple on 2026/2/6.
//

import Foundation
import Combine
import RealityKit

class ModelA: ObservableObject {
    private let subscriberId = SubscriberIdentifer(id: UUID(), type: "ModelA")
    
    init () {
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        MessageBus.shared.subscribe(subscriberId, to: .entityDidUpdate) { [weak self] message in
            guard let self = self else {return}
            
            self.handleEntitySelection(message.payload as? Entity)
        }
    }
    private func handleEntitySelection(_ entity: Entity?) {
        print("执行了 handleEntitySelection", entity?.name ?? "")
    }
    
    func selectedEntity(_ entity: Entity) {
        MessageBus.shared.send(.entityDidSelect, sender: subscriberId, payload: entity)
    }
    
//    deinit {
//        MessageBus.shared.unsubscribeAll(subscriberId)
//    }
}
