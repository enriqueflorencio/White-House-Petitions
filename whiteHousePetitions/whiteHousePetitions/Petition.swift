//
//  Petition.swift
//  project7
//
//  Created by Enrique Florencio on 7/8/19.
//  Copyright © 2019 Enrique Florencio. All rights reserved.
//

import Foundation

struct Petition: Codable, Equatable {
    var title: String
    var body: String
    var signatureCount: Int
}
