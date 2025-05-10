import SwiftUI
import AVFoundation
import UIKit

struct CameraView: View {
    @Binding var isImagePicked: Bool
    @Binding var pickedImage: UIImage

    @State private var image = UIImage()
    @State private var showSheet = false

    @State private var captureSession: AVCaptureSession?
    @State private var photoOutput: AVCapturePhotoOutput!
    @State private var previewLayer: AVCaptureVideoPreviewLayer!
    
    @State private var isImagePickerPresented = false  // For showing the Image Picker
    
    var body: some View {
        VStack {
            Button(action: {
                print(self.image)
            }) {
                Text("Print photo")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            // Kamera-Vorschau
            if previewLayer != nil {
                CameraPreviewLayer(previewLayer: previewLayer)
                    .edgesIgnoringSafeArea(.all)
            }
            
            // Button zum Aufnehmen eines Fotos
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
                ImagePicker(selectedImage: self.$image)
            }

            // Button für den Image Picker (Foto auswählen)
            Button(action: {
                isImagePickerPresented.toggle()
            }) {
                Text("Select Picture")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
        }
        .onAppear(perform: setupCamera)
        .onDisappear(perform: stopCamera)
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePickerView(selectedImage: $pickedImage)  // Bild-Picker anzeigen
        }
    }
    
    // Kamera einrichten
    func setupCamera() {
        captureSession = AVCaptureSession()
        photoOutput = AVCapturePhotoOutput()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            print("Camera not found!")
            return
        }
        let videoDeviceInput: AVCaptureDeviceInput
        
        do {
            videoDeviceInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            print("Error accessing camera: \(error.localizedDescription)")
            return
        }
        
        if captureSession!.canAddInput(videoDeviceInput) {
            captureSession!.addInput(videoDeviceInput)
        } else {
            print("Error adding input to session")
            return
        }
        
        if captureSession!.canAddOutput(photoOutput) {
            captureSession!.addOutput(photoOutput)
        } else {
            print("Error adding output to session")
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        captureSession!.startRunning()
    }
    
    // Foto aufnehmen
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: CameraCoordinator(isImagePicked: $isImagePicked, pickedImage: $pickedImage))
    }

    // Kamera stoppen
    func stopCamera() {
        captureSession?.stopRunning()
    }
}

// Coordinator zum Verarbeiten des aufgenommenen Fotos
class CameraCoordinator: NSObject, AVCapturePhotoCaptureDelegate {
    @Binding var isImagePicked: Bool
    @Binding var pickedImage: UIImage

    init(isImagePicked: Binding<Bool>, pickedImage: Binding<UIImage>) {
        _isImagePicked = isImagePicked
        _pickedImage = pickedImage
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) {
            pickedImage = image
            isImagePicked = true
        }
    }
}

// Kamera-Vorschau für SwiftUI
struct CameraPreviewLayer: UIViewRepresentable {
    var previewLayer: AVCaptureVideoPreviewLayer
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct ImagePickerView: View {
    @Binding var selectedImage: UIImage
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ImagePickerController(selectedImage: $selectedImage)
            .edgesIgnoringSafeArea(.all)
    }
}

struct ImagePickerController: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(selectedImage: $selectedImage, presentationMode: presentationMode)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        @Binding var selectedImage: UIImage
        var presentationMode: Binding<PresentationMode>

        init(selectedImage: Binding<UIImage>, presentationMode: Binding<PresentationMode>) {
            _selectedImage = selectedImage
            self.presentationMode = presentationMode
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                selectedImage = image
            }
            presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            presentationMode.wrappedValue.dismiss()
        }
    }
}
