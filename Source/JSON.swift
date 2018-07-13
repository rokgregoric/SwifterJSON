//
//  JSON.swift
//
//  Created by Rok Gregoric on 12/04/2018.
//  Copyright © 2018 Rok Gregoric. All rights reserved.
//

import Foundation

public class JSON {
  var obj: Any?

  fileprivate init(obj: Any?) {
    self.obj = obj
  }

  public convenience init(_ obj: Any?) {
    if let data = obj as? Data {
      self.init(data: data)
    } else {
      self.init(obj: obj)
    }
  }

  public convenience init(data: Data, options opt: JSONSerialization.ReadingOptions = []) {
    self.init(obj: try? JSONSerialization.jsonObject(with: data, options: opt))
  }

  public convenience init(parseJSON string: String) {
    self.init(string.data(using: .utf8))
  }

  public subscript(_ key: String) -> JSON {
    return JSON((obj as? NSDictionary)?[key])
  }

  public var object: Any? { return obj is NSNull ? nil : obj }

  public var arrayObject: [Any]? { return obj as? [Any] }
  public var array: [JSON]? { return arrayObject?.map { JSON($0) } }
  public var arrayValue: [JSON] { return array ?? [] }

  public var dictionaryObject: [String: Any]? { return obj as? [String: Any] }
  public var dictionary: [String: JSON]? {
    guard let dic = dictionaryObject else { return nil }
    var d = [String: JSON](minimumCapacity: dic.count)
    for (key, value) in dic {
      d[key] = JSON(value)
    }
    return d
  }
  public var dictionaryValue: [String: JSON] { return dictionary ?? [:] }

  public var string: String? { return obj as? String }
  public var stringValue: String { return string ?? "" }

  public var number: NSNumber? { return obj as? NSNumber }
  public var numberValue: NSNumber { return number ?? NumberFormatter().number(from: stringValue) ?? 0 }

  public var bool: Bool? { return obj as? Bool }
  public var boolValue: Bool { return bool ?? Bool(stringValue) ?? false }

  public var double: Double? { return obj as? Double }
  public var doubleValue: Double { return double ?? Double(stringValue) ?? 0 }

  public var float: Float? { return obj as? Float }
  public var floatValue: Float { return float ?? Float(stringValue) ?? 0 }

  public var int: Int? { return obj as? Int }
  public var intValue: Int { return int ?? Int(stringValue) ?? 0 }

  public var uInt: UInt? { return obj as? UInt }
  public var uIntValue: UInt { return uInt ?? UInt(stringValue) ?? 0 }

  public var int8: Int8? { return obj as? Int8 }
  public var int8Value: Int8 { return int8 ?? Int8(stringValue) ?? 0 }

  public var uInt8: UInt8? { return obj as? UInt8 }
  public var uInt8Value: UInt8 { return uInt8 ?? UInt8(stringValue) ?? 0 }

  public var int16: Int16? { return obj as? Int16 }
  public var int16Value: Int16 { return int16 ?? Int16(stringValue) ?? 0 }

  public var uInt16: UInt16? { return obj as? UInt16 }
  public var uInt16Value: UInt16 { return uInt16 ?? UInt16(stringValue) ?? 0 }

  public var int32: Int32? { return obj as? Int32 }
  public var int32Value: Int32 { return int32 ?? Int32(stringValue) ?? 0 }

  public var uInt32: UInt32? { return obj as? UInt32 }
  public var uInt32Value: UInt32 { return uInt32 ?? UInt32(stringValue) ?? 0 }

  public var int64: Int64? { return obj as? Int64 }
  public var int64Value: Int64 { return int64 ?? Int64(stringValue) ?? 0 }

  public var uInt64: UInt64? { return obj as? UInt64 }
  public var uInt64Value: UInt64 { return uInt64 ?? UInt64(stringValue) ?? 0 }

  public var url: URL? {
    guard let str = string else { return nil }

    // Check for existing percent escapes first to prevent double-escaping of % character
    if str.range(of: "%[0-9A-Fa-f]{2}", options: .regularExpression, range: nil, locale: nil) != nil {
      return URL(string: str)
    }
    return str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed).flatMap { URL(string: $0) }
  }

  public func rawString(_ encoding: String.Encoding = .utf8, options opt: JSONSerialization.WritingOptions = .prettyPrinted) -> String? {
    guard let obj = obj else { return nil }
    guard JSONSerialization.isValidJSONObject(obj) else { return nil }
    let data = try? JSONSerialization.data(withJSONObject: obj, options: opt)
    return data.flatMap { String(data: $0, encoding: .utf8) }
  }
}

// MARK: - Printable, DebugPrintable

extension JSON: Swift.CustomStringConvertible, Swift.CustomDebugStringConvertible {
  public var description: String {
    return rawString(options: .prettyPrinted) ?? "unknown"
  }

  public var debugDescription: String {
    return description
  }
}

