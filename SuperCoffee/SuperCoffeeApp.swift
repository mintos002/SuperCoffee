import SwiftUI

@main
struct SuperCoffeeApp: App {
    @State private var isEnabled = false
    @State private var hours: String = "1.0"
    @State private var process: Process?
    @State private var endTime: String = "" // Para mostrar la hora de fin

    var body: some Scene {
        MenuBarExtra {
            VStack(spacing: 16) {
                // Header con estilo minimalista
                VStack(spacing: 4) {
                    Text(isEnabled ? "COFFEE ACTIVE" : "STANDBY")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .foregroundStyle(isEnabled ? .orange : .secondary)
                    
                    if isEnabled && !endTime.isEmpty {
                        Text("Until \(endTime)")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundStyle(.primary.opacity(0.8))
                    }
                }

                // Input compacto
                HStack(spacing: 10) {
                    Image(systemName: "timer")
                        .foregroundStyle(.secondary)
                    TextField("Hours", text: $hours)
                        .textFieldStyle(.plain)
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .multilineTextAlignment(.center)
                        .frame(width: 50)
                        .padding(4)
                        .background(Color.primary.opacity(0.05))
                        .cornerRadius(4)
                    Text("hrs")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                // Botón principal estilo Tahoe
                Button(action: { isEnabled ? stop() : start() }) {
                    Text(isEnabled ? "STOP" : "START")
                        .font(.system(size: 12, weight: .bold))
                        .frame(maxWidth: .infinity, minHeight: 32)
                }
                .buttonStyle(.borderedProminent)
                .tint(isEnabled ? .red : .primary)
                .controlSize(.large)

                Divider()

                Button("Quit") {
                    stop()
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
            }
            .padding(20)
            .frame(width: 160) // Ancho mucho más contenido y elegante
        } label: {
            Image(systemName: isEnabled ? "cup.and.saucer.fill" : "cup.and.saucer")
        }
        .menuBarExtraStyle(.window)
    }

    func start() {
        let cleanHours = hours.replacingOccurrences(of: ",", with: ".")
        guard let h = Float(cleanHours), h > 0 else { return }
        let seconds = Int(h * 3600)

        // Calcular hora de fin
        let date = Date().addingTimeInterval(TimeInterval(seconds))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        endTime = formatter.string(from: date)

        let newProcess = Process()
        newProcess.executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")
        newProcess.arguments = ["-di", "-t", "\(seconds)"]
        
        newProcess.terminationHandler = { _ in
            DispatchQueue.main.async {
                self.isEnabled = false
                self.process = nil
                self.endTime = ""
            }
        }

        do {
            try newProcess.run()
            self.process = newProcess
            self.isEnabled = true
        } catch {
            print("Error")
        }
    }

    func stop() {
        process?.terminate()
        process = nil
        isEnabled = false
        endTime = ""
    }
}
