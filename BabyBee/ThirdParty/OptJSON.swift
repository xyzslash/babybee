//
//  OptJSON.swift
//  OptJSON
//
//  Created by max on 26.06.14.
//
//

import Foundation

public protocol JSONValue {
    subscript(key: String) -> JSONValue? { get }
    subscript(index: Int) -> JSONValue? { get }
}

extension NSNull : JSONValue {
    public subscript(key: String) -> JSONValue? { return nil }
    public subscript(index: Int) -> JSONValue? { return nil }
}

extension NSNumber : JSONValue {
    public subscript(key: String) -> JSONValue? { return nil }
    public subscript(index: Int) -> JSONValue? { return nil }
}

extension NSString : JSONValue {
    public subscript(key: String) -> JSONValue? { return nil }
    public subscript(index: Int) -> JSONValue? { return nil }
}

extension NSArray : JSONValue {
    public subscript(key: String) -> JSONValue? { return nil }
    public subscript(index: Int) -> JSONValue? { return index < count && index >= 0 ? JSON(self[index]) : nil }
}

extension NSDictionary : JSONValue {
    public subscript(key: String) -> JSONValue? { return JSON(self[key] as Any?) }
    public subscript(index: Int) -> JSONValue? { return nil }
}

public func JSON(_ object: Any?) -> JSONValue? {
    if let some: Any = object {
        switch some {
        case let null as NSNull:        return null
        case let number as NSNumber:    return number
        case let string as NSString:    return string
        case let array as NSArray:      return array
        case let dict as NSDictionary:  return dict
        default:                        return nil
        }
    } else {
        return nil
    }
}
