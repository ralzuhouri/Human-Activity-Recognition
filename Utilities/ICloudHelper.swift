//
//  ICloudHelper.swift
//  Human Activity Recognition
//
//  Created by Ramy Al Zuhouri on 28/10/17.
//  Copyright © 2017 Ramy Al Zuhouri. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ICloudDocument: UIDocument
{
	var data:Data?
	
	func setContents(_ contents:String) {
		let length = contents.lengthOfBytes(using: .utf8)
		self.data = NSData(bytes: contents, length: length) as Data
	}
	
	override func contents(forType typeName: String) throws -> Any {
		if let data = self.data {
			return data
		} else {
			return Data()
		}
	}
	
	override func load(fromContents contents: Any, ofType typeName: String?) throws {
		if let data = contents as? Data {
			/*self.contents = NSString(bytes: (contents as AnyObject).bytes,
			                         length: userContent.count,
			                         encoding: String.Encoding.utf8.rawValue) as String?*/
			self.data = data
		}
	}
}

class ICloudHelper
{
	private var query:NSMetadataQuery?
	private var completionHandler:(([URL?],Bool) -> Void)?
	private var ubiquityURL:URL?
	
	// Not fully working: for some reason it can't list the files in a subdirectory
	// It works only if the directory parameter is nil
	func fileURLs(forFilename filename:String?, inDirectory directory:String?, completionHandler: @escaping ([URL?],Bool) -> Void)
	{
		let manager = FileManager.default
		guard var ubiquityURL = manager.url(forUbiquityContainerIdentifier: nil) else {
			completionHandler([nil], false)
			return
		}
		ubiquityURL = ubiquityURL.appendingPathComponent("Documents")
		if directory != nil {
			ubiquityURL = ubiquityURL.appendingPathComponent("\(directory!)")
		}
		if filename != nil {
			ubiquityURL = ubiquityURL.appendingPathComponent("\(filename!)")
		}
		self.ubiquityURL = ubiquityURL
		
		self.completionHandler = completionHandler
		self.query = NSMetadataQuery()
		
		var predicates:[NSPredicate] = []
		if filename != nil {
			predicates.append(NSPredicate(format: "%K like '\(filename!)'", NSMetadataItemFSNameKey))
		}
		if directory != nil {
			predicates.append(NSPredicate(format: "%K like '\(directory!)'",NSMetadataItemPathKey))
		}
		self.query?.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
		self.query?.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
		
		NotificationCenter.default.addObserver(self, selector: #selector(self.metadataQueryDidFinishGathering(notification:)), name: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: query)
		
		DispatchQueue.main.async { [weak self] in
			self?.query?.start()
		}
	}
	
	@objc private func metadataQueryDidFinishGathering(notification:Notification) {
		self.query?.disableUpdates()
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: query)
		self.query?.stop()
		
		if let resultCount = self.query?.resultCount, resultCount > 0 {
			var URLs = [URL]()
			for i in 0..<resultCount {
				let resultURL = self.query?.value(ofAttribute: NSMetadataItemURLKey, forResultAt: i) as! URL
				URLs.append(resultURL)
			}
			completionHandler?(URLs, true)
		} else {
			completionHandler?([ubiquityURL], false)
		}
	}
	
	func openDocument(atURL url:URL) -> ICloudDocument? {
		let document = ICloudDocument(fileURL: url)
		document.open { (success:Bool) in
			if !success {
				print("Failed to open iCloud document at URL: \(url)")
			}
		}
		return document
	}
	
	func createDocument(atURL url:URL) -> ICloudDocument? {
		let document = ICloudDocument(fileURL: url)
		document.save(to: url, for: .forCreating) { (success:Bool) in
			if !success {
				print("Failed to create iCloud document at URL \(url)")
			}
		}
		return document
	}
	
	func overwriteDocument(_ document:UIDocument) {
		document.save(to: document.fileURL, for: .forOverwriting) { (success:Bool) in
			if !success {
				print("Failed to overwrite iCloud document at URL: \(document.fileURL)")
			}
		}
	}
	
	func closeDocument(_ document:UIDocument) {
		document.close(completionHandler: nil)
	}
}







