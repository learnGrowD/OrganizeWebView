//
//  CommonBridgeResultDto.swift
//  OrganizeWebView
//
//  Created by 도학태 on 2023/04/26.
//

import Foundation




protocol CommonBridgeProtocol : Codable {
    var functionName : String? { get set }
}


struct CommonBridgeResultDto : CommonBridgeProtocol {
    var functionName: String?
}

struct ShowBottomModalResultDto : CommonBridgeProtocol {
    var functionName: String?
    
    let actions : [Item]
    
    struct Item : Codable {
        let title : String?
        let color : String?
        let actionId : String?
    }
}
