//
//  UploadView.swift
//  Alvi-CDTMHack25
//

//

import SwiftUI
import UIKit

struct UploadView: View {
    @State private var message = "Got it, thank you for sharing your heart rate data, Milana! 📊 I see a little spike in the evenings — I’ll make sure the doctor knows so they can take a closer look tomorrow 💡 In the meantime, do you happen to have any past medical letters or reports you could upload? Just in case there’s helpful context! 📄✨"
    @State private var isCameraPresented = false
    @State private var isDocumentPickerPresented = false
    @State private var isImagePickerPresented = false
    @State private var showSheet = false
    @State private var pickedImage: UIImage = UIImage()
    @State private var selectedDocumentURL: URL? = nil // nil wenn noch keine Datei gewählt 
    @State private var uploadMessage: String? = nil
    @State private var isUploading = false

    var messages: [String] = [
        "Thanks a bunch, Milana! 🥰 I see the letter from your cardiologist mentioning 'Arterielle Hypertonie' — that’s super helpful. Do you happen to have any other medical letters or documents lying around? Anything else you upload now could help the doctor prepare even better 📄✨",
        "Thank you Milana 🌟 This second letter gives great context — I see it mentions 'Koronare Zweigefäßerkrankung' from last year. You're doing such a thorough job! Before we wrap up, could you snap a quick picture of your vaccination pass if you have it handy? That way, the doctor can check if anything’s missing 💉📔",
        "Lovely, thank you Milana! 🌼 Your vaccination pass looks perfectly up to date — gold star from me ⭐️ That’s all I needed for now. If you remember anything else later, feel free to pop back in. Otherwise, the doctor will see you tomorrow at 2pm — all prepped and ready! 🧚‍♀️"
    ]
    @State private var messageIndex: Int = 0

    var body: some View {
        VStack {
            ChatReplyBubble(
                text: $message,
                icon: Image("alvi-idle")
            )
            .padding()

            // Upload Status Message
            if let message = uploadMessage {
                Text(message)
                    .foregroundColor(message.contains("success") ? .primary : .primary)
                    .padding()
            }
            Spacer()
            // Buttons

            ZStack {
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
                            if isUploading {
                                ProgressView()
                            } else {
                                Image(systemName: "square.and.arrow.up")
                                Text("Upload")
                            }
                        }
                        .padding()
                        .background(.white)
                        .foregroundColor(.black)
                        .shadow(radius: 20)
                        .cornerRadius(10)
                    }
                }
            }

            Spacer()

            VStack(spacing: 20) {
                // Button 1: Take a photo
                Button(action: {
                    showSheet = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "camera")
                        Text("Capture Photo")
                    }
                    .frame(maxWidth: .infinity)          // full-width
                    .frame(height: 44)                   // standard height
                    .background(Color(.systemGray6))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
                    .contentShape(Rectangle())
                }
                .sheet(isPresented: $showSheet) {
                    ImagePicker(selectedImage: self.$pickedImage) // hier pickedImage variable mit dem bild
                }

                // Button 3: Select picture (öffnet sofort die Fotogalerie)
                Button(action: {
                    isImagePickerPresented.toggle() // Bild-Auswahl Modal öffnen
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "photo")
                        Text("Choose Photo")
                    }
                    .frame(maxWidth: .infinity)          // full-width
                    .frame(height: 44)                   // standard height
                    .background(Color(.systemGray6))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
                    .contentShape(Rectangle())
                }

                // Button 2: Upload document
                Button(action: {
                    isDocumentPickerPresented.toggle() // Dokumenten-Picker Modul öffnen
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "doc")
                        Text("Upload Document")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color(.systemGray6))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
                    .contentShape(Rectangle())
                }
            }
            .padding()
            .disabled(isUploading) // Schützt vor versehentlichen Doppelklicks während eines laufenden Uploads
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
        uploadMessage = ""

        guard let base64String = image.toBase64JPEG(compressionQuality: 0.1) else { // methode in UIImage
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
            "patientId": "81d40b06-601d-4f43-91bf-539933e1f6a6",
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

                        message = messages[messageIndex]
                        messageIndex += 1
                        if messageIndex > 2 {
                            messageIndex = 0
                        }
                    } else {
                        uploadMessage = "Upload failed with status code: \(httpResponse.statusCode)"
                    }
                }
            }
        }
        task.resume()
    }
}

#Preview {
    UploadView()
}
