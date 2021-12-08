//
//  AppGroup.swift
//  Dday
//
//  Created by 한수진 on 2021/12/08.
//

import Foundation

public enum AppGroup: String {
  case facts = "group.com.sujin.Dday"

  public var containerURL: URL {
    switch self {
    case .facts:
      return FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: self.rawValue)!
    }
  }
}
