//
//  ComplicationController.swift
//  Human Activity Recognition WatchKit Extension
//
//  Created by Ramy Al Zuhouri on 02/09/17.
//  Copyright © 2017 Ramy Al Zuhouri. All rights reserved.
//

import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource
{
	var tintColor:UIColor {
		return UIColor(red: 1.0, green: 0.792, blue: 0.294, alpha: 1.0)
	}
	
	class func reloadData() {
		let server = CLKComplicationServer.sharedInstance()
		guard let complications = server.activeComplications else {
			return
		}
		
		for complication in complications {
			server.reloadTimeline(for: complication)
		}
	}
	
	func template(forComplication complication:CLKComplication) -> CLKComplicationTemplate?
	{
		let info = WorkoutInfo.shared
		
		if complication.family == .modularSmall {
			let template = CLKComplicationTemplateModularSmallSimpleImage()
			guard let image = UIImage(named: "Complication/Modular") else {
				return nil
			}
			template.imageProvider = CLKImageProvider(onePieceImage: image)
			template.imageProvider.tintColor = self.tintColor
			return template
		} else if complication.family == .modularLarge {
			let template = CLKComplicationTemplateModularLargeStandardBody()
			guard let image = UIImage(named: "Complication/Modular") else {
				return nil
			}
			template.headerImageProvider = CLKImageProvider(onePieceImage: image)
			template.headerImageProvider?.tintColor = self.tintColor
			// Why not white? a white color is automatically turned into gray, but this isn't detected
			// as white. It's a workaround to avoid having gray text in the body text providers
			template.tintColor = UIColor(red: 0.99, green: 0.99, blue: 0.99, alpha: 1.0)
			
			let headerTextProvider = CLKSimpleTextProvider(text: "Human Activity Recognition", shortText: "HAR App")
			headerTextProvider.tintColor = self.tintColor
			template.headerTextProvider = headerTextProvider
			
			let body1TextProvider = CLKSimpleTextProvider(text: info.sessionStatusText, shortText: info.sessionStatusShortText)
			template.body1TextProvider = body1TextProvider
			
			let body2TextProvider = CLKSimpleTextProvider(text: info.instancesText, shortText: info.instancesShortText)
			template.body2TextProvider = body2TextProvider
			return template
		} else if complication.family == .utilitarianSmall {
			let template = CLKComplicationTemplateUtilitarianSmallSquare()
			guard let image = UIImage(named: "Complication/Utilitarian") else {
				return nil
			}
			template.imageProvider = CLKImageProvider(onePieceImage: image)
			template.imageProvider.tintColor = self.tintColor
			return template
		} else if complication.family == .circularSmall {
			let template = CLKComplicationTemplateCircularSmallSimpleImage()
			guard let image = UIImage(named: "Complication/Circular") else {
				return nil
			}
			template.imageProvider = CLKImageProvider(onePieceImage: image)
			template.imageProvider.tintColor = self.tintColor
			return template
		} else if complication.family == .extraLarge {
			let template = CLKComplicationTemplateExtraLargeSimpleImage()
			guard let image = UIImage(named: "Complication/Extra Large") else {
				return nil
			}
			template.imageProvider = CLKImageProvider(onePieceImage: image)
			template.imageProvider.tintColor = self.tintColor
			return template
		}
		
		return nil
	}
	
	// MARK: - Timeline Configuration
	func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
		handler([])
	}
	
	// MARK: - Timeline Population
	func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
		// Call the handler with the current timeline entry
		guard let template = self.template(forComplication: complication) else {
			handler(nil)
			return
		}
		let timelineEntry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
		handler(timelineEntry)
	}
	
	// MARK: - Placeholder Templates
	func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
		// This method will be called once per supported complication, and the results will be cached
		let template = self.template(forComplication: complication)
		handler(template)
	}
	
}







