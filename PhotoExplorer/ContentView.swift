//
//  ContentView.swift
//  PhotoExplorer
//
//  Created by 杨洋 on 2024/10/2.
//

import SwiftUI
import SwiftData
import PhotosUI


struct ContentView: View {
    @State private var images: [UIImage] = [] // 保存加载的图片
    @State private var fetchCompleted = false // 标记是否完成加载

    var body: some View {
        NavigationView {
            if fetchCompleted {
                // 使用 Grid 将照片排列出来
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                        ForEach(images, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipped()
                        }
                    }
                    .padding()
                }
            } else {
                Text("Loading Photos...")
                    .onAppear {
                        requestPhotosPermission() // 请求权限
                    }
            }
        }
        .navigationTitle("Photo Gallery")
    }

    // 请求访问照片库的权限
    private func requestPhotosPermission() {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized, .limited:
                fetchPhotos() // 如果授权成功，开始加载照片
            case .denied, .restricted:
                print("Photo access denied or restricted.")
            default:
                break
            }
        }
    }

    // 获取照片资源
    private func fetchPhotos() {
        DispatchQueue.global(qos: .userInitiated).async {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)] // 按创建时间排序
            let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)

            let imageManager = PHImageManager.default()
            let imageRequestOptions = PHImageRequestOptions()
            imageRequestOptions.isSynchronous = true // 同步请求图片

            var loadedImages: [UIImage] = []

            allPhotos.enumerateObjects { asset, index, stop in
                imageManager.requestImage(for: asset,
                                          targetSize: CGSize(width: 100, height: 100),
                                          contentMode: .aspectFill,
                                          options: imageRequestOptions) { image, _ in
                    if let image = image {
                        loadedImages.append(image) // 添加加载的图片到数组中
                    }
                }
            }

            DispatchQueue.main.async {
                self.images = loadedImages // 更新图片数组
                self.fetchCompleted = true // 标记为完成加载
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
