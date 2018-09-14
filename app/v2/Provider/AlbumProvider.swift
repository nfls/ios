//
//  AlbumProvider.swift
//  NFLSers-iOS
//
//  Created by Qingyang Hu on 2018/9/14.
//  Copyright © 2018 胡清阳. All rights reserved.
//

import Foundation

class GalleryProvider: AbstractProvider<GalleryRequest> {
    public var list: [Gallery] = []
    public var detail: Gallery? = nil
    public var id: Int? {
        get {
            return self.detail?.id
        }
    }
    
    public func getList(completion: @escaping ()->Void ) {
        self.request(target: GalleryRequest.list(), type: ListWrapper<Gallery>.self, success: { response in
            self.list = response.data.list
            completion()
        })
    }
    
    public func getDetail(id: Int, completion: @escaping ()->Void) {
        self.request(target: GalleryRequest.detail(id: id), type: Gallery.self, success: { response in
            self.detail = response.data
            completion()
        })
    }
    
    public func comment(_ text: String, completion: @escaping (String?)->Void) {
        self.request(target: GalleryRequest.comment(id: self.id!, content: text), type: DataWrapper<String?>.self, success: {response in
            completion(response.data.value)
        })
    }
    
    public func like(completion: @escaping ()->Void) {
        self.request(target: GalleryRequest.like(), type: DataWrapper<String?>.self, success: {response in
            completion()
        })
    }
    
    public func likeStatus(completion: @escaping (Bool)->Void) {
        self.request(target: GalleryRequest.likeStatus(), type: DataWrapper<Bool>.self, success: {response in
            completion(response.data.value)
        })
    }
 }
