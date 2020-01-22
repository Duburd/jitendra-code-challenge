//
//  NetworkReachability.swift
//  MapApp
//
//  Created by Jitendra Kumar on 21/01/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//
#if !(os(watchOS) || os(Linux))
import Foundation
import SystemConfiguration

/// The `NetworkReachability` class listens for reachability changes of hosts and addresses for both cellular and
/// WiFi network interfaces.
///
/// Reachability can be used to determine background information about why a network operation failed, or to retry
/// network requests when a connection is established. It should not be used to prevent a user from initiating a network
/// request, as it's possible that an initial request may be required to establish reachability.
open class NetworkReachability {
    /// Defines the various states of network reachability.
    public enum NetworkReachabilityStatus {
        /// It is unknown whether the network is reachable.
        case unknown
        /// The network is not reachable.
        case notReachable
        /// The network is reachable on the associated `ConnectionType`.
        case reachable(ConnectionType)
        
        init(_ flags: SCNetworkReachabilityFlags) {
            guard flags.isActuallyReachable else { self = .notReachable; return }
            
            var networkStatus: NetworkReachabilityStatus = .reachable(.ethernetOrWiFi)
            
            if flags.isCellular { networkStatus = .reachable(.cellular) }
            
            self = networkStatus
        }
        
        /// Defines the various connection types detected by reachability flags.
        public enum ConnectionType {
            /// The connection type is either over Ethernet or WiFi.
            case ethernetOrWiFi
            /// The connection type is a cellular connection.
            case cellular
        }
    }
    
    /// A closure executed when the network reachability status changes. The closure takes a single argument: the
    /// network reachability status.
    public typealias Listener = (NetworkReachabilityStatus) -> Void
    
    /// Default `NetworkReachabilityManager` for the zero address and a `listenerQueue` of `.main`.
    public static let `default` = NetworkReachability()
    
    // MARK: - Properties
    /// Whether the network is currently reachable.
    open var isReachable: Bool { return isReachableOnCellular || isReachableOnEthernetOrWiFi }
    
    /// Whether the network is currently reachable over the cellular interface.
    ///
    /// - Note: Using this property to decide whether to make a high or low bandwidth request is not recommended.
    ///         Instead, set the `allowsCellularAccess` on any `URLRequest`s being issued.
    ///
    open var isReachableOnCellular: Bool { return status == .reachable(.cellular) }
    
    /// Whether the network is currently reachable over Ethernet or WiFi interface.
    open var isReachableOnEthernetOrWiFi: Bool { return status == .reachable(.ethernetOrWiFi) }
    
    /// `DispatchQueue` on which reachability will update.
    public let reachabilityQueue = DispatchQueue(label: "org.alamofire.reachabilityQueue")
    
    /// Flags of the current reachability type, if any.
    open var flags: SCNetworkReachabilityFlags? {
        var flags = SCNetworkReachabilityFlags()
        
        return (SCNetworkReachabilityGetFlags(reachability, &flags)) ? flags : nil
    }
    
    /// The current network reachability status.
    open var status: NetworkReachabilityStatus {
        return flags.map(NetworkReachabilityStatus.init) ?? .unknown
    }
    
    /// A closure executed when the network reachability status changes.
    private var listener: Listener?
    
    /// `DispatchQueue` on which listeners will be called.
    private var listenerQueue: DispatchQueue?
    
    /// `SCNetworkReachability` instance providing notifications.
    private let reachability: SCNetworkReachability
    
    /// Protected storage for the previous status.
    private let previousStatus = Protector<NetworkReachabilityStatus?>(nil)
    
    // MARK: - Initialization
    /// Creates an instance with the specified host.
    ///
    /// - Note: The `host` value must *not* contain a scheme, just the hostname.
    ///
    /// - Parameters:
    ///   - host:          Host used to evaluate network reachability. Must *not* include the scheme (e.g. `https`).
    public convenience init?(host: String) {
        guard let reachability = SCNetworkReachabilityCreateWithName(nil, host) else { return nil }
        
        self.init(reachability: reachability)
    }
    
    /// Creates an instance that monitors the address 0.0.0.0.
    ///
    /// Reachability treats the 0.0.0.0 address as a special token that causes it to monitor the general routing
    /// status of the device, both IPv4 and IPv6.
    public convenience init?() {
        var zero = sockaddr()
        zero.sa_len = UInt8(MemoryLayout<sockaddr>.size)
        zero.sa_family = sa_family_t(AF_INET)
        
        guard let reachability = SCNetworkReachabilityCreateWithAddress(nil, &zero) else { return nil }
        
        self.init(reachability: reachability)
    }
    
    private init(reachability: SCNetworkReachability) {
        self.reachability = reachability
    }
    
    deinit {
        stopListening()
    }
    
    // MARK: - Listening
    /// Starts listening for changes in network reachability status.
    ///
    /// - Note: Stops and removes any existing listener.
    ///
    /// - Parameters:
    ///   - queue:    `DispatchQueue` on which to call the `listener` closure. `.main` by default.
    ///   - listener: `Listener` closure called when reachability changes.
    ///
    /// - Returns: `true` if listening was started successfully, `false` otherwise.
    @discardableResult
    open func startListening(onQueue queue: DispatchQueue = .main,
                             onUpdatePerforming listener: @escaping Listener) -> Bool {
        stopListening()
        
        listenerQueue = queue
        self.listener = listener
        
        var context = SCNetworkReachabilityContext(version: 0,
                                                   info: Unmanaged.passRetained(self).toOpaque(),
                                                   retain: nil,
                                                   release: nil,
                                                   copyDescription: nil)
        let callback: SCNetworkReachabilityCallBack = { (target, flags, info) in
            guard let info = info else { return }
            
            let instance = Unmanaged<NetworkReachability>.fromOpaque(info).takeUnretainedValue()
            instance.notifyListener(flags)
        }
        
        let queueAdded = SCNetworkReachabilitySetDispatchQueue(reachability, reachabilityQueue)
        let callbackAdded = SCNetworkReachabilitySetCallback(reachability, callback, &context)
        
        // Manually call listener to give initial state, since the framework may not.
        if let currentFlags = flags {
            reachabilityQueue.async {
                self.notifyListener(currentFlags)
            }
        }
        
        return callbackAdded && queueAdded
    }
    
    /// Stops listening for changes in network reachability status.
    open func stopListening() {
        SCNetworkReachabilitySetCallback(reachability, nil, nil)
        SCNetworkReachabilitySetDispatchQueue(reachability, nil)
        previousStatus.write { $0 = nil }
        listenerQueue = nil
        listener = nil
    }
    
    // MARK: - Internal - Listener Notification
    
    /// Calls the `listener` closure of the `listenerQueue` if the computed status hasn't changed.
    ///
    /// - Note: Should only be called from the `reachabilityQueue`.
    ///
    /// - Parameter flags: `SCNetworkReachabilityFlags` to use to calculate the status.
    func notifyListener(_ flags: SCNetworkReachabilityFlags) {
        let newStatus = NetworkReachabilityStatus(flags)
        
        previousStatus.write { previousStatus in
            guard previousStatus != newStatus else { return }
            
            previousStatus = newStatus
            
            listenerQueue?.async { self.listener?(newStatus) }
        }
    }
}

// MARK: -
extension NetworkReachability.NetworkReachabilityStatus: Equatable { }

extension SCNetworkReachabilityFlags {
    var isReachable: Bool { return contains(.reachable) }
    var isConnectionRequired: Bool { return contains(.connectionRequired) }
    var canConnectAutomatically: Bool { return contains(.connectionOnDemand) || contains(.connectionOnTraffic) }
    var canConnectWithoutUserInteraction: Bool { return canConnectAutomatically && !contains(.interventionRequired) }
    var isActuallyReachable: Bool { return isReachable && (!isConnectionRequired || canConnectWithoutUserInteraction) }
    var isCellular: Bool {
        #if os(iOS) || os(tvOS)
        return contains(.isWWAN)
        #else
        return false
        #endif
    }
    
    /// Human readable `String` for all states, to help with debugging.
    var readableDescription: String {
        let W = isCellular ? "W" : "-"
        let R = isReachable ? "R" : "-"
        let c = isConnectionRequired ? "c" : "-"
        let t = contains(.transientConnection) ? "t" : "-"
        let i = contains(.interventionRequired) ? "i" : "-"
        let C = contains(.connectionOnTraffic) ? "C" : "-"
        let D = contains(.connectionOnDemand) ? "D" : "-"
        let l = contains(.isLocalAddress) ? "l" : "-"
        let d = contains(.isDirect) ? "d" : "-"
        let a = contains(.connectionAutomatic) ? "a" : "-"
        
        return "\(W)\(R) \(c)\(t)\(i)\(C)\(D)\(l)\(d)\(a)"
    }
}
#endif
// MARK: -
/// An `os_unfair_lock` wrapper.
final class UnfairLock {
    private let unfairLock: os_unfair_lock_t
    
    init() {
        unfairLock = .allocate(capacity: 1)
        unfairLock.initialize(to: os_unfair_lock())
    }
    
    deinit {
        unfairLock.deinitialize(count: 1)
        unfairLock.deallocate()
    }
    
    fileprivate func lock() {
        os_unfair_lock_lock(unfairLock)
    }
    
    fileprivate func unlock() {
        os_unfair_lock_unlock(unfairLock)
    }
    
    /// Executes a closure returning a value while acquiring the lock.
    ///
    /// - Parameter closure: The closure to run.
    ///
    /// - Returns:           The value the closure generated.
    func around<T>(_ closure: () -> T) -> T {
        lock(); defer { unlock() }
        return closure()
    }
    
    /// Execute a closure while acquiring the lock.
    ///
    /// - Parameter closure: The closure to run.
    func around(_ closure: () -> Void) {
        lock(); defer { unlock() }
        return closure()
    }
}

/// A thread-safe wrapper around a value.
final class Protector<T> {
    private let lock = UnfairLock()
    private var value: T
    
    init(_ value: T) {
        self.value = value
    }
    
    /// The contained value. Unsafe for anything more than direct read or write.
    var directValue: T {
        get { return lock.around { value } }
        set { lock.around { value = newValue } }
    }
    
    /// Synchronously read or transform the contained value.
    ///
    /// - Parameter closure: The closure to execute.
    ///
    /// - Returns:           The return value of the closure passed.
    func read<U>(_ closure: (T) -> U) -> U {
        return lock.around { closure(self.value) }
    }
    
    /// Synchronously modify the protected value.
    ///
    /// - Parameter closure: The closure to execute.
    ///
    /// - Returns:           The modified value.
    @discardableResult
    func write<U>(_ closure: (inout T) -> U) -> U {
        return lock.around { closure(&self.value) }
    }
}

extension Protector where T: RangeReplaceableCollection {
    /// Adds a new element to the end of this protected collection.
    ///
    /// - Parameter newElement: The `Element` to append.
    func append(_ newElement: T.Element) {
        write { (ward: inout T) in
            ward.append(newElement)
        }
    }
    
    /// Adds the elements of a sequence to the end of this protected collection.
    ///
    /// - Parameter newElements: The `Sequence` to append.
    func append<S: Sequence>(contentsOf newElements: S) where S.Element == T.Element {
        write { (ward: inout T) in
            ward.append(contentsOf: newElements)
        }
    }
    
    /// Add the elements of a collection to the end of the protected collection.
    ///
    /// - Parameter newElements: The `Collection` to append.
    func append<C: Collection>(contentsOf newElements: C) where C.Element == T.Element {
        write { (ward: inout T) in
            ward.append(contentsOf: newElements)
        }
    }
}


