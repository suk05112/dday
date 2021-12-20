//
//  DdayTests.swift
//  DdayTests
//
//  Created by 한수진 on 2021/07/19.
//

import XCTest
@testable import Dday

class DdayTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testNoneSetting(){
        let calculation = CalculateDay.shared
        let noneSetting = Setting(iter: .none, set1: false, widget: false)
        let str: String? = "2021.12.23 화요일"
        
        let testDay = DdayDateFormmater().toDate(str: str!)
        
        XCTAssertEqual(calculation.calculateDday(select_day: testDay, setting: noneSetting), -3, "정닶 dday와 다릅니다.")
    }

    func testIterSetting(){
        
    }
    
    func testSet1Setting(){
        
    }
    
    func testIterAndSet1Setting(){
        
    }
    
    
    
    
}

class NoneSetting{
    
    func beforeToday(){
        
    }
    
    func today(){
        
    }
    
    func afterToday(){
        
    }
}

//class IterSetting(){
//    
//}
//
//class Set1Setting(){
//    
//}
//
//class IterAndSet1Setting(){
//    
//}
