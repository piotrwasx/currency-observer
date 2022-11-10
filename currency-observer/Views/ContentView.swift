//
//  ContentView.swift
//  currency-observer
//
//  Created by Piotr Waś on 09/11/2022.
//

import SwiftUI

struct ContentView: View {
    
    @State var currencyCode: String? = "SEK"
    @State var currencyRate: Double? = 0
    @State private var valueInPLN: Double = 1
    @State private var outputValue: Double = 0
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    VStack {
                        TextField("PLN", value: $valueInPLN, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: Constants.textFieldWidth)
                            .onChange(of: valueInPLN) { newValue in
                                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.delay_small) {
                                    countOutputValue(valueInPLN: newValue)}}
                        Text("PLN")
                    }
                    VStack {
                        TextField("PLN", value: $outputValue, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: Constants.textFieldWidth)
                        Text(currencyCode!)
                    }
                }
                
                NavigationLink(destination: CurrencyListView(rateCode: $currencyCode)) {
                    Text("zmien walutę")
                }
                .onChange(of: currencyCode) { newValue in
                    fetchSpecificCurrency(rateCode: currencyCode!)
                    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.delay_small) {
                        countOutputValue(valueInPLN: valueInPLN)}}
            }
        }
        .onAppear() {
            fetchSpecificCurrency(rateCode: currencyCode!)
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.delay) {
                countOutputValue(valueInPLN: valueInPLN)}
        }
    }
    
    func countOutputValue(valueInPLN: Double) {
        outputValue = valueInPLN * (currencyRate ?? 0)
    }
    
    func fetchSpecificCurrency(rateCode: String) {
        let url = "https://api.nbp.pl/api/exchangerates/rates/a/\(rateCode)/?format=json"
        NetworkController.fetchData(url: url, dataType: SpecificCurrency.self) { currencyRate in
            DispatchQueue.main.async {
                self.currencyRate = currencyRate.rates.first?.mid ?? 0
            }}
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

private enum Constants {
    static let delay_small: Double = 0.3
    static let delay: Double = 0.5
    static let textFieldWidth: CGFloat = 150
}
