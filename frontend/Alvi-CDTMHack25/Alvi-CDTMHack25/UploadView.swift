//
//  UploadView.swift
//  Alvi-CDTMHack25
//

//

import SwiftUI
import UIKit

struct UploadView: View {
    @State private var isCameraPresented = false
    @State private var isDocumentPickerPresented = false
    @State private var isImagePickerPresented = false
    @State private var showSheet = false
    @State private var pickedImage: UIImage = UIImage()
    @State private var selectedDocumentURL: URL? = nil // nil wenn noch keine Datei gewählt 
    @State private var uploadMessage: String? = nil
    @State private var isUploading = false

    var body: some View {
        VStack {
            // Avatar in einem Kreis anzeigen
            ZStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 150, height: 150)
                
                Image("Alvi_smiling") // Dein Avatar-Bild
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
            }
            .padding()
            
            // Sprechblase und Text
            HStack {
                Text("Help me to be your perfect assistant and gather some information...")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .frame(maxWidth: 250)
                
                Spacer()
            }
            .padding()
            
            // Upload Status Message
            if let message = uploadMessage {
                Text(message)
                    .foregroundColor(message.contains("success") ? .green : .red)
                    .padding()
            }
            
            // Buttons
            VStack(spacing: 20) {
                // Button 1: Take a photo
                Button(action: {
                    showSheet = true
                }) {
                    Text("Capture Photo")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .sheet(isPresented: $showSheet) {
                    ImagePicker(selectedImage: self.$pickedImage) // hier pickedImage variable mit dem bild
                }

                // Button 2: Upload document
                Button(action: {
                    isDocumentPickerPresented.toggle() // Dokumenten-Picker Modul öffnen
                }) {
                    Text("Upload document")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                // Button 3: Select picture (öffnet sofort die Fotogalerie)
                Button(action: {
                    isImagePickerPresented.toggle() // Bild-Auswahl Modal öffnen
                }) {
                    Text("Select picture")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .disabled(isUploading) // Schützt vor versehentlichen Doppelklicks während eines laufenden Uploads

            if pickedImage != UIImage() { // prüft ob pickedImage != das leere Standardbild ist
                // Bild-Vorschau
                Image(uiImage: pickedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            }

            if let docURL = selectedDocumentURL {
                // Dokument-Vorschau (nur Dateiname und Icon)
                HStack {
                    Image(systemName: "doc.text")
                        .font(.largeTitle)
                    Text(docURL.lastPathComponent)
                        .font(.headline)
                }
                .padding()
            }

            // Gemeinsamer Senden-Button
            if pickedImage != UIImage() || selectedDocumentURL != nil {
                Button(action: {
                    if pickedImage != UIImage() {
                        uploadImage(pickedImage)
                    } else if let docURL = selectedDocumentURL {
                        uploadDocument(docURL)
                    }
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Upload")
                    }
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
                }
            }
        }

        // here: image-variable gets a value
        // für button 1
        .sheet(isPresented: $isCameraPresented) { 
            CameraView(isImagePicked: .constant(false), pickedImage: $pickedImage)
        }
        // für button 2
        .sheet(isPresented: $isDocumentPickerPresented) {      
            DocumentPickerView(selectedDocumentURL: $selectedDocumentURL)
        }
        // für button 3
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePickerView(selectedImage: $pickedImage)
        }
    }
    
    // uploading functions -> they call the sendToAPI function
    private func uploadImage(_ image: UIImage) {
        isUploading = true
        uploadMessage = "Uploading image..."
        
        guard let base64String = image.toBase64JPEG(compressionQuality: 0.8) else { // methode in UIImage
            uploadMessage = "Failed to prepare image for upload"
            isUploading = false
            return
        }
        
        let fileName = "image_\(Date().timeIntervalSince1970).jpg"
        sendToAPI(fileName: fileName, fileType: "image/jpeg", base64Data: base64String)
    }
    
    private func uploadDocument(_ url: URL) {
        isUploading = true
        uploadMessage = "Uploading document..."
        
        do {
            let fileData = try Data(contentsOf: url)
            let base64String = fileData.base64EncodedString() // swifts own converting methode and not ours 
            let fileName = url.lastPathComponent
            let fileType = url.pathExtension.lowercased() == "pdf" ? "application/pdf" : "application/octet-stream"
            
            sendToAPI(fileName: fileName, fileType: fileType, base64Data: base64String)
        } catch {
            isUploading = false
            uploadMessage = "Failed to read document: \(error.localizedDescription)"
        }
    }
    
    // here are the actual sendToAPI functions
    private func sendToAPI(fileName: String, fileType: String, base64Data: String) {
        guard let url = URL(string: "https://cdtmhack.vercel.app/api/post_add_file") else {
            uploadMessage = "Invalid URL"
            isUploading = false
            return
        }
        
        let requestBody: [String: Any] = [
            "patientId": "6a53a6cb-86b8-41d1-bc28-84e8de22cd1d",
            "file_data": [
                "file_name": fileName,
                "file_type": fileType,
                "file_base64": base64Data
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("AYBXFG3VBOSXCPIJARmjGfyfB8dI97vJ", forHTTPHeaderField: "x-vercel-protection-bypass")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody) // umwandeln des body into json
        } catch {
            uploadMessage = "Failed to prepare request: \(error.localizedDescription)"
            isUploading = false
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isUploading = false
                
                if let error = error {
                    uploadMessage = "Failed to upload: \(error.localizedDescription)"
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        uploadMessage = "Upload successful!"
                        // Reset the image/document after successful upload
                        pickedImage = UIImage()
                        selectedDocumentURL = nil
                    } else {
                        uploadMessage = "Upload failed with status code: \(httpResponse.statusCode)"
                    }
                }
            }
        }
        task.resume()
    }
}
