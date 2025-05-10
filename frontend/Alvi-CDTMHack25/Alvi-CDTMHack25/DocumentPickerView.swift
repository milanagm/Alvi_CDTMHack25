import SwiftUI
import UIKit
import MobileCoreServices

struct DocumentPickerView: UIViewControllerRepresentable {
    @Binding var selectedDocumentURL: URL?

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // Dokumenten-Picker konfigurieren
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf, .text, .image], asCopy: true)
        documentPicker.delegate = context.coordinator
        return documentPicker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // Hier könnte zusätzliche Logik hinzugefügt werden, wenn das View aktualisiert werden muss
    }

    // Erstelle einen Coordinator, um den Picker zu verwalten
    func makeCoordinator() -> Coordinator {
        return Coordinator(selectedDocumentURL: $selectedDocumentURL)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        @Binding var selectedDocumentURL: URL?
        
        init(selectedDocumentURL: Binding<URL?>) {
            _selectedDocumentURL = selectedDocumentURL
        }
        
        // Wenn der Benutzer ein Dokument auswählt
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                selectedDocumentURL = url
            }
        }

        // Fehlerbehandlung (falls der Benutzer den Vorgang abbricht)
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("Document Picker was cancelled")
        }
    }
}
