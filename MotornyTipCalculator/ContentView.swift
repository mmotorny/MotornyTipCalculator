import AudioToolbox
import SwiftUI

func formatCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    return formatter.string(from: NSNumber(floatLiteral: value)) ?? formatCurrency(0)
}

func parseCurrency(_ value: String) -> Double {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    return formatter.number(from: value)?.doubleValue ?? 0
}

func formatPercent(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .percent
    return formatter.string(from: NSNumber(floatLiteral: value)) ?? formatPercent(0)
}

let numberSoundID: SystemSoundID = 1104;
let deleteSoundID: SystemSoundID = 1155;


struct ContentView: View {
    @State private var amount: String = formatCurrency(0)
    @State private var isCursorVisible = true
    @State private var total: String = formatCurrency(0)
    @State private var tipIndex = UserDefaults.standard.object(forKey: "tipIndex") as? Int ?? 19
    
    let buttons = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["", "0", "⌫"]
    ]
    
    var body: some View {
        VStack {
            Spacer()
            VStack {
                Text("Before tip")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Text(amount)
                    .font(.largeTitle)
                    .padding(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color(UIColor.tintColor), lineWidth: 1)
                    )
                    .textSelection(.enabled)
            }
            .padding()
            VStack {
                Text("Tip")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Picker("Tip", selection: $tipIndex) {
                    ForEach(1..<51) { percent in
                        let percent = Double(percent) / 100
                        Text("\(formatPercent(percent)) = \(formatCurrency(parseCurrency(amount) * percent))")
                    }
                }
                .pickerStyle(.wheel)
                .onChange(of: tipIndex) {
                    updateTotal()

                    let savedTipIndex: Int? = tipIndex;
                    UserDefaults.standard.set(savedTipIndex, forKey: "tipIndex")
                }
            }
            .padding()
            VStack {
                Text("After tip")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                Text(total)
                    .font(.largeTitle)
                    .textSelection(.enabled)
            }
            .padding()
            Spacer()
            VStack(spacing: 6) {
                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: 6) {
                        ForEach(row, id: \.self) { button in
                            Text(button)
                                .font(.largeTitle)
                                .frame(maxWidth: .infinity, maxHeight: 48)
                                .background(Int(button) == nil ? .clear : Color(UIColor.systemFill))
                                .cornerRadius(5)
                                .onTapGesture() {
                                    if let digit = Double(button) {
                                        AudioServicesPlaySystemSound(numberSoundID)
                                        amount = formatCurrency(parseCurrency(amount) * 10 + digit / 100)
                                    } else {
                                        AudioServicesPlaySystemSound(deleteSoundID)
                                        amount = formatCurrency(floor(parseCurrency(amount) * 10) / 100)
                                    }
                                    updateTotal()
                                }
                                .onLongPressGesture() {
                                    if Double(button) == nil {
                                        AudioServicesPlaySystemSound(deleteSoundID)
                                        amount = formatCurrency(0)
                                        updateTotal()
                                    }
                                }
                        }
                    }
                }
            }
            .padding(6)
            .background(Color(UIColor.secondarySystemBackground))
        }
    }
    
    private func updateTotal() {
        total = formatCurrency(parseCurrency(amount) * (1 + Double(tipIndex + 1) / 100))
    }
}

#Preview {
    ContentView()
}
