//
//  MessageQueue.swift
//  Human Activity Recognition WatchKit Extension
//
//  Created by Ramy Al Zuhouri on 06/12/17.
//  Copyright © 2017 Ramy Al Zuhouri. All rights reserved.
//

import Foundation
import WatchConnectivity

protocol MessageQueueDelegate:NSObjectProtocol
{
	func messageQueue(_ queue:MessageQueue, didDeliverMessage message:[String:Any], withReply:[String:Any])
	func messageQueue(_ queue:MessageQueue, didFailToDeliverMessage:[String:Any], retry: UnsafeMutablePointer<Bool>)
}

fileprivate class Message {
	let sequenceNumber:Int
	let contents:[String:Any]
	
	init(sequenceNumber:Int, contents:[String:Any]) {
		self.sequenceNumber = sequenceNumber
		self.contents = contents
	}
}

class MessageQueue
{
	private var semaphore = DispatchSemaphore(value: 1)
	private var timer:Timer?
	private var queue = Queue<Message>()
	private var currentMessage:Message?
	private var _nextSequenceNumber = 0
	var nextSequenceNumber:Int {
		defer {
			_nextSequenceNumber += 1
		}
		return _nextSequenceNumber
	}
	
	var timeout:TimeInterval
	weak var delegate:MessageQueueDelegate?
	
	var tokens = 5.0 // 5 tokens = 1 message
	var tokensTimer:Timer?
	
	init(timeout:TimeInterval) {
		self.timeout = timeout
		
		self.tokensTimer = Timer(timeInterval: 0.25, repeats: true, block: { [weak self] (timer:Timer) in
			guard let tokens = self?.tokens else { return }
			let success:Bool
			
			if tokens >= 5.0 {
				success = self?.send() ?? false
				if success { self?.tokens -= 5.0 }
			}
			
			self?.tokens = min(tokens + 1.0, 5.0)
		})
		
		RunLoop.main.add(self.tokensTimer!, forMode: .commonModes)
	}
	
	deinit {
		self.timer?.invalidate()
		self.tokensTimer?.invalidate()
	}
	
	var size:Int {
		return self.queue.count
	}
	
	var isEmpty:Bool {
		return self.size == 0
	}
	
	var session:WCSession {
		return WCSession.default
	}
	
	var canSendMessage:Bool {
		guard WCSession.isSupported() else { return false }
		return self.session.activationState == .activated && self.session.isReachable
	}
	
	func clear() {
		self.semaphore.wait()
		self.currentMessage = nil
		self.queue.clear()
		
		self.semaphore.signal()
	}
	
	func send() -> Bool {
		self.semaphore.wait()
		defer {
			self.semaphore.signal()
		}
		
		guard self.currentMessage == nil else {
			return false
		}
		guard self.canSendMessage else {
			return false
		}
		guard let message = self.dequeue() else { return false }
		let sentSN = message.sequenceNumber
		
		self.currentMessage = message
		
		DispatchQueue.global(qos: .background).async {
			self.session.sendMessage(message.contents, replyHandler: { [weak self] replyDict in
				self?.semaphore.wait()
				defer {
					self?.semaphore.signal()
				}
				
				guard let currentMessage = self?.currentMessage else { return }
				let currentSN = currentMessage.sequenceNumber
				if currentSN == sentSN {
					self?.currentMessage = nil
					self?.timer?.invalidate()
					
					self?.delegate?.messageQueue(self!, didDeliverMessage: currentMessage.contents, withReply: replyDict)
				} else {
					//Log("Received reply handler of message with wrong sequence number. Correct message sequence number: \(currentSN), received sequence number: \(sentSN)")
				}
				}, errorHandler: { [weak self] error in
					print("\(error)") // The failed delivery is handled in the timeout
			})
		}
		
		self.timer?.invalidate()
		
		self.timer = Timer(timeInterval: self.timeout, repeats: false) { [weak self] timer in
			self?.semaphore.wait()
			defer {
				self?.semaphore.signal()
			}
			guard let currentMessage = self?.currentMessage else {
				return
			}
			self?.currentMessage = nil
			var retry:Bool = true
			
			self?.delegate?.messageQueue(self!, didFailToDeliverMessage: currentMessage.contents, retry: &retry)
			if retry {
				self?.queue.pushFront(currentMessage)
			}
		}
		
		RunLoop.main.add(self.timer!, forMode: .defaultRunLoopMode)
		
		return true
	}
	
	func enqueue(message:[String:Any]) {
		self.semaphore.wait()
		let message = Message(sequenceNumber: self.nextSequenceNumber, contents: message)
		self.queue.pushBack(message)
		self.semaphore.signal()
	}
	
	private func dequeue() -> Message? { // This should be ONLY called after waiting on the semaphore!
		guard let message = self.queue.pop() else { return nil }
		return message
	}
}









