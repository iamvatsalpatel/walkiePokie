//
//  SearchResultsView.swift
//  WalkiePokie
//
//  Created by Vatsal Vipulkumar Patel on 7/22/23.
//

//import SwiftUI
//
//struct SearchResultsView: View {
//    let suggestions: [Suggestion]
//    @Binding var searchText: String
//    @Binding var isSettingOrigin: Bool
//    @Binding var origin: Suggestion?
//    @Binding var destination: Suggestion?
//    @Binding var isBottomSheetPresented: Bool
//
//    var body: some View {
//        List(suggestions, id: \.magicKey) { suggestion in
//            VStack(alignment: .leading) {
//                Text(suggestion.text)
//                    .font(.headline)
//            }
//            .padding(.vertical, 8)
//            .onTapGesture {
//                if isSettingOrigin {
//                    origin = suggestion
//                    print(origin?.text ?? "Nothing")
//                    isSettingOrigin.toggle()
//                } else {
//                    destination = suggestion
//                    print(destination?.text ?? "Nothing")
//                    isBottomSheetPresented = false
//                }
//                searchText = ""
//            }
//        }
//        .background(Color.white)
//    }
//}


import SwiftUI

struct SearchResultsView: View {
    let suggestions: [Suggestion]
    @Binding var searchText: String
    @Binding var destination: Suggestion?
    @Binding var isBottomSheetPresented: Bool
    @Binding var showMapTrial: Bool
    let modelMapSharedInstance = ModelMap.shared
    
    var body: some View {
        List(suggestions, id: \.magicKey) { suggestion in
            VStack(alignment: .leading) {
                Text(suggestion.text)
                    .font(.headline)
            }
            .padding(.vertical, 8)
            .onTapGesture {
                destination = suggestion
                print(destination?.text ?? "Nothing")
                
                
                // Set showMapTrial to true when both origin and destination are set
                if destination != nil {
                    showMapTrial = true
                }
                searchText = ""
                print(modelMapSharedInstance.routeStops.count)
                Task {
                    _ = await modelMapSharedInstance.geocode(address: destination?.text ?? "")
                    print(modelMapSharedInstance.routeStops.count)
                    print("End")
                }
                isBottomSheetPresented = false
            }
        }
        .background(Color.white)
    }
}
