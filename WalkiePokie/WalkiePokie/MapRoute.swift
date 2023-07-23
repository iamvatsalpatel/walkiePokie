//
//  MapRoute.swift
//  WalkiePokie
//
//  Created by Vatsal Vipulkumar Patel on 7/22/23.
//
//

import Foundation
import SwiftUI
import ArcGIS

struct MapRoute: View {
    let modelMapSharedInstance = ModelMap.shared
    @State private var isSheetPresented = false
    @State private var isDataLoaded = false
    @State var directions: [String]? = nil
    @State private var map: Map? = nil
    @State private var isWebViewPresented = false
    @State private var isWebView1Presented = false
    @State private var bottomSheetPresented = false
    @State private var selectedUrl: URL? = nil
    @State private var showLastPage = false
    
    var body: some View {
        ZStack {
            if !showLastPage {
                MapView(map: modelMapSharedInstance.map, graphicsOverlays: [modelMapSharedInstance.routeGraphicsOverlay])
                    .task {
                        do {
                            modelMapSharedInstance.makeGraphics()
                            self.directions = try await modelMapSharedInstance.solveRoute(stops: modelMapSharedInstance.routeStops)
                            self.isDataLoaded = true
                            print(directions!)
                        } catch {
                            print(error)
                        }
                    }
                if isDataLoaded {
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                self.showLastPage.toggle()
                            }) {
                                Text("End")
                                    .font(.custom(FontManager.Montserrat.regular, size: 24).weight(.regular))
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 20)
                                    .foregroundColor(Color(hex: 0x3A434E))
                                    .background(Color(UIColor(red: 1, green: 0.78, blue: 0, alpha: 1)))
                                    .cornerRadius(10)
                            }
                            .padding()
                            
                        }
                        Spacer()
                    }.padding(.top, 120)
                    
                    VStack {
                        Spacer()
                        HStack(alignment: .bottom) {
                            VStack{
                                Button(action: {
                                    isSheetPresented.toggle()
                                }) {
                                    Image(systemName: "location.circle.fill")
                                        .font(.system(size: 22))
                                        .padding(22)
                                        .foregroundColor(Color(hex: 0xB3CFF2))
                                        .background(Color(hex: 0x3A434E))
                                        .clipShape(Circle())
                                }
                                .sheet(isPresented: $isSheetPresented) {
                                    VStack {
                                        Text("Directions:")
                                            .font(.custom(FontManager.Montserrat.bold, size: 20).weight(.black))
                                            .padding(.top)
                                            .foregroundColor(Color(hex: 0x3A434E))
                                        if(isDataLoaded) {
                                            List {
                                                ForEach(directions ?? [], id: \.self) { direction in
                                                    Text(direction)
                                                        .font(.custom(FontManager.Montserrat.regular, size: 16).weight(.regular))
                                                        .foregroundColor(Color(hex: 0x3A434E))

                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            Spacer()
                            VStack{
                                Button(action: {
                                    isWebView1Presented = true
                                }) {
                                    Image("Blue gem")
                                        .resizable()
                                        .frame(width: 22.8, height: 20)
                                        .padding(22)
                                        .background(Color(hex: 0x3A434E))
                                        .clipShape(Circle())
                                }
                                .sheet(isPresented: $isWebView1Presented) {
                                    WebView(url: URL(string: "https://arcg.is/0aHDH8")!)
                                }
                                Button(action: {
                                    bottomSheetPresented.toggle()
                                }) {
                                    Image("Blue flag")
                                        .resizable()
                                        .frame(width: 20, height: 22.8)
                                        .padding(22)
                                        .background(Color(hex: 0x3A434E))
                                        .clipShape(Circle())
                                }
                                .sheet(isPresented: $bottomSheetPresented) {
                                    NavigationView {
                                        VStack{
                                            Image("Report")
                                                .resizable()
                                                .frame(width: 300, height: 200)
                                                .padding(.vertical, 25)
                                            Text("What do you want to share with us?")
                                                .font(.custom(FontManager.Montserrat.regular, size: 16).weight(.regular))
                                            
                                            NavigationLink(destination: WebView(url: URL(string: "https://arcg.is/PriaP")!)) {
                                                Text("Hidden Gems")
                                                    .frame(minWidth: 0, maxWidth: .infinity)
                                                    .padding(.horizontal, 30)
                                                    .padding(.vertical, 15)
                                                    .foregroundColor(Color(hex: 0x3A434E))
                                                    .background(Color(hex: 0xB3CFF2))
                                                    .cornerRadius(10)
                                            }
                                            .padding(.horizontal)
                                            
                                            NavigationLink(destination: WebView(url: URL(string: "https://arcg.is/1SD0v42")!)) {
                                                Text("Report")
                                                    .frame(minWidth: 0, maxWidth: .infinity)
                                                    .padding(.horizontal, 30)
                                                    .padding(.vertical, 15)
                                                    .foregroundColor(Color(hex: 0x3A434E))
                                                    .background(Color(hex: 0xB3CFF2))
                                                    .cornerRadius(10)
                                            }
                                            .padding(.horizontal)
                                            .padding(.vertical, 10)
                                        }
                                    }
                                }
                                
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                    }
                }
            } else {
                Image("Last Page")
                    .resizable()
                    .padding(.top, 60)
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            //Do nothing
                        } label: {
                            Image(systemName: "house")
                                .padding()
                                .foregroundColor(.white)
                                .background(Color(hex: 0x3A434E))
                                .clipShape(Circle())
                        }
                        .padding()
                    }
                    Spacer()
                }.padding(.top, 60)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct MapRoute_Preview: PreviewProvider {
    static var previews: some View {
        MapRoute()
    }
}
