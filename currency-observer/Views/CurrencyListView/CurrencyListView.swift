//
//  CurrencyListView.swift
//  currency-observer
//
//  Created by Piotr Waś on 10/11/2022.
//

import SwiftUI

struct CurrencyListView: View {
    
    @StateObject var viewModel = CurrencyListViewModel()
    @Binding var rateCode: String?
    
    var body: some View {
        VStack {
            NavigationView() {
                List(selection: $rateCode) {
                    ForEach(viewModel.currencyTable, id: \.no) { rate in
                        ForEach(rate.rates, id: \.code) { pair in
                            Text("\(pair.code) - \(pair.currency)")
                        }
                    }
                }
                .navigationTitle("Currencies")
            }
        }
    }
}

struct CurrencyListView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyListView(rateCode: .constant("USD")).environmentObject(CurrencyListViewModel())
    }
}
