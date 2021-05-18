//
//  User.swift
//  se_iOS_client
//
//  Created by syon on 2021/04/04.
//

import Foundation

struct Account {
    var account_id: Int64?
    var id: String
    var password: String
    var name: String
    var nickname: String
    var student_id: String?
    var type: String?
    var phone_number: String?
    var email: String
    var last_signin_ip: String?
    var information_open_agree: Bool?
}
