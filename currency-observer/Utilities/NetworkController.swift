//
//  NetworkController.swift
//  currency-observer
//
//  Created by Piotr Waś on 09/11/2022.
//

import SwiftUI

struct NetworkController {
    static func fetchData<T: Codable>(url: String, dataType: T.Type, completion: @escaping ((T) -> Void)) {
        if let url = URL(string: url) {
            URLSession.shared.dataTask(with: url) { data, _, error in
                if let data = data {
                    do {
                        let output = try JSONDecoder().decode(dataType.self, from: data)
                        completion(output)
                    } catch {
                        print("error: ", error)
                    }
                }
            }.resume()
        }
    }
}

// MARK: - CurrencySingle
struct SpecificCurrency: Codable {
    var table, currency, code: String
    var rates: [Rate]
}

// MARK: - Rate
struct Rate: Codable {
    var no, effectiveDate: String
    var mid: Double
}

// MARK: - CurrencyTable
struct CurrencyTable: Codable {
    var table, no, effectiveDate: String
    var rates: [Rates]
}

// MARK: - Rates
struct Rates: Codable {
    var currency, code: String
    var mid: Double
}



