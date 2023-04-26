//
//  CommonUrl.swift
//  OrganizeWebView
//
//  Created by 도학태 on 2023/04/26.
//

import Foundation






protocol CommonUrlProtocol {
    var baseUrl : String { get }
    var resultUrl : String { get set }
    func getUrl() -> URL?
}

extension CommonUrlProtocol {
    func getUrl() -> URL? {
        URL(string: self.resultUrl)
    }
}

struct SwiftUrl : CommonUrlProtocol {
    var baseUrl: String {
        return AppConfigure.IS_PRODUCT_RELEASE ? "https://will-d-swift.com" : "https://test-will-d-swift.com"
    }
    
    var resultUrl: String = ""
    
    /*
     그때 그때 path 작성해서 진입
     */
    init(customPath : String) {

        resultUrl = "\(baseUrl)/\(customPath)"
    }
    
    /*
     path를 통한 진입
     */
    init(path : Path) {
        resultUrl = "\(baseUrl)/\(path.rawValue)"
    }
    
    /*
     Detail Page 진입
     */
    init(person : Person) {
        resultUrl = "\(baseUrl)/detail/\(person.id)"
    }
    
    enum Path : String {
        case closure    = "closure"
        case pop        = "pop"
        case _protocol  = "protocol"
        case _extension = "extension"
    }
}

struct KotlinUrl : CommonUrlProtocol {
    var baseUrl: String {
        return AppConfigure.IS_PRODUCT_RELEASE ? "https://will-d-kotlin.com" : "https://test-will-d-kotlin.com"
    }
    
    var resultUrl: String = ""
    
    enum Path : String {
        case convertJava = "convertJava"
        case nullSafety = "nullSafety"
    }
    
    init(customPath : String) {
        resultUrl = "\(baseUrl)/\(customPath)"
    }
    
    init(path : Path) {
        resultUrl = "\(baseUrl)/\(path.rawValue)"
    }
}

