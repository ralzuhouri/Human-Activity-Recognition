//
//  Queue.swift
//  Human Activity Recognition WatchKit Extension
//
//  Created by Ramy Al Zuhouri on 09/12/17.
//  Copyright © 2017 Ramy Al Zuhouri. All rights reserved.
//

import Foundation

// FIFO queue
// Push on the tail, pop on the head
class Queue<T>
{
	class Node<T>
	{
		let value:T
		var next:Node<T>?
		weak var previous:Node<T>?
		
		init(value:T) { self.value = value }
	}
	
	var head:Node<T>? // Head of the FIFO queue (oldest node)
	var tail:Node<T>? // Tail of the FIFO queue (newest node)
	private(set) var count = 0
	
	var isEmpty:Bool {
		return count == 0
	}
	
	func pushBack(_ value:T) { push(value) }
	
	func pushFront(_ value:T) {
		let node = Node<T>(value: value)
		count += 1
		
		if head == nil {
			head = node
			tail = node
			return
		}
		
		node.previous = head
		head?.next = node
		head = node
	}
	
	func push(_ value:T) {
		let node = Node<T>(value: value)
		count += 1
		
		if tail == nil {
			head = node
			tail = node
			return
		}
		
		node.next = tail
		tail?.previous = node
		tail = node
	}
	
	func pop() -> T? {
		if head == nil {
			return nil
		}
		
		count -= 1
		let node = head
		head?.previous?.next = nil
		head = head?.previous
		if head == nil { tail = nil }
		return node?.value
	}
	
	func clear() {
		head = nil
		tail = nil
	}
}



















