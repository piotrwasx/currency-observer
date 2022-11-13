//
//  ContentView.swift
//  currency-observer
//
//  Created by Piotr Waś on 09/11/2022.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var selectedCurrencyCode: String? = nil
    @State var valueOfOnePLNInSelectedCurrency: Double? = nil
    
    @State private var outputValue: Double = 0
    
    @State private var leftCurrencyValue: Double = Constants.deafultValue
    @State private var leftCurrencyCode: String = Constants.mainCurrency
    @State private var rightCurrencyCode: String = Constants.deafultForeignCurrency
    
    var body: some View {
        NavigationView {
            VStack {
                Color.secondary
                    .frame(width: UIScreen.main.bounds.width - 20,
                           height: Constants.boxHeight)
                    .mask {
                        RoundedRectangle(cornerSize: Constants.boxCornerSize)
                            .stroke(style: StrokeStyle())
                    }
                    .overlay {
                        HStack {
                            VStack {
                                TextField("Type value here", value: $leftCurrencyValue, format: .number)
                                    .keyboardType(.numberPad)
                                    .frame(maxWidth: UIScreen.main.bounds.width - 45)
                                    .font(.system(size: 42))
                                    .fontWeight(.semibold)
                                    .onChange(of: leftCurrencyValue) { newValue in
                                        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.delay_small) {
                                            countCurrencyExchange()}}
                                Text(leftCurrencyCode)
                                
                                Color.secondary
                                    .frame(width: Constants.switchButtonWidth, height: Constants.switchButtonHeight)
                                    .padding()
                                    .mask {
                                        RoundedRectangle(cornerSize: Constants.switchButtonCornerSize)
                                            .stroke(style: StrokeStyle())
                                            .frame(width: Constants.switchButtonWidth - 10, height: Constants.switchButtonHeight - 10)
                                    }
                                    .overlay {
                                        Button(action: {
                                            withAnimation {
                                                let temp = leftCurrencyCode
                                                leftCurrencyCode = rightCurrencyCode
                                                rightCurrencyCode = temp
                                            }
                                        }, label: {
                                            Image(systemName: "arrow.2.squarepath")
                                                .foregroundColor(Color.primary)
                                        })
                                    }
                                
                                Text("\(outputValue, specifier: "%.2f")")
                                    .font(.system(size: 42))
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: UIScreen.main.bounds.width - 40, maxHeight: Constants.outputBoxMaxHeight)
                                Text(rightCurrencyCode)
                            }
                            .multilineTextAlignment(.center)
                        }
                    }
                Color.secondary
                    .frame(width: Constants.changeCurrencyButtonWidth, height: Constants.changeCurrencyButtonHeight)
                    .mask {
                        RoundedRectangle(cornerSize: Constants.changeCurrencyButtonCornerSize)
                            .stroke(style: StrokeStyle())
                            .frame(width: Constants.changeCurrencyButtonWidth, height: Constants.changeCurrencyButtonHeight - 10)
                    }
                    .overlay {
                        NavigationLink(destination: CurrencyListView(rateCode: $selectedCurrencyCode)) {
                            Text("change currency")
                                .foregroundColor(Color.primary)
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
        }
        .onAppear() {
            fetchSpecificCurrency(currencyCode: rightCurrencyCode)
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.delay) {
                countCurrencyExchange()}
        }
        .accentColor(colorScheme == .dark ? Color.white : Color.black)
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
    
    static let boxHeight: CGFloat = 450
    static let boxCornerSize = CGSize(width: 80, height: 80)
    
    static let switchButtonWidth: CGFloat = 70
    static let switchButtonHeight: CGFloat = 60
    static let switchButtonCornerSize = CGSize(width: 120, height: 120)
    
    static let outputBoxMaxHeight: CGFloat = 40
    
    static let changeCurrencyButtonWidth: CGFloat = 160
    static let changeCurrencyButtonHeight: CGFloat = 60
    
    static let changeCurrencyButtonCornerSize = CGSize(width: 120, height: 120)
}
