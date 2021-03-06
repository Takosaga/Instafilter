//
//  ContentView.swift
//  Instafilter
//
//  Created by Gonzalo Gamez on 4/11/20.
//  Copyright © 2020 Gamez. All rights reserved.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ContentView: View {
    @State private var image: Image?
    @State private var filterIntensity = 0.5
    
    @State private var showingFilterSheet = false
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var processedImage: UIImage?
    @State private var showingAlert = false
    @State private var filterName = "Sepia Tone"
    
    @State var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    
    var body: some View {
        let intensity = Binding<Double>(
            get: {
                self.filterIntensity
        },
            set: {
                self.filterIntensity = $0
                self.applyProcessing()
        }
        )
        
        return NavigationView {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Color.secondary)
                    
                    if image != nil {
                        image?
                            .resizable()
                            .scaledToFit()
                    } else {
                        Text("Tap to select a picture")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                .onTapGesture {
                    self.showingImagePicker = true
                }
                
                HStack {
                    Text("Current Filter: \(self.filterName)")
                        .font(.headline)
                }
                
                HStack {
                    Text("Intensity")
                    Slider(value: intensity)
                }
                .padding(.vertical)
                
                HStack {
                    Button("Change Filter") {
                        self.showingFilterSheet = true
                    }
                    
                    Spacer()
                    
                    Button("Save") {
                        guard let processedImage = self.processedImage else {
                            self.showingAlert = true
                            return }
                        
                        
                        let imageSaver = ImageSaver()
                        
                        imageSaver.successHandler = {
                            print("Success!")
                        }
                        imageSaver.errorHandler = {
                            print("Oops: \($0.localizedDescription)")
                        }
                        
                        
                        imageSaver.writeToPhotoAlbum(image: processedImage)
                    }
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("No Image Selected"), message: Text("Please select an image."), dismissButton: .default(Text("Dismiss")))
                    }
                }
            }
            .padding([.horizontal, .bottom])
            .navigationBarTitle("Instafilter")
            .sheet(isPresented: $showingImagePicker,
                   onDismiss: loadImage) {
                    ImagePicker(image: self.$inputImage)
            }
            .actionSheet(isPresented: $showingFilterSheet) {
                ActionSheet(title: Text("Select a filter"), buttons: [
                    .default(Text("Edges")) {
                        self.filterName = "Edges"
                        self.setFilter(CIFilter.edges())},
                    .default(Text("Gaussian Blur")) {
                        self.filterName = "Gaussian Blur"
                        self.setFilter(CIFilter.gaussianBlur())},
                    .default(Text("Pixallate")) {
                        self.filterName = "Pixallate"
                        self.setFilter(CIFilter.pixellate())},
                    .default(Text("Sepia Tone")) {
                        self.filterName = "Sepia Tone"
                        self.setFilter(CIFilter.sepiaTone())},
                    .default(Text("Unshard Mask")) {
                        self.filterName = "Unshared Mask"
                        self.setFilter(CIFilter.unsharpMask())},
                    .default(Text("Vignette")) {
                        self.filterName = "Vignette"
                        self.setFilter(CIFilter.vignette())},
                    .cancel()
                ])
            }
        }
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
        
        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey)
        }
        
        guard let outputImage = currentFilter.outputImage
            else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent){
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
