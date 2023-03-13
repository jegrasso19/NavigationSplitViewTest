//
//  NavigationSplitViewTestAppApp.swift
//  NavigationSplitViewTestApp
//
//  Created by Joseph Grasso on 3/12/23.
//

import SwiftUI

@main
struct NavigationSplitViewTestAppApp: App {
    
    @StateObject var navModel = NavigationModel.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(navModel)
        }
    }
}

class NavigationModel: ObservableObject {

    @Published var path = NavigationPath()
    static var shared = NavigationModel()
    
    func popToRoot() {
        path.removeLast(path.count)
    }
}

struct ContentView: View {
    
    @EnvironmentObject var navModel : NavigationModel
    @State private var productFamilies : [ProductFamilyModel]? = ProductFamilyModel.loadData()
    @State private var navigated = false
    
    var body: some View {
        
        NavigationSplitView {
            Button(action: {
                self.navigated.toggle()
            }, label: {
                Text("LOGIN")
                    .bold()
                    .padding()
                    .foregroundColor(.white)
                    .background(
                        Capsule()
                            .foregroundColor(.green)
                            .frame(width: 200, height: 50)
                    )
            })
            .navigationDestination(isPresented: $navigated) {
                ProductFamilyView(productFamilies: productFamilies!)
            }
        } detail: {
            NavigationStack(path: $navModel.path) {
                NavigationLink("", value: productFamilies)
            }
        }
        .environmentObject(navModel)
    }
}

struct ProductFamilyView: View { //This is my home view
    
    @EnvironmentObject var navModel : NavigationModel
    @State var productFamilies: [ProductFamilyModel]
    @State private var selectedFamily : ProductFamilyModel?
    
    var body: some View {
        
        List(productFamilies, selection: $selectedFamily) { productFamily in
            NavigationLink(productFamily.name, value: productFamily)
        }
        .navigationDestination(for: ProductFamilyModel.self) { productFamily in
            PartNumberView(productFamily: productFamily)
        }
        .navigationTitle("Product Families")
        .navigationBarTitleDisplayMode(.inline)
        .environmentObject(navModel)
    }
}

struct PartNumberView: View {
    
    @EnvironmentObject var navModel : NavigationModel
    @State var productFamily: ProductFamilyModel
    @State private var selectedPartDetail : ProductModel?
        
    var body: some View {
        let partDetails = productFamily.partNumbers.compactMap( {$0} )
        
        List(partDetails, selection: $selectedPartDetail) { partDetail in
            NavigationLink(partDetail.partNumber, value: partDetail)
        }
        .navigationDestination(for: ProductModel.self) { partDetail in
            PartNumberRow(productDetail: partDetail)
        }
        .navigationTitle("\(productFamily.name)")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: HomeButtonView() )
        .environmentObject(navModel)
    }
}
struct PartNumberRow: View {
    
    @EnvironmentObject var navModel : NavigationModel
    @State var productDetail : ProductModel
    
    var body: some View {
        
        List {
            Text("Description: \(productDetail.description)")
            Text("Product Family: \(productDetail.productFamily)")
        }
        .navigationTitle("\(productDetail.partNumber)")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: HomeButtonView() )
        .environmentObject(navModel)
    }
}

struct HomeButtonView: View {
    
    @EnvironmentObject var navModel : NavigationModel
    
    var body: some View {
        
        Button(action: {
            self.navModel.popToRoot()
        }, label: {
            Image(systemName: "house")
        })
        .environmentObject(navModel)
    }
}

class ProductFamilyModel: ObservableObject, Identifiable {
    
    var id = UUID().uuidString
    var name : String
    var partNumbers : [ProductModel?]
    
    init(name: String) {
        self.name = name
        self.partNumbers = []
    }
    
    static func loadData() -> [ProductFamilyModel] {
        
        let productFamilyNames = ["Product Family 1",
                                  "Product Family 2",
                                  "Product Family 3"]
        let partDetails = ProductModel.loadData()
        var productFamilies : [ProductFamilyModel] = []
        
        for productFamilyName in productFamilyNames {
            
            let productFamily = ProductFamilyModel(name: productFamilyName)
            
            for partDetail in partDetails {
                
                if partDetail.productFamily == productFamilyName {
                    productFamily.partNumbers.append(partDetail)
                }
            }
            productFamilies.append(productFamily)
        }
        return productFamilies
    }
}

extension ProductFamilyModel : Hashable {
    
    static func == (lhs: ProductFamilyModel, rhs: ProductFamilyModel) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }
}

struct Product {
    
    var partNumber    : String = "part number"
    var productFamily : String = "product family"
    var description   : String = "description"
}

class ProductModel: ObservableObject, Identifiable  {
    
    var id = UUID().uuidString
    var partNumber    : String
    var productFamily : String
    var description   : String
    
    init(model: Product) {
        self.partNumber    = model.partNumber
        self.productFamily = model.productFamily
        self.description   = model.description
    }
    static func loadData() -> Set<ProductModel> {
        
        let productDetails : Set<ProductModel> = [
            ProductModel(model: Product(
                partNumber: "100-1111-101",
                productFamily: "Product Family 1",
                description: "Part Number 100-1111-101"
            )),
            ProductModel(model: Product(
                partNumber: "100-1111-102",
                productFamily: "Product Family 1",
                description: "Part Number 100-1111-102"
            )),
            ProductModel(model: Product(
                partNumber: "100-1111-103",
                productFamily: "Product Family 1",
                description: "Part Number 100-1111-103"
            )),
            ProductModel(model: Product(
                partNumber: "200-1111-101",
                productFamily: "Product Family 2",
                description: "Part Number 200-1111-101"
            )),
            ProductModel(model: Product(
                partNumber: "200-1111-102",
                productFamily: "Product Family 2",
                description: "Part Number 200-1111-102"
            )),
            ProductModel(model: Product(
                partNumber: "200-1111-103",
                productFamily: "Product Family 2",
                description: "Part Number 200-1111-103"
            )),
            ProductModel(model: Product(
                partNumber: "300-1111-101",
                productFamily: "Product Family 3",
                description: "Part Number 300-1111-101"
            )),
            ProductModel(model: Product(
                partNumber: "300-1111-102",
                productFamily: "Product Family 3",
                description: "Part Number 300-1111-102"
            )),
            ProductModel(model: Product(
                partNumber: "300-1111-103",
                productFamily: "Product Family 3",
                description: "Part Number 300-1111-103"
            ))
        ]
        return productDetails
    }
}

extension ProductModel : Hashable {
    
    static func == (lhs: ProductModel, rhs: ProductModel) -> Bool {
        return lhs.id == rhs.id && lhs.partNumber == rhs.partNumber && lhs.productFamily == rhs.productFamily && lhs.description == rhs.description
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(partNumber)
        hasher.combine(productFamily)
        hasher.combine(description)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(NavigationModel())
    }
}

