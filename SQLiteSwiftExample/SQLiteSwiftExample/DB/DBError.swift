//
//  DBError.swift
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

import Foundation


enum DBError: Error {
    /// 数据库连接失败
    case connectError
    /// 数据库操作失败
    case insertError
    case updateError
    case deleteError
    case queryError
    /// 表操作
    case createTableError
    case dropTableError
    /// 数据源有误, 关键信息校验不过, 未满足执行数据库操作的前提
    case invalidDataError
    /// 事务
    case transactionError
}

extension DBError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .connectError:     return "数据库连接失败"
        case .invalidDataError: return "无效数据"
        case .insertError:      return "插入数据失败"
        case .updateError:      return "更新数据失败"
        case .deleteError:      return "删除数据失败"
        case .queryError:       return "查询数据失败"
        case .createTableError: return "删除表失败"
        case .dropTableError:   return "删除表失败"
        case .transactionError: return "处理事务失败"
        }
    }
}

