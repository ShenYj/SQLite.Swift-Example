//
//  DataBaseManager.swift
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
//
//  Seealso: `http://masteringswift.blogspot.com/2015/09/create-data-access-layer-with.html`
//  Seealso: `https://github.com/stephencelis/SQLite.swift/blob/master/Documentation/Index.md#column-constraints`

import SQLite
import SBLibrary

enum SQLiteTableName: String {
    
    /// 表名
    case messages = "t_messages"
    
    static subscript(tableName: SQLiteTableName) -> String { tableName.rawValue }
}

internal class DataBaseManager {
    
    /// 全局访问点
    static let shared: DataBaseManager = DataBaseManager()
    /// 数据库存放路径
    private var path: String = ""
    /// 数据库对象
    var dbConnection: Connection?
    
    private init() {
        
        path = FileManager.default.documentDirectory?.appending("/example_db.sqlite3") ?? ""
        debugPrint("数据库路径 ====>: \(path)")
        
        do {
            /// 使用数据库的路径初始化连接。 SQLite将尝试创建数据库文件（如果尚不存在）
            dbConnection = try Connection(path)
            dbConnection?.busyTimeout = 5
            dbConnection?.busyHandler({ (tries) -> Bool in
                if tries >= 3 { return false }
                return true
            })
            log.debug("数据库连接成功")
        } catch _ {
            dbConnection = nil
            log.error("数据库连接失败")
        }
    }
}

extension DataBaseManager {
    
    /// 建表
    func createTables() throws {
        do {
            try TableMessage.createTable()
            log.debug("建表成功")
        }
        catch {
            log.error("建表失败")
            throw DBError.createTableError
        }
    }
    
    
    /// 通过本地文件完整路径读取字符串内容
    ///
    /// - Returns: 文件中的`SQL`语句
    ///
    func readString() -> String? {
        guard let sqlPath = Bundle.main.path(forResource: "create_table_msg", ofType: "sql") else { return nil }
        guard let data = FileManager.default.contents(atPath: sqlPath) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
