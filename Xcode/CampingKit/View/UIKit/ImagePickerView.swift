//
//  ImagePickerView.swift
//  
//
//  Created by Alsey Coleman Miller on 8/15/23.
//

#if canImport(UIKit)
import Foundation
import UIKit
import SwiftUI

public struct ImagePickerView: UIViewControllerRepresentable {

    private let sourceType: UIImagePickerController.SourceType
    
    private let allowsEditing: Bool
    
    private let onImagePicked: (UIImage) -> Void
    
    @Environment(\.presentationMode)
    private var presentationMode
    
    public init(
        sourceType: UIImagePickerController.SourceType,
        allowsEditing: Bool = false,
        onImagePicked: @escaping (UIImage) -> Void
    ) {
        self.sourceType = sourceType
        self.allowsEditing = allowsEditing
        self.onImagePicked = onImagePicked
    }

    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.allowsEditing = allowsEditing
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(
            onDismiss: { self.presentationMode.wrappedValue.dismiss() },
            onImagePicked: self.onImagePicked
        )
    }

    final public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

        private let onDismiss: () -> Void
        
        private let onImagePicked: (UIImage) -> Void
        
        init(onDismiss: @escaping () -> Void, onImagePicked: @escaping (UIImage) -> Void) {
            self.onDismiss = onDismiss
            self.onImagePicked = onImagePicked
        }
        
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                self.onImagePicked(editedImage)
            } else if let image = info[.originalImage] as? UIImage {
                self.onImagePicked(image)
            }
            self.onDismiss()
        }
        
        public func imagePickerControllerDidCancel(_: UIImagePickerController) {
            self.onDismiss()
        }
    }
}

#if DEBUG
struct ImagePickerView_Previews: PreviewProvider {
    
    struct PreviewView: View {
        
        @State
        private var image: Image?
        
        @State
        private var isPresented = false
        
        var body: some View {
            NavigationView {
                VStack(alignment: .center, spacing: 25) {
                    Button("Show Picker") {
                        isPresented = true
                    }
                }
                .padding()
                .sheet(isPresented: $isPresented, onDismiss: nil) {
                    ImagePickerView(sourceType: .camera) { image in
                        self.image = Image(uiImage: image)
                    }
                }
            }
        }
    }
    
    static var previews: some View {
        PreviewView()
    }
}
#endif
#endif
