//
//  ContentViewModel.swift
//  currency-observer
//
//  Created by Piotr Waś on 09/11/2022.
//

import SwiftUI

final class CurrencyListViewModel: ObservableObject {
    
    @Published var currencyTable: [CurrencyTable] = []
    
    init() {
        fetchCurrencyTableFromURL(url: "https://api.nbp.pl/api/exchangerates/tables/a/?format=json")
    }
    
    func fetchCurrencyTableFromURL(url: String) {
        NetworkController.fetchData(url: url, dataType: [CurrencyTable].self) { currencyTable in
            DispatchQueue.main.async {
                self.currencyTable = currencyTable
            }
        }
    }
    
}
