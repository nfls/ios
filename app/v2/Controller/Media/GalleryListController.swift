//
//  GalleryListController.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 21/01/2018.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation

class GalleryListController:AbstractViewController {
    override func viewDidLoad() {
        let provider = GalleryProvider()
        provider.getList {
            dump(provider.list)
        }
    }
}
