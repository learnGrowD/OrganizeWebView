//
//  CommonBridgeResultDto.swift
//  OrganizeWebView
//
//  Created by 도학태 on 2023/04/26.
//

import Foundation




protocol CommonBridgeResultDto : Codable {
    var functionName : String { get set }
}




struct ShowBottomModalResultDto : CommonBridgeResultDto {
    var functionName: String
    
    let actions : [Item]
    
    struct Item : Codable {
        let title : String
        let color : String
        let actionId : String
    }
}
