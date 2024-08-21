//
//  BaseModel.swift
//  bili
//
//  Created by DJ on 2024/8/19.
//

import Foundation

protocol DefaultValue {
    associatedtype Value: Codable
    static var defaultValue: Value { get }
}

@propertyWrapper
struct Default<T: DefaultValue> {
    var wrappedValue: T.Value
}

extension Default: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = (try? container.decode(T.Value.self)) ?? T.defaultValue
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

extension KeyedDecodingContainer {
    func decode<T>(_ type: Default<T>.Type, forKey key: Key) throws -> Default<T> where T: DefaultValue {
        //判断 key 缺失的情况，提供默认值
        (try decodeIfPresent(type, forKey: key)) ?? Default(wrappedValue: T.defaultValue)
    }
    
}


extension Int: DefaultValue {
    static var defaultValue = -1
}

extension String: DefaultValue {
    static var defaultValue = "unknown"
}

extension Bool: DefaultValue {
    static var defaultValue = false
}

extension Double: DefaultValue {
    static var defaultValue = 0.0
}

//struct Person: Decodable {
//    @Default<String> var name: String
//    @Default<Int> var age: Int
//}


//let data = #"{ "name": null, "age": null}"#
//let p = try JSONDecoder().decode(Person.self, from: data.data(using: .utf8)!)
//print(p, p.name, p.age)
//Person(_name: Default<Swift.String>(wrappedValue: "unknown"), _age: Default<Swift.Int>(wrappedValue: -1))
//unknown  -1


/*model嵌套改层级
struct UserResponse: Decodable {
    let sexStatus: String
    let anotherValue: String

    enum CodingKeys: String, CodingKey {
        case sexStatus
        case details
    }

    enum DetailsKeys: String, CodingKey {
        case anotherValue = "another_value"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sexStatus = try container.decode(String.self, forKey: .sexStatus)

        // 处理嵌套的 details
        let detailsContainer = try container.nestedContainer(keyedBy: DetailsKeys.self, forKey: .details)
        anotherValue = try detailsContainer.decode(String.self, forKey: .anotherValue)
    }
}

// 使用示例
let jsonData = """
{
    "user": {
        "sexStatus": "male",
        "details": {
            "another_value": "some_value"
        }
    }
}
""".data(using: .utf8)!

struct Response: Decodable {
    let user: UserResponse
}

do {
    let response = try JSONDecoder().decode(Response.self, from: jsonData)
    print(response.user.sexStatus) // 输出: male
    print(response.user.anotherValue) // 输出: some_value
} catch {
    print("Error decoding JSON: \(error)")
}
 */
