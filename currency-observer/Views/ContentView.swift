//
//  ContentView.swift
//  currency-observer
//
//  Created by Piotr Waś on 09/11/2022.
//

import SwiftUI

struct ContentView: View {
    
    @State var selectedCurrencyCode: String? = nil
    @State var valueOfOnePLNInSelectedCurrency: Double? = nil
    
    @State private var outputValue: Double = 0
    
    @State private var leftCurrencyValue: Double = Constants.deafultValue
    @State private var leftCurrencyCode: String = Constants.mainCurrency
    @State private var rightCurrencyCode: String = Constants.deafultForeignCurrency
    
    var body: some View {
        NavigationView {
            VStack {
                Button("odwróć") {
                    let temp = leftCurrencyCode
                    leftCurrencyCode = rightCurrencyCode
                    rightCurrencyCode = temp
                }
                HStack {
                    VStack {
                        TextField(leftCurrencyCode, value: $leftCurrencyValue, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: Constants.textFieldWidth)
                            .onChange(of: leftCurrencyValue) { newValue in
                                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.delay_small) {
                                    countCurrencyExchange()}}
                        Text(leftCurrencyCode)
                    }
                    VStack {
                        TextField("", value: $outputValue, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: Constants.textFieldWidth)
                        Text(rightCurrencyCode)
                    }
                }
                
                NavigationLink(destination: CurrencyListView(rateCode: $selectedCurrencyCode)) {
                    Text("zmień walutę")
                }
                .onChange(of: rightCurrencyCode) { newValue in
                    fetchSpecificCurrency(currencyCode: selectedCurrencyCode ?? rightCurrencyCode)
                    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.delay_small) {
                        countCurrencyExchange()}
                }
                .onChange(of: selectedCurrencyCode) { newValue in
                    rightCurrencyCode = selectedCurrencyCode!
                    leftCurrencyCode = Constants.mainCurrency
                    leftCurrencyValue = 1
                }
            }
        }
        .onAppear() {
            fetchSpecificCurrency(currencyCode: rightCurrencyCode)
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.delay) {
                countCurrencyExchange()}
        }
    }
    
    func countCurrencyExchange() {
        if leftCurrencyCode == Constants.mainCurrency {
            outputValue = leftCurrencyValue / (valueOfOnePLNInSelectedCurrency ?? 1)
        } else {
            outputValue = leftCurrencyValue * (valueOfOnePLNInSelectedCurrency ?? 1)
            
        }
    }
    
    func fetchSpecificCurrency(currencyCode: String) {
        let url = "https://api.nbp.pl/api/exchangerates/rates/a/\(currencyCode)/?format=json"
        NetworkController.fetchData(url: url, dataType: SpecificCurrency.self) { currencyRate in
            DispatchQueue.main.async {
                self.valueOfOnePLNInSelectedCurrency = currencyRate.rates.first?.mid ?? .zero
            }}
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

private enum Constants {
    static let mainCurrency: String = "PLN"
    static let deafultForeignCurrency: String = "USD"
    
    static let delay_small: Double = 0.3
    static let delay: Double = 0.6
    static let textFieldWidth: CGFloat = 150
    
    static let deafultValue: Double = 1
}
