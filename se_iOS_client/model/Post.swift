//
//  File.swift
//  se_iOS_client
//
//  Created by syon on 2021/05/25.
//

import UIKit

class Post {
    var postId : Int?
    var boardId : Int?
    
    var boardNameEng : String?
    var boardNameKor: String?
    
    var views : Int?
    var numReply : Int?
    
    var isNotice : String?
    var isSecret : String?
    
    var title : String?
    var previewText : NSAttributedString?
    var text : NSAttributedString?
    var textString : String?
    var nickname : String?
    
    var createAt : String?
    var tagId : Int?
    var tagNameList : Array<String>?
    
    var anonymousNickname : String?
    var anonymousPassword : String?
    
    var accountType: String?
}
