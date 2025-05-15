//
//  File.swift
//  
//
//  Created by Damon on 2022/1/13.
//

import Vapor
import Fluent

public final class DDLoggerModel: Model {
    public static let schema = "DDLoggerModel"
    public init() {
        level = ""
        message = ""
        uuid = ""
        createTime = Date().timeIntervalSince1970    //时间戳
    }

    @ID(custom: "id")
    public var id: Int?    //数据库存储的ID
    @Field(key: "level")
    var level: String
    @Field(key: "message")
    var message: String
    @Field(key: "uuid")
    var uuid: String
    @Field(key: "createTime")
    var createTime: Double  //时间

}

public class DDLoggerCreateModel: Migration {
    public func prepare(on database: Database) -> EventLoopFuture<Void> {
        return database.schema("DDLoggerModel").field("id", .int, .identifier(auto: true)).field("level", .string, .required).field("message", .string, .required).field("uuid", .string, .required).field("createTime", .double, .required).create()
    }

    public func revert(on database: Database) -> EventLoopFuture<Void> {
        return database.eventLoop.future()
    }
}
