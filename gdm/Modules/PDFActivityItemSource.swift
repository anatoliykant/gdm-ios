//
//  PDFActivityItemSource.swift
//  gdm
//
//  Created by Anatoliy Podkladov on 2025-07-07.
//

import LinkPresentation

final class PDFActivityItemSource: NSObject, UIActivityItemSource {
    
    private let url: URL
    private let title: String
    private let data: Data
    private let fileName: String
    
    init(url: URL, title: String = "Дневник сахара", data: Data, fileName: String) {
        self.url = url
        self.title = title
        self.data = data
        self.fileName = fileName
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return data
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return data
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return fileName
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "com.adobe.pdf"
    }
    
//    func activityViewController(_ activityViewController: UIActivityViewController, linkMetadataForActivityType activityType: UIActivity.ActivityType?) -> LPLinkMetadata? {
//        return nil
//    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = title
        metadata.url = url
        metadata.originalURL = url
        metadata.iconProvider = NSItemProvider(contentsOf: url)
        return metadata
    }
}
