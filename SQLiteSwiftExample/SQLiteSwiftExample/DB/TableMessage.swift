//
//  TableMessage.swift
//  SQLiteSwiftExample
//
//  Created by ShenYj on 2021/03/03.
//
//  Copyright (c) 2021 ShenYj <shenyanjie123@foxmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import SQLite
import SwiftDate

internal struct TableMessage {
    
    static var table: Table = Table(SQLiteTableName[.messages])
    
    /// Column
    static let primary_key              = Expression<Int>("primary_key")
    static let message_code             = Expression<String>("message_code")
    static let message_title            = Expression<String>("message_title")
    static let message_detail           = Expression<String>("message_detail")
    static let message_unread           = Expression<Bool>("message_unread")
    
    /// Alter
    static let message_new_column       = Expression<String>("message_new_column")
    
}

extension TableMessage: DataOperateable {
    
    typealias T = Message
    
    ///
    /// 创建表
    ///
    static func createTable() throws {
        guard let db = DataBaseManager.shared.dbConnection else { throw DBError.connectError }
        do {
            let _ = try db.run(table.create(ifNotExists: true) { ( table ) in
                table.column(primary_key, primaryKey: true)
                table.column(message_code, unique: true, defaultValue: nil)
                table.column(message_title, defaultValue: "")
                table.column(message_detail, defaultValue: "")
                table.column(message_unread, defaultValue: true)
            })
        } catch _ {
            throw DBError.createTableError
        }
        // db.trace { print($0) }
        
        log.debug("当前数据库版本: \(db.userVersion)")
        // 补丁 let stmt = try db.prepare("PRAGMA table_info([t_messages])")
        // let result = try? db.run(table.addColumn(message_unread, defaultValue: true))
        // log.verbose("表新增列: \(String(describing: result))")
    }
    
    ///
    /// 删除表
    ///
    static func dropTable() throws {
        guard let db = DataBaseManager.shared.dbConnection else { throw DBError.connectError }
        do {
            try db.run(table.drop(ifExists: true))
            log.debug("删除表成功")
        } catch {
            log.debug("删除表失败")
            throw DBError.dropTableError
        }
    }
    
    /// 插入消息
    ///
    /// - Note: 只插入, 如果存在会插入失败
    ///
    /// - Returns: 插入的`row id`
    ///
    static func insert(item: Message) throws -> Int64 {
        guard let db = DataBaseManager.shared.dbConnection else { throw DBError.connectError }
        guard let unique_code = item.message_code else { throw DBError.invalidDataError }
        
        let row = table.insert(
            message_code <- unique_code,
            message_title <- item.message_title ?? "",
            message_detail <- item.message_detail ?? "",
            message_unread <- item.message_unread
        )

        do {
            let rowID = try db.run(row)
            return rowID
        } catch { throw DBError.insertError }
    }
    
    ///
    /// 更新消息
    ///
    /// - Returns: The number of updated rows.
    ///
    static func update(item: Message) throws -> Int {
        guard let db = DataBaseManager.shared.dbConnection else { throw DBError.connectError }
        guard let unique_code = item.message_code else { throw DBError.invalidDataError }
        
        let update = table.filter(message_code == unique_code)
        let row = update.update(
            message_title <- item.message_title ?? "",
            message_detail <- item.message_detail ?? "",
            message_unread <- item.message_unread
        )
        
        do {
            let rows = try db.run(row)
            return rows
        } catch { throw DBError.updateError }
    }
    
    ///
    /// 删除消息
    ///
    static func delete(item: Message) throws {
        guard let db = DataBaseManager.shared.dbConnection else { throw DBError.connectError }
        guard let unique_code = item.message_code else { throw DBError.invalidDataError }
        let query = table.filter(message_code == unique_code)
        do {
            let tmp = try db.run(query.delete())
            guard tmp == 1 else { throw DBError.deleteError }
            log.debug("删除成功")
        } catch { throw DBError.deleteError }
    }
    
    ///
    /// 删除全部
    ///
    static func deleteAll() throws -> Int {
        guard let db = DataBaseManager.shared.dbConnection else { throw DBError.connectError }
        do {
            return try db.run(table.delete())
        } catch { throw DBError.dropTableError }
    }
    
    static func totalCount() throws -> Int {
        guard let db = DataBaseManager.shared.dbConnection else { throw DBError.connectError }
        do {
            let count = try db.scalar(table.count)
            log.debug("row总数: \(String(describing: count))")
            return count
        } catch { throw DBError.queryError }
    }
    
    ///
    /// 查找全部
    ///
    static func findAll() throws -> [Message]? {
        guard let db = DataBaseManager.shared.dbConnection else { throw DBError.connectError }
        do {
            var allMessages: Array<Message> = Array()
            let accounts = try db.prepare(table)
            for item in accounts {
                var map = [String: Any]()
                map["message_code"] = item[message_code]
                map["message_title"] = item[message_title]
                map["message_detail"] = item[message_detail]
                map["message_unread"] = item[message_unread]
                if let account = Message.init(JSON: map) {
                    allMessages.append(account)
                }
            }
            log.debug("查询全部消息: \(allMessages.count)条")
            return allMessages
        } catch { throw DBError.queryError }
    }

    
    static func findWithCodeAndTitle() throws -> [Message]? {
        guard let db = DataBaseManager.shared.dbConnection else { throw DBError.connectError }
        do {
            var allMessages: Array<Message> = Array()
            let query = table.filter(message_code == "106" && message_title == "消息5")
            let accounts = try db.prepare(query)
            for item in accounts {
                var map = [String: Any]()
                map["message_code"] = item[message_code]
                map["message_title"] = item[message_title]
                map["message_detail"] = item[message_detail]
                map["message_unread"] = item[message_unread]
                if let account = Message.init(JSON: map) {
                    allMessages.append(account)
                }
            }
            log.debug("查询满足条件的全部消息: \(allMessages.count)条")
            return allMessages
        } catch { throw DBError.queryError }
    }
}


extension TableMessage {
    
    
    /// 批量写入消息
    ///
    /// - Note: 有则更新, 无则写入
    ///
    ///         1. 无效数据忽略
    ///         2. 空数据直接返回
    ///
    static func transaction_insert_update(messages: [Message], updateFlag: Bool = false) throws {
        guard let db = DataBaseManager.shared.dbConnection else { throw DBError.connectError }
        guard messages.count > 0 else { return }
        do {
            
            try db.transaction {
                log.debug(" 1. 将插入\(messages.count)条消息 ")
                for message in messages {
                    
                    // 编号无效, 忽略, 处理下一条
                    guard let valid_code = message.message_code else { continue }
                    
                    let query = table.filter(message_code == valid_code)
                    let rows = Array(try db.prepare(query))
                    log.debug(" 2. 检查消息编号\(valid_code)是否存在 - \(rows.count)条(DB)")
                    if rows.count > 0 {
                        if updateFlag == false { continue }
                        else {
                            let updateRows = try update(item: message)
                            log.debug(" 3. 更新\(updateRows)条 - 消息Code: \(valid_code)")
                        }
                    }
                    else {
                        let insertRows = try? insert(item: message)
                        log.debug(" 3. 插入Row ID\(insertRows ?? 0) - 消息Code: \(valid_code)")
                    }
                }
            }
        }
        catch {
            log.error("事务处理失败")
            throw DBError.transactionError
        }
    }
    
}



extension TableMessage {
    
    static func createTable(with sql: String) throws {
        guard let db = DataBaseManager.shared.dbConnection else { throw DBError.connectError }
        
        // 补丁 let stmt = try db.prepare("PRAGMA table_info([t_messages])")
        //let result = try? db.run(table.addColumn(message_unread, defaultValue: true))
        //log.verbose("表新增列: \(String(describing: result))")
        do {
            try db.execute(sql)
            log.debug("sql语句创建表成功")
        }
        catch {
            log.error("sql语句创建表失败")
            throw DBError.createTableError
        }
    }

}

extension TableMessage {
    
    static func alterNewColumn() throws {
        // 补丁 let stmt = try db.prepare("PRAGMA table_info([t_messages])")
        guard let db = DataBaseManager.shared.dbConnection else { throw DBError.connectError }
        
        guard db.userVersion < 1 else {
            log.debug("当前数据库版本: \(db.userVersion)")
            return
        }
        
        log.debug("当前数据库版本: \(db.userVersion)")
        do {
            
            let result = try db.run(table.addColumn(message_new_column, defaultValue: ""))
            log.verbose("消息表新增列: \(String(describing: result))")
            db.userVersion = 1
            log.warning("添加列成功")
        }
        catch {
            log.warning("添加列失败")
        }
    }
}
