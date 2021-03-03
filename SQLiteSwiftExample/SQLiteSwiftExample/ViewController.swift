//
//  ViewController.swift
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

import UIKit
import ObjectMapper

class ViewController: UITableViewController { }

extension ViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        createTable(didSelectRowAt: indexPath)
        operateTable(didSelectRowAt: indexPath)
        dropTable(didSelectRowAt: indexPath)
        query(didSelectRowAt: indexPath)
        transition(didSelectRowAt: indexPath)
    }
}


extension ViewController {
    
    /// 创建表
    ///
    /// - Note: `row == 0`  用`SQLite.Swift`接口的方式创建表
    /// - Note: `row == 1`  用本地`SQL`语句的方式创建表
    ///
    private func createTable(didSelectRowAt indexPath: IndexPath) {
        
        guard indexPath.section == 0 else { return }
        if indexPath.row == 0 {
            try? DataBaseManager.shared.createTables()
            return
        }
        if indexPath.row == 1 {
            let sql = DataBaseManager.shared.readString() ?? ""
            try? TableMessage.createTable(with: sql)
            return
        }
    }
    
    
    
    /// 表操作
    ///
    /// - Note: 增删改查
    ///
    private func operateTable(didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        
        
        // MARK: insert
        if indexPath.row == 0 {
            let inserMessage = Message.init(JSON: mockOneMessage as [String : Any])
            
            do {
                let row = try TableMessage.insert(item: inserMessage!)
                log.debug("插入\(row)行")
            }
            catch {
                debugPrint(error.localizedDescription)
                log.error("插入失败")
            }
            return
        }
        
        // MARK: update
        if indexPath.row == 1 {
            var updateMessage = Message.init(JSON: mockOneMessage as [String : Any])!
            // 修改为已读
            updateMessage.message_unread = false
            
            do {
                let row = try TableMessage.update(item: updateMessage)
                log.debug("更新\(row)行")
            }
            catch {
                debugPrint(error.localizedDescription)
                log.error("更新失败")
            }
            return
        }
        
        
        // MARK: delete
        if indexPath.row == 2 {
            let deleteMessage = Message.init(JSON: mockOneMessage as [String : Any])
            
            do {
                try TableMessage.delete(item: deleteMessage!)
                log.debug("删除完成")
            }
            catch {
                debugPrint(error.localizedDescription)
                log.error("删除失败")
            }
            return
        }
    }
    
    
    /// 删除表
    ///
    /// - Note: `drop` 表
    ///
    private func dropTable(didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 2 else { return }
        do {
            try TableMessage.dropTable()
            log.debug("删除表完成")
        }
        catch {
            log.error("删除表失败")
        }
    }
    
    ///
    /// 基础查询
    ///
    private func query(didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 3 else { return }
        
        if indexPath.row == 0 {
            do {
                let rows = try TableMessage.totalCount()
                log.debug("总计\(rows)行")
            }
            catch {
                debugPrint(error.localizedDescription)
                log.error("查询失败")
            }
            
            return
        }
        
        if indexPath.row == 0 {
            do {
                let messages = try TableMessage.findAll()
                log.debug("全部数据:")
                print(messages)
            }
            catch {
                debugPrint(error.localizedDescription)
                log.error("查询失败")
            }
            return
        }
    }
    
    ///
    /// 批量写入/更新
    ///
    private func transition(didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 4 else { return }
        if indexPath.row == 0 {
            do {
                
                var messages: [Message] = []
                for mockMsgJson in mockMessages {
                    let message = Message.init(JSON: mockMsgJson as [String : Any])!
                    messages.append(message)
                }
                try TableMessage.transaction_insert_update(messages: messages, updateFlag: true)
                log.debug("写入/更新成功")
            }
            catch {
                debugPrint(error.localizedDescription)
                log.error("批量操作失败")
            }
            
            return
        }
    }
}
