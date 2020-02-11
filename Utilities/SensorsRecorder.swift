//
//  SensorsRecorder.swift
//  Human Activity Recognition
//
//  Created by Ramy Al Zuhouri on 12/09/17.
//  Copyright © 2017 Ramy Al Zuhouri. All rights reserved.
//

import Foundation
import CoreMotion
import CoreLocation
import WatchConnectivity

let HeartRateMonitor:UInt = 1
let Gyroscope:UInt = 1 << 1
let Accelerometer:UInt = 1 << 2
let GPS:UInt = 1 << 3

func SensorsConfigurationMaskFromPreferences() -> UInt
{
	var mask:UInt = 0
	
	if Preferences.includeHeartRate {
		mask = mask | HeartRateMonitor
	}
	
	if Preferences.includeRoll || Preferences.includePitch || Preferences.includeYaw || Preferences.includeAttitudeMagnitude || Preferences.includeXRotationRate || Preferences.includeYRotationRate || Preferences.includeZRotationRate || Preferences.includeRotationRateMagnitude {
		mask = mask | Gyroscope
	}
	
	if Preferences.includeXGravity || Preferences.includeYGravity || Preferences.includeZGravity || Preferences.includeGravityMagnitude || Preferences.includeXUserAcceleration || Preferences.includeYUserAcceleration || Preferences.includeZUserAcceleration || Preferences.includeUserAccelerationMagnitude {
		mask = mask | Accelerometer
	}
	
	if Preferences.includeLatitude || Preferences.includeLongitude || Preferences.includeAltitude || Preferences.includeCourse || Preferences.includeSpeed {
		mask = mask | GPS
	}
	
	return mask
}

struct SensorsState : Equatable
{
	var isHeartRateMonitorActive:Bool = false
	var isGyroscopeActive:Bool = false
	var isAccelerometerActive:Bool = false
	var isGPSActive:Bool = false
	
	var allSensorsAreActive:Bool {
		return isHeartRateMonitorActive && isAccelerometerActive && isGyroscopeActive && isGPSActive
	}
	
	init() {}
	
	init(withDataSample sample:DataSample) {
		self.isHeartRateMonitorActive = sample.isHeartRateMonitorActive
		self.isGyroscopeActive = sample.isGyroscopeActive
		self.isAccelerometerActive = sample.isAccelerometerActive
		self.isGPSActive = sample.isGPSActive
	}
	
	static func == (lhs:SensorsState, rhs:SensorsState) -> Bool {
		return lhs.isHeartRateMonitorActive == rhs.isHeartRateMonitorActive &&
			   lhs.isGyroscopeActive == rhs.isGyroscopeActive &&
			   lhs.isAccelerometerActive == rhs.isAccelerometerActive &&
			   lhs.isGPSActive == rhs.isGPSActive
	}
	
	static func != (lhs:SensorsState, rhs:SensorsState) -> Bool {
		return !(lhs == rhs)
	}
}

struct DataSample
{
	var heartRate:Double?
	var attitude:CMAttitude?
	var rotationRate:CMRotationRate?
	var gravity:CMAcceleration?
	var userAcceleration:CMAcceleration?
	var coordinate:CLLocationCoordinate2D?
	var altitude:CLLocationDistance?
	var course:CLLocationDirection?
	var speed:CLLocationSpeed?
	
	var hasNilValues:Bool {
		guard isHeartRateMonitorActive else { return true }
		guard isGyroscopeActive else { return true }
		guard isAccelerometerActive else { return true }
		guard isGPSActive else { return true }
		return false
	}
	
	func hasNilValues(forConfigurationMask mask:UInt) -> Bool {
		if (mask & HeartRateMonitor) == HeartRateMonitor {
			guard isHeartRateMonitorActive else { return true }
		}
		
		if (mask & Accelerometer) == Accelerometer {
			guard isAccelerometerActive else { return true }
		}
		
		if (mask & Gyroscope) == Gyroscope {
			guard isGyroscopeActive else { return true }
		}
		
		if (mask & GPS) == GPS {
			guard isGPSActive else { return true }
		}
		
		return false
	}
	
	var isHeartRateMonitorActive:Bool {
		guard let _ = self.heartRate else { return false }
		return true
	}
	
	var isGyroscopeActive:Bool {
		guard let _ = self.attitude else { return false }
		guard let _ = self.rotationRate else { return false }
		return true
	}
	
	var isAccelerometerActive:Bool {
		guard let _ = self.gravity else { return false }
		guard let _ = self.userAcceleration else { return false }
		return true
	}
	
	var isGPSActive:Bool {
		guard let _ = self.coordinate else { return false }
		guard let _ = self.altitude else { return false }
		guard let _ = self.speed else { return false }
		return true
	}
}

protocol SensorsRecorderDelegate : NSObjectProtocol
{
	func sensorsRecorder(_ recorder:SensorsRecorder, didExtractFeatures features:[String:Any])
	func sensorsRecorder(_ recorder:SensorsRecorder, didChangefromSensorsState fromState:SensorsState, toState:SensorsState)
}

enum SensorsRecorderSessionState
{
	case running, paused, ended, notStarted
}

class SensorsRecorder : NSObject
{
#if os(watchOS)
	// MARK: - Properties
	weak var delegate:SensorsRecorderDelegate?
	var healthKitService:HealthKitService
	var coreMotionService:CoreMotionService
	var coreLocationService:CoreLocationService
	var data:Queue<DataSample>
	var timer:Timer!
	var activity:String
	var sensorsState:SensorsState
	var collectData = false
	var sessionState:SensorsRecorderSessionState = .notStarted
	let configurationMask:UInt
	
	// MARK: - Methods
	convenience init?(activity:String) {
		self.init(activity: activity, configurationMask: SensorsConfigurationMaskFromPreferences())
	}
	
	init?(activity:String, configurationMask:UInt) {
		self.activity = activity
		self.configurationMask = configurationMask
		guard let healthKitService = HealthKitService(activity:activity) else { return nil }
		self.healthKitService = healthKitService
		
		guard let coreMotionService = CoreMotionService() else { return nil }
		coreMotionService.samplingFrequency = Preferences.samplingFrequency
		self.coreMotionService = coreMotionService
		
		self.coreLocationService = CoreLocationService()
		data = Queue<DataSample>()
		
		self.sensorsState = SensorsState()
		
		super.init()
	}
	
	var isHeartRateMonitorEnabled:Bool {
		return (self.configurationMask & HeartRateMonitor) == HeartRateMonitor
	}
	
	var isAccelerometerEnabled:Bool {
		return (self.configurationMask & Accelerometer) == Accelerometer
	}
	
	var isGyroscopeEnabled:Bool {
		return (self.configurationMask & Gyroscope) == Gyroscope
	}
	
	var isGPSEnabled:Bool {
		return (self.configurationMask & GPS) == GPS
	}
	
	deinit {
		print("SensorsRecorder.deinit")
		if self.sessionState == .running || self.sessionState == .paused {
			self.stop()
		}
	}
	
	let semaphore = DispatchSemaphore(value: 1)
	func scheduleTimer() {
		timer = Timer.scheduledTimer(withTimeInterval: 1.0 / Double(Preferences.samplingFrequency), repeats: true, block: { [weak self ](timer) in
			DispatchQueue.global(qos: .userInteractive).async {
				var sensorData = DataSample()
				sensorData.heartRate = self?.healthKitService.heartRate
				
				if let motion = self?.coreMotionService.motion {
					sensorData.attitude = motion.attitude
					sensorData.rotationRate = motion.rotationRate
					sensorData.gravity = motion.gravity
					sensorData.userAcceleration = motion.userAcceleration
				}
				
				if let location = self?.coreLocationService.location {
					sensorData.coordinate = location.coordinate
					sensorData.altitude = location.altitude
					sensorData.course = location.course
					sensorData.speed = location.speed
				}
				
				
				let newState = SensorsState(withDataSample: sensorData)
				if let oldState = self?.sensorsState, oldState != newState {
					self?.sensorsState = newState
					self?.delegate?.sensorsRecorder(self!, didChangefromSensorsState: oldState, toState: newState)
				}
				
				guard self?.collectData == true else { return }
				
				guard !sensorData.hasNilValues(forConfigurationMask: self?.configurationMask ?? 0) else {
					self?.semaphore.wait()
					self?.data.clear()
					self?.semaphore.signal()
					return
				}
				
				self?.semaphore.wait()
				self?.data.push(sensorData)
				self?.semaphore.signal()
				
				let windowSize = Int(Preferences.windowSize * Double(Preferences.samplingFrequency))
				var requiredWindowSize = windowSize
				if Preferences.trimLastTwoInstances {
					if Preferences.overlappingWindows {
						requiredWindowSize *= 2
					} else {
						requiredWindowSize *= 3
					}
				}
				
				if self?.data.count == requiredWindowSize {
					var array = [DataSample]()
					self?.semaphore.wait()
					var head = self?.data.head
					while head != nil {
						guard let value = head?.value else { break }
						array.append(value)
						if array.count == windowSize { break }
						head = head?.previous
					}
					self?.semaphore.signal()
					
					if array.count == windowSize {
						
						if let features = self?.extractFeatures(data: array) {
							DispatchQueue.main.async {
								self?.delegate?.sensorsRecorder(self!, didExtractFeatures: features)
							}
						}
						
						self?.semaphore.wait()
						if Preferences.overlappingWindows {
							for _ in 0..<windowSize / 2 {
								let _ = self?.data.pop()
							}
						} else {
							for _ in 0..<windowSize {
								let _ = self?.data.pop()
							}
						}
						self?.semaphore.signal()
					}
				}
			}
		})
	}
	
	// MARK: - Handling States
	func startSession() {
		if healthKitService.sessionState == .notStarted {
			healthKitService.startSession(monitorHeartRate: self.isHeartRateMonitorEnabled)
		}
	}
	
	func stopSession() {
		if healthKitService.sessionState == .running {
			healthKitService.stopSession(monitorHeartRate: self.isHeartRateMonitorEnabled)
		}
	}
	
	func start() {
		//healthKitService.startSession()
		
		self.collectData = true
		if self.isAccelerometerEnabled || self.isGyroscopeEnabled {
			coreMotionService.startUpdates()
		}
		if self.isGPSEnabled {
			coreLocationService.startUpdates()
		}
		data.clear()
		scheduleTimer()
		self.sessionState = .running
	}
	
	func pause() {
		//healthKitService.pauseSession()
		self.collectData = false
		if self.isAccelerometerEnabled || self.isGyroscopeEnabled {
			coreMotionService.stopUpdates()
		}
		if self.isGPSEnabled {
			coreLocationService.stopUpdates()
		}
		timer.invalidate()
		self.sessionState = .paused
	}
	
	func resume() {
		//healthKitService.resumeSession()
		self.collectData = true
		if self.isAccelerometerEnabled || self.isGyroscopeEnabled {
			coreMotionService.startUpdates()
		}
		if self.isGPSEnabled {
			coreLocationService.startUpdates()
		}
		data.clear()
		scheduleTimer()
		self.sessionState = .running
	}
	
	func stop() {
		//healthKitService.stopSession()
		self.collectData = false
		if self.isAccelerometerEnabled || self.isGyroscopeEnabled {
			coreMotionService.stopUpdates()
		}
		if self.isGPSEnabled {
			coreLocationService.stopUpdates()
		}
		timer.invalidate()
		self.sessionState = .ended
	}
	
	// MARK: - Features Extraction
	func extractFeatures(data:[DataSample]) -> [String:Any]? {
		var featuresDict = [String:Any]()
		
		let features : ([Double]) -> [String:Any] = {(data) in
			var transforms:[Double]?
			let mean = data.mean
			let variance = data.variance(mean: mean)
			let deviation = data.deviation(variance: variance)
			var dict = [String:Any]()
			
			if Preferences.includeMax {
				dict["max"] = data.max()
			}
			if Preferences.includeMin {
				dict["min"] = data.min()
			}
			if Preferences.includeMedian {
				dict["median"] = data.median
			}
			if Preferences.includeMean {
				dict["mean"] = mean
			}
			if Preferences.includeDeviation {
				dict["deviation"] = deviation
			}
			if Preferences.includeVariance {
				dict["variance"] = variance
			}
			if Preferences.includeSkewness {
				dict["skewness"] = data.skewness(mean: mean, deviation: deviation)
			}
			if Preferences.includeKurtosis {
				dict["kurtosis"] = data.kurtosis(mean: mean, deviation: deviation)
			}
			if Preferences.includeIQR {
				dict["interQuartileRange"] = data.interQuartileRange
			}
			if Preferences.includeEnergy {
				transforms = fft(data)
				dict["energy"] = data.energy(transforms: transforms!)
			}
			if Preferences.includeEntropy {
				if transforms == nil {
					transforms = fft(data)
				}
				dict["entropy"] = data.entropy(transforms: transforms!)
			}
			
			return dict
		}
		
		if Preferences.includeHeartRate {
			if let heartRate = data.map({(sample) in
				return sample.heartRate
			}).unwrapped {
				featuresDict["heartRate"] = features(heartRate)
			}
		}
		
		if Preferences.includeRoll {
			if let roll = data.map({(sample) in
				return sample.attitude?.roll
			}).unwrapped {
				featuresDict["attitude-roll"] = features(roll)
			}
		}
		
		if Preferences.includeYaw {
			if let yaw = data.map({(sample) in
				return sample.attitude?.yaw
			}).unwrapped {
				featuresDict["attitude-yaw"] = features(yaw)
			}
		}
		
		if Preferences.includePitch {
			if let pitch = data.map({(sample) in
				return sample.attitude?.pitch
			}).unwrapped {
				featuresDict["attitude-pitch"] = features(pitch)
			}
		}
		
		if Preferences.includeAttitudeMagnitude {
			if let attitude = data.map({(sample) in
				return sample.attitude?.magnitude
			}).unwrapped {
				featuresDict["attitude-magnitude"] = features(attitude)
			}
		}
		
		if Preferences.includeXRotationRate {
			if let xRotationRate = data.map({(sample) in
				return sample.rotationRate?.x
			}).unwrapped {
				featuresDict["rotationRate-x"] = features(xRotationRate)
			}
		}
		
		if Preferences.includeYRotationRate {
			if let yRotationRate = data.map({(sample) in
				return sample.rotationRate?.y
			}).unwrapped {
				featuresDict["rotationRate-y"] = features(yRotationRate)
			}
		}
		
		if Preferences.includeZRotationRate {
			if let zRotationRate = data.map({(sample) in
				return sample.rotationRate?.z
			}).unwrapped {
				featuresDict["rotationRate-z"] = features(zRotationRate)
			}
		}
		
		if Preferences.includeRotationRateMagnitude {
			if let rotationRateMagnitude = data.map({(sample) in
				return sample.rotationRate?.magnitude
			}).unwrapped {
				featuresDict["rotationRate-magnitude"] = features(rotationRateMagnitude)
			}
		}
		
		if Preferences.includeXGravity {
			if let xGravity = data.map({(sample) in
				return sample.gravity?.x
			}).unwrapped {
				featuresDict["gravity-x"] = features(xGravity)
			}
		}
		
		if Preferences.includeYGravity {
			if let yGravity = data.map({(sample) in
				return sample.gravity?.y
			}).unwrapped {
				featuresDict["gravity-y"] = features(yGravity)
			}
		}
		
		if Preferences.includeZGravity {
			if let zGravity = data.map({(sample) in
				return sample.gravity?.z
			}).unwrapped {
				featuresDict["gravity-z"] = features(zGravity)
			}
		}
		
		if Preferences.includeGravityMagnitude {
			if let gravityMagnitude = data.map({(sample) in
				return sample.gravity?.magnitude
			}).unwrapped {
				featuresDict["gravity-magnitude"] = features(gravityMagnitude)
			}
		}
		
		if Preferences.includeXUserAcceleration {
			if let xUserAcceleration = data.map({(sample) in
				return sample.userAcceleration?.x
			}).unwrapped {
				featuresDict["userAcceleration-x"] = features(xUserAcceleration)
			}
		}
		
		if Preferences.includeYUserAcceleration {
			if let yUserAcceleration = data.map({(sample) in
				return sample.userAcceleration?.y
			}).unwrapped {
				featuresDict["userAcceleration-y"] = features(yUserAcceleration)
			}
		}
		
		if Preferences.includeZUserAcceleration {
			if let zUserAcceleration = data.map({(sample) in
				return sample.userAcceleration?.z
			}).unwrapped {
				featuresDict["userAcceleration-z"] = features(zUserAcceleration)
			}
		}
		
		if Preferences.includeUserAccelerationMagnitude {
			if let userAccelerationMagnitude = data.map({(sample) in
				return sample.userAcceleration?.magnitude
			}).unwrapped {
				featuresDict["userAcceleration-magnitude"] = features(userAccelerationMagnitude)
			}
		}
		
		if Preferences.includeLatitude {
			if let latitude = data.map({(sample) in
				return sample.coordinate?.latitude
			}).unwrapped {
				featuresDict["coordinate-latitude"] = features(latitude)
			}
		}
		
		if Preferences.includeLongitude {
			if let longitude = data.map({(sample) in
				return sample.coordinate?.longitude
			}).unwrapped {
				featuresDict["coordinate-longitude"] = features(longitude)
			}
		}
		
		if Preferences.includeAltitude {
			if let altitude = data.map({(sample) in
				return sample.altitude
			}).unwrapped {
				featuresDict["altitude"] = features(altitude)
			}
		}
		
		if Preferences.includeCourse {
			if let course = data.map({(sample) in
				return sample.course
			}).unwrapped {
				featuresDict["course"] = features(course)
			}
		}
		
		if Preferences.includeSpeed {
			if let speed = data.map({(sample) in
				return sample.speed
			}).unwrapped {
				featuresDict["speed"] = features(speed)
			}
		}
		
		return featuresDict
	}
#endif
	
	// MARK: - Authorizations
	static var _locationService:CoreLocationService?
	static var locationService:CoreLocationService {
		if _locationService == nil {
			_locationService = CoreLocationService()
		}
		return _locationService!
	}
	
	class func checkAuthorizations() -> Bool {
		let checkAuthorizationsLambda = {() -> Bool in
			if !HealthKitService.isAuthorized {
				HealthKitService.authorizeHealthKitAccess({(success,error) in
					if success {
						print("HealthKit has been succesfully authorized")
					} else {
						print("HealthKit authorization denied!")
						if let error = error {
							print("\(String(describing: error))")
						}
					}
				})
				return false
			}
			
			if !locationService.isAuthorized {
				locationService.requestAuthorization()
				return false
			}
			
			return true
		}
		
		if Thread.current.isMainThread {
			return checkAuthorizationsLambda()
		} else {
			var result:Bool = false
			DispatchQueue.main.sync {
				result = checkAuthorizationsLambda()
			}
			return result
		}
	}
}











