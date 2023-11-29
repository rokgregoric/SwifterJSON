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

  public convenience init() {
    self.init(obj: nil)
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

  required public convenience init(from decoder: Decoder) throws {
    var object: Any?

    if let container = try? decoder.singleValueContainer(), !container.decodeNil() {
      for type in JSON.codableTypes {
        if object != nil {
          break
        }
        // try to decode value
        switch type {
          case let boolType as Bool.Type:
            object = try? container.decode(boolType)
          case let intType as Int.Type:
            object = try? container.decode(intType)
          case let int8Type as Int8.Type:
            object = try? container.decode(int8Type)
          case let int32Type as Int32.Type:
            object = try? container.decode(int32Type)
          case let int64Type as Int64.Type:
            object = try? container.decode(int64Type)
          case let uintType as UInt.Type:
            object = try? container.decode(uintType)
          case let uint8Type as UInt8.Type:
            object = try? container.decode(uint8Type)
          case let uint16Type as UInt16.Type:
            object = try? container.decode(uint16Type)
          case let uint32Type as UInt32.Type:
            object = try? container.decode(uint32Type)
          case let uint64Type as UInt64.Type:
            object = try? container.decode(uint64Type)
          case let doubleType as Double.Type:
            object = try? container.decode(doubleType)
          case let stringType as String.Type:
            object = try? container.decode(stringType)
          case let jsonValueArrayType as [JSON].Type:
            object = try? container.decode(jsonValueArrayType)
          case let jsonValueDictType as [String: JSON].Type:
            object = try? container.decode(jsonValueDictType)
          default:
            break
        }
      }
    }
    self.init(object ?? NSNull())
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

  public var decimal: Decimal? { return obj as? Decimal }
  public var decimalValue: Decimal { return decimal ?? numberValue.decimalValue }

  public var decimalNumber: NSDecimalNumber? { return obj as? NSDecimalNumber }
  public var decimalNumberValue: NSDecimalNumber { return decimalNumber ?? decimalValue as NSDecimalNumber }

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

  public static var defaultOptions: JSONSerialization.WritingOptions {
    if #available(iOS 11.0, macOS 10.13, *) {
      return [.sortedKeys, .prettyPrinted]
    }
    return [.prettyPrinted]
  }

  public func rawString(_ encoding: String.Encoding = .utf8, options opt: JSONSerialization.WritingOptions = defaultOptions) -> String? {
    guard let obj = obj else { return nil }
    guard JSONSerialization.isValidJSONObject(obj) else { return nil }
    let data = try? JSONSerialization.data(withJSONObject: obj, options: opt)
    return data.flatMap { String(data: $0, encoding: encoding) }
  }
}

// MARK: - CustomStringConvertible, CustomDebugStringConvertible

extension JSON: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    return rawString() ?? "nil"
  }

  public var debugDescription: String {
    return description
  }
}

// MARK: - Codable

extension JSON: Codable {
  private static var codableTypes: [Codable.Type] {
    return [
      Bool.self,
      Int.self,
      Int8.self,
      Int16.self,
      Int32.self,
      Int64.self,
      UInt.self,
      UInt8.self,
      UInt16.self,
      UInt32.self,
      UInt64.self,
      Double.self,
      String.self,
      [JSON].self,
      [String: JSON].self
    ]
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    if object is NSNull {
      try container.encodeNil()
      return
    }
    switch object {
      case let intValue as Int:
        try container.encode(intValue)
      case let int8Value as Int8:
        try container.encode(int8Value)
      case let int32Value as Int32:
        try container.encode(int32Value)
      case let int64Value as Int64:
        try container.encode(int64Value)
      case let uintValue as UInt:
        try container.encode(uintValue)
      case let uint8Value as UInt8:
        try container.encode(uint8Value)
      case let uint16Value as UInt16:
        try container.encode(uint16Value)
      case let uint32Value as UInt32:
        try container.encode(uint32Value)
      case let uint64Value as UInt64:
        try container.encode(uint64Value)
      case let doubleValue as Double:
        try container.encode(doubleValue)
      case let boolValue as Bool:
        try container.encode(boolValue)
      case let stringValue as String:
        try container.encode(stringValue)
      case is [Any]:
        let jsonValueArray = array ?? []
        try container.encode(jsonValueArray)
      case is [String: Any]:
        let jsonValueDictValue = dictionary ?? [:]
        try container.encode(jsonValueDictValue)
      default:
        break
    }
  }
}

// MARK: - Hashable

extension JSON: Hashable {
  public static func == (lhs: JSON, rhs: JSON) -> Bool {
    lhs.description == rhs.description
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(description)
  }
}
