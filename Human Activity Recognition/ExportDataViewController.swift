//
//  ExportDataViewController.swift
//  Human Activity Recognition
//
//  Created by Ramy Al Zuhouri on 28/10/17.
//  Copyright © 2017 Ramy Al Zuhouri. All rights reserved.
//

import UIKit
import MessageUI

class ExportDataViewController: UIViewController, MFMailComposeViewControllerDelegate
{
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	private var _controller:TrainingsController?
	var controller:TrainingsController {
		if _controller == nil {
			_controller = TrainingsController(background: true)
		}
		return _controller!
	}
	let helper = ICloudHelper()
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.activityIndicator.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	@IBAction func restoreLatestICloudBakup(_ sender: UIButton) {
		self.activityIndicator.isHidden = false
		self.activityIndicator.startAnimating()
		self.navigationItem.leftBarButtonItem?.isEnabled = false
		
		self.controller.context.perform { [weak self] in
			self?.helper.fileURLs(forFilename: nil, inDirectory: nil) { (urls, exists) in
				
				defer {
					DispatchQueue.main.async {
						self?.activityIndicator.isHidden = true
						self?.activityIndicator.stopAnimating()
						self?.navigationItem.leftBarButtonItem?.isEnabled = true
					}
				}
				
				var backups = [URL]()
				for url in urls {
					guard let url = url else { continue }
					let name = (url.path as NSString).lastPathComponent
					if name.contains("Backup") {
						backups.append(url)
					}
				}
				
				var datesAndURLs = [(Date,URL)]()
				let formatter = DateFormatter()
				formatter.timeStyle = .medium
				formatter.dateStyle = .medium
				
				for url in backups {
					let name = (url.path as NSString).lastPathComponent as String
					var dateString = name
					guard let prefixRange = dateString.range(of: "Backup ") else { continue }
					dateString.removeSubrange(prefixRange)
					
					guard let suffixRange = dateString.range(of: ".xml") else { continue }
					dateString.removeSubrange(suffixRange)
					guard let date = formatter.date(from: dateString) else { continue }
					datesAndURLs.append((date,url))
				}
				
				datesAndURLs.sort(by: { (dateAndURL1, dateAndURL2) -> Bool in
					let date1 = dateAndURL1.0
					let date2 = dateAndURL2.0
					return date1 > date2
				})
				
				let fail = { (message:String?) in
					DispatchQueue.main.async {
						let alert = UIAlertController(title: "Failure", message: message, preferredStyle: .alert)
						let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
						alert.addAction(ok)
						self?.present(alert, animated: true, completion: nil)
					}
				}
				
				guard let latestDate = datesAndURLs.first?.0 else {
					fail("There are no Backups to Restore")
					return
				}
				guard let latestDateURL = datesAndURLs.first?.1 else {
					fail("There are no Backups to Restore")
					return
				}
				
				guard let success = self?.controller.restore(fromURL: latestDateURL) else { return }
				self?.controller.saveContext()
				NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didEditDataset"), object: nil)
				
				DispatchQueue.main.async {
					if success {
						let latestDateString = formatter.string(from: latestDate)
						let alert = UIAlertController(title: "Success!", message: "Backup from \(latestDateString) Restored with Success", preferredStyle: .alert)
						let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
						alert.addAction(ok)
						self?.present(alert, animated: true, completion: nil)
					} else {
						fail("Could not Restore Latest Backup. The File may be Corrupted")
					}
				}
			}
		}
	}
	
	@IBAction func saveICloudBackup(_ sender: UIButton)
	{
		self.activityIndicator.isHidden = false
		self.activityIndicator.startAnimating()
		self.navigationItem.leftBarButtonItem?.isEnabled = false
		
		self.controller.context.perform { [weak self] in
			if let data = self?.controller.data {
				let helper = ICloudHelper()
				let date = Date()
				let formatter = DateFormatter()
				formatter.timeStyle = .medium
				formatter.dateStyle = .medium
				let filename = "Backup " + formatter.string(from: date) + ".xml"
				helper.fileURLs(forFilename: filename, inDirectory: nil) {(urls:[URL?], exists:Bool) in
					if let url = urls.first, url != nil {
						var document:ICloudDocument?
						if exists {
							document = helper.openDocument(atURL: url!)
						} else {
							document = helper.createDocument(atURL: url!)
						}
						
						if document != nil {
							document!.data = data
							helper.overwriteDocument(document!)
							helper.closeDocument(document!)
							
							DispatchQueue.main.async {
								self?.activityIndicator.isHidden = true
								self?.activityIndicator.stopAnimating()
								self?.navigationItem.leftBarButtonItem?.isEnabled = true
								
								let alert = UIAlertController(title: "Success", message: "The Backup was Succesfully Saved to the iCloud Documents Folder", preferredStyle: .alert)
								let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
								alert.addAction(ok)
								self?.navigationController?.topViewController?.present(alert, animated: true, completion: nil)
							}
						}
					}
				}
			}
		}
	}
	
	@IBAction func saveToICloud(_ sender: UIButton)
	{
		self.activityIndicator.isHidden = false
		self.activityIndicator.startAnimating()
		self.navigationItem.leftBarButtonItem?.isEnabled = false
		
		self.controller.context.perform { [weak self] in
			let trainings = self?.controller.trainings
			if let csv = trainings?.csvString() {
				let helper = ICloudHelper()
				let date = Date()
				let formatter = DateFormatter()
				formatter.timeStyle = .medium
				formatter.dateStyle = .medium
				let filename = "Dataset " + formatter.string(from: date) + ".csv"
				helper.fileURLs(forFilename: filename, inDirectory: nil) { (urls:[URL?], exists:Bool) in
					if let url = urls.first, url != nil {
						var document:ICloudDocument?
						if exists {
							document = helper.openDocument(atURL: url!)
						} else {
							document = helper.createDocument(atURL: url!)
						}
						
						if document != nil {
							document!.setContents(csv)
							helper.overwriteDocument(document!)
							helper.closeDocument(document!)
							
							DispatchQueue.main.async {
								self?.activityIndicator.isHidden = true
								self?.activityIndicator.stopAnimating()
								self?.navigationItem.leftBarButtonItem?.isEnabled = true
								
								let alert = UIAlertController(title: "Success", message: "The Dataset was Succesfully exported to the iCloud Documents Folder", preferredStyle: .alert)
								let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
								alert.addAction(ok)
								self?.navigationController?.topViewController?.present(alert, animated: true, completion: nil)
							}
						}
					}
				}
			}
		}
	}
	
	
	@IBAction func sendViaEmail(_ sender: UIButton) {
		self.activityIndicator.isHidden = false
		self.activityIndicator.startAnimating()
		self.navigationItem.leftBarButtonItem?.isEnabled = false
		
		self.controller.context.perform { [weak self] in
			if let data = self?.controller.trainings?.csvString().data(using: .utf8) {
				DispatchQueue.main.async {
					let mailVC = MFMailComposeViewController()
					mailVC.mailComposeDelegate = self
					mailVC.setSubject("Training Data")
					mailVC.setMessageBody("This is the Training Dataset Attachment.", isHTML: false)
					mailVC.addAttachmentData(data, mimeType: "text/csv", fileName: "TrainingDataset.csv")
					self?.present(mailVC, animated: true, completion: {})
				}
			}
		}
	}
	
	/*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
	
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		self.dismiss(animated: false, completion: nil)
		
		var msg:String!
		var title:String!
		
		switch (result)
		{
		case .sent:
			msg = "Training Dataset Sent via Email"
			title = "Success"
			break
		case .saved:
			msg = "Draft Saved"
			title = "Success"
			break
		case .cancelled:
			msg = "The Email Has Been Cancelled"
			title = "Email Cancelled"
			break
		case .failed:
			msg = "Mail failed:  An error occurred when trying to compose this email"
			title = "Error"
			break
		}
		
		let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
		let ok = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in }
		alert.addAction(ok)
		self.present(alert, animated: true, completion: {})
		
		self.activityIndicator.isHidden = true
		self.activityIndicator.stopAnimating()
		self.navigationItem.leftBarButtonItem?.isEnabled = true
	}

}






