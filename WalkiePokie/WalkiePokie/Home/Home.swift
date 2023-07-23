//
//  Home.swift
//  WalkiePokie
//
//  Created by Vatsal Vipulkumar Patel on 7/22/23.
//

import SwiftUI
import ArcGIS
import CoreLocation

struct Home: View {
    //    private let map = Map(basemapStyle: .arcGISNavigation)
    private let locationDisplay = LocationDisplay(dataSource: SystemLocationDataSource())
    
    @State private var locationManager = LocationManager()
    @State private var map: Map? = nil
    
    @State private var showMapTrial = false
    
    @State private var isAddressSearchPresented = false
    @State private var isBottomSheetPresented = false
    @State private var searchText = ""
    @State private var suggestions: [Suggestion] = []
    
    @State private var destination: Suggestion? = nil
    @State private var isActive: Bool = false

    let modelMapSharedInstance = ModelMap.shared
    
    var body: some View {
        NavigationView {
            if(!showMapTrial) {
                ZStack {
                    if let map = map {
                        MapView(map: map)
                            .locationDisplay(locationDisplay)
                            .task {
                                let locationManager = CLLocationManager()
                                locationManager.requestWhenInUseAuthorization()
                                do {
                                    try await locationDisplay.dataSource.start()
                                    locationDisplay.initialZoomScale = 72_000
                                    locationDisplay.autoPanMode = .recenter
                                    if(modelMapSharedInstance.routeStops.count >= 2) {
                                        modelMapSharedInstance.routeStops.removeLast()
                                        print(modelMapSharedInstance.routeStops.count)
                                        print("END")
                                    }
                                } catch {
                                    print(error)
                                }
                            }
                    }
                    
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                centerToCurrentLocation()
                            }) {
                                Image(systemName: "location.circle.fill")
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color(hex: 0x3A434E))
                                    .clipShape(Circle())
                            }
                            .padding()
                        }
                        Spacer()
                    }.padding(.top, 60)
                    
                    // Bottom sheet
                    VStack(alignment: .leading) {
                        Divider()
                        if(destination == nil) {
                            TextField("Search destination...", text: $searchText)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(Color(hex: 0x3A434E))
                                .cornerRadius(5)
                                .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color(hex: 0xBDC0C4), lineWidth: 1)
                                )
                                .padding()
                                .onTapGesture {
                                    withAnimation {
                                        isBottomSheetPresented.toggle()
                                    }
                                }
                        }
                        
                        if suggestions.isEmpty || searchText.isEmpty  {
                            VStack(alignment: .leading) {
                                Text("Let’s go for a walk")
                                    .font(.custom(FontManager.Montserrat.regular, size: 16).weight(.regular))
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 15)
                                    .foregroundColor(Color(hex: 0x3A434E))
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 12) {
                                        ForEach(0..<10) { index in
                                            VStack{
                                                Text("\(10 * (index + 1)) - \(10 * (index + 2))")
                                                Text("Mins")
                                            }
                                            .font(.custom(FontManager.Montserrat.regular, size: 16).weight(.regular))
                                            .padding(20)
                                            .foregroundColor(Color(hex: 0x3A434E))
                                            .background(Color(hex: 0xB3CFF2))
                                            .cornerRadius(5)
                                        }
                                    }.padding(.horizontal)
                                }
                            }
                        }
                        Spacer()
                        
                        if !suggestions.isEmpty && !searchText.isEmpty  {
                            SearchResultsView(suggestions: suggestions, searchText: $searchText, destination: $destination, isBottomSheetPresented: $isBottomSheetPresented, showMapTrial: $showMapTrial)
                        }
                        
                        
                    }
                    .background(Color.white)
                    .cornerRadius(20)
                    .modifier(BottomSheetViewModifier(isPresented: $isBottomSheetPresented, destination: $destination))
                }
                .onAppear {
                    Task {
                        map = await initializeMap()
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .onChange(of: searchText) { _ in
                    fetchSearchData()
                }
                
            }
            else {
                List {
                    HStack {
                        let firstPart = destination!.text.split(separator: ",").first ?? ""
                        Text("Esri HQ - " + String(firstPart))
                            .font(.custom(FontManager.Montserrat.regular, size: 16))
                        Spacer()
                        Button(action: {
                            // Here is where you navigate to your view.
                            self.isActive = true
                        }) {
                            Text("Go")
                                .font(.custom(FontManager.Montserrat.regular, size: 16))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 20)
                                .background(Color(hex: 0xFFC700))
                                .foregroundColor(Color(hex: 0x3A434E))
                                .cornerRadius(20)
                        }
                        .padding(.horizontal,8)
                    }
                }
                .navigationTitle("Safe Routes")
                .background(NavigationLink(destination: MapRoute().onDisappear {
                    showMapTrial = false
                    destination = nil
                }, isActive: $isActive) { EmptyView() }.hidden())
            }
        }
    }
    
    private func initializeMap() async -> Map {
        let item = PortalItem(
            portal: .arcGISOnline(connection: .anonymous),
            id: PortalItem.ID("153ee1c7e66745888361852acf8608aa")!
        )
        return Map(item: item)
    }
    
    func centerToCurrentLocation() {
        locationDisplay.autoPanMode = .recenter
    }
    
    private func fetchSearchData() {
        guard let encodedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Invalid search text")
            return
        }
        
        guard let url = URL(string: "https://geocode-api.arcgis.com/arcgis/rest/services/World/GeocodeServer/suggest?text=\(encodedSearchText)&f=json&token=AAPK952cfc45d84148fc9424e47cc893bb241Yi_-7sshjErQzetrfsJSQTVjztTsU8_HbhOv5-nIIdZMiP1iH7X8coF8dGuvhc0&location=\(locationManager.longitude),\(locationManager.latitude)") else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Decode the received JSON data
            do {
                let decoder = JSONDecoder()
                let responseData = try decoder.decode(APIResponse.self, from: data)
                DispatchQueue.main.async {
                    self.suggestions = responseData.suggestions
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        
        task.resume()
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}

struct APIResponse: Codable {
    let suggestions: [Suggestion]
}

