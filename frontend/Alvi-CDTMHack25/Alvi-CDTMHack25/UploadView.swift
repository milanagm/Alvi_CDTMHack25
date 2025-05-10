//
//  UploadView.swift
//  Alvi-CDTMHack25
//
//  Created by Milana Gurbanova on 10.05.25.
//

import SwiftUI
import UIKit

struct UploadView: View {
    @State private var isCameraPresented = false
    @State private var isDocumentPickerPresented = false
    @State private var isImagePickerPresented = false  // Bild-Picker direkt hier steuern
    @State private var pickedImage: UIImage = UIImage()

    @State private var showSheet = false

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
            
            // Buttons
            VStack(spacing: 20) {
                Button(action: {
                    print(self.pickedImage.toBase64JPEG()?.count)
                }) {
                    Text("Upload")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

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
                    ImagePicker(selectedImage: self.$pickedImage)
                }

                // Button 2: Upload document
                Button(action: {
                    isDocumentPickerPresented.toggle() // Dokumenten-Picker Modal öffnen
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
        }
        .background(Color.white)  // Hintergrund auf weiß setzen
        .sheet(isPresented: $isCameraPresented) {
            CameraView(isImagePicked: .constant(false), pickedImage: $pickedImage)
        }
        .sheet(isPresented: $isDocumentPickerPresented) {
            DocumentPickerView(selectedDocumentURL: .constant(nil))
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePickerView(selectedImage: $pickedImage) // Direkt der Bild-Picker
        }
    }
}
