//
//  FoodDatabase.swift
//  FoodManagement2027
//
//  Created by  User on 15.11.2026.
//

import UIKit
import os.log

class FoodDatabase {
    
    ///MARK: dinh nghia cac thuoc tinh co ban cho co so du lieu
    private let DB_NAME = "foods.sqlite"
    private let DB_PATH:String?
    private let DB:FMDatabase?
  
    ///MARK: Dinh nghia constructor
    init() {
        //buoc 1 khoi tao duong dan cho csdl
        let directories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true)
        DB_PATH = directories[0] + "/" + DB_NAME
        //buoc 2 khoi tao csdl FMDatabase
        DB = FMDatabase(path: DB_PATH)
        if DB != nil {
            os_log("Khoi tao CSDL: \(self.DB_PATH!) thanh cong")
            //thuc hien tao cac bang du lieu o day
            //1. tao bang meals
            //1.1 cau lenh sql de tao bang
            let sql = "CREATE TABLE \(TABLE_MEAL_NAME)(" +
            "\(MEAL_ID) INTEGER PRIMARY KEY AUTOINCREMENT, " +
            "\(MEAL_NAME) TEXT, " +
            "\(MEAL_IMAGE) TEXT, " +
            "\(MEAL_RATING) INTEGER)"
            //1.2 goi ham tao bang
            let _ = createTable(sql: sql, tableName: TABLE_MEAL_NAME)
        }
        else {
            os_log("Khong the khoi tao csdl: \(self.DB_PATH!)")
        }
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////
    //MARK: Dinh nghia cac thuoc tinh co ban cho cac bang du lieu
    /////////////////////////////////////////////////////////////////////////////////////////////
    // Bang 1: Bang meals
    private let TABLE_MEAL_NAME = "meals"
    private let MEAL_ID = "_id"
    private let MEAL_NAME = "name"
    private let MEAL_IMAGE = "image"
    private let MEAL_RATING = "rating"
    /////////////////////////////////////////////////////////////////////////////////////////////
    //MARK: Dinh nghia cac primitives cua CSDL
    /////////////////////////////////////////////////////////////////////////////////////////////
    
    // 1. Mo CSDL
    private func openDatabase()-> Bool {
        var ok = false
        if let DB = DB {
            if DB.open() {
                ok = true
                os_log("CSDL \(self.DB_NAME) mo thanh cong!")
            }
            else {
                os_log("CSDL \(self.DB_NAME) khong the mo!")
            }
        }
        else {
            os_log("CSDL muon mo chua ton tai!")
        }
        return ok
    }
    // 2. Dong CSDL
    private func closeDatabase() {
        if let DB = DB {
            DB.close()
        }
    }
    // 3. Ham tao bang du lieu
    private func createTable(sql:String, tableName:String)->Bool {
        var ok = false
        if openDatabase() {
            // Kiem tra su ton tai cua bang du lieu trong CSDL
            if !DB!.tableExists(tableName) {
                // Thuc thi cau lenh sql de tao bang du lieu
                if DB!.executeStatements(sql) {
                    ok = true
                    os_log("Tao bang du lieu \(tableName) da thanh cong!")
                }
                else {
                    os_log("Khong the tao bang du lieu: \(tableName)")
                }
            }
            closeDatabase()
        }
        return ok
    }
    // 4. Kiem tra su ton tai cua bang du lieu
    private func tableExits(_ tableName:String) -> Bool {
        if openDatabase() {
            if DB!.tableExists(tableName) {
                return true
            }
            //return false
        }
        return false
    }
    /////////////////////////////////////////////////////////////////////////////////////////////
    //MARK: Dinh nghia cac APIs cua CSDL
    /////////////////////////////////////////////////////////////////////////////////////////////
    // 1. Ghi mot mon an vao CSDL
    func inserMeal(meal:Meal) -> Bool {
        var ok = false
        if openDatabase() && tableExits(TABLE_MEAL_NAME){
            // Cau lenh sql
            //let sql = "INSERT INTO \(TABLE_MEAL_NAME) (\(MEAL_NAME), \(MEAL_IMAGE), \(MEAL_RATING)) VALUES (?, ?, ?)"
            // Chuyen anh cua mon an thanh String truoc khi luu vao bang meals
            var strImage = ""
            if let image = meal.image {
                // B1. Chuyen anh thanh dang NSData
                let dataImage = image.pngData()! as NSData
                // B2. Chuyen dataImage thanh String
                strImage = dataImage.base64EncodedString(options: .lineLength64Characters)
            }
            let sql = "INSERT INTO \(TABLE_MEAL_NAME) (\(MEAL_NAME), \(MEAL_IMAGE), \(MEAL_RATING)) VALUES ('\(meal.name)', '\(strImage)', \(meal.rating))"
            // Thuc hien cau lenh ghi doi tuong meal vao CSDL trong bang meals
            //if DB!.executeUpdate(sql, withArgumentsIn: [meal.name, strImage, meal.rating]) {
            if DB!.executeStatements(sql) {
                ok = true
                os_log("Ghi doi tuong mon an \(meal.name) vao CSDL thanh cong!")
            }
            else {
                os_log("Ghi doi tuong mon an \(meal.name) vao CSDL KHONG thanh cong!")
            }
            
            closeDatabase()
        }
        return ok
    }
    // 2. Doc toan bo du lieu tu meals vao MealList
    func readMeals(list: inout [Meal]) {
        if openDatabase() && tableExits(TABLE_MEAL_NAME){
            // Cau lenh sql
            let sql = "SELECT * FROM \(TABLE_MEAL_NAME) ORDER BY \(MEAL_RATING) DESC"
            var result:FMResultSet? = nil
            // Thu hien truy van vao CSDL de doc cac mon an
            do {
                result = try DB!.executeQuery(sql, values: nil)
            }
            catch {
                os_log("Khong the doc du lieu tu CSDL!")
            }
            
            // Xu ly du lieu doc ve
            if let result = result {
                while result.next() {
                    let name = result.string(forColumn: MEAL_NAME) ?? ""
                    let strImage = result.string(forColumn: MEAL_IMAGE)
                    let rating = result.int(forColumn: MEAL_RATING)
                }
            }
        }
    }
}
