//
//  Maps Trial.swift
//  WalkiePokie
//
//  Created by Vatsal Vipulkumar Patel on 7/21/23.
//

import ArcGIS
import SwiftUI

class ModelMap: ObservableObject {
    
    static let shared = ModelMap()
    @Published var currentRouteResult: RouteResult? = nil
    
    let map: Map = {
        let item = PortalItem(
            portal: .arcGISOnline(connection: .anonymous),
            id: PortalItem.ID("8bbd009485e142b18746367dd52d9aa7")!
        )
        let map = Map(item: item)
        map.initialViewpoint =
        Viewpoint(
            latitude: 34.053667,
            longitude: -117.205035,
            scale: 10000
        )
        return map
    }()
    
    /// A graphic to symbolize the start point of the route.
    let originGraphic: Graphic = {
        let symbol = SimpleMarkerSymbol(style: .circle, color: .white, size: 12)
        symbol.outline = SimpleLineSymbol(style: .solid, color: .black, width: 2)
        let graphic = Graphic(geometry: nil, symbol: symbol)
        return graphic
    }()
    
    /// A graphic to symbolize a midway stop of the route.
    let stopGraphic: Graphic = {
        let symbol = SimpleMarkerSymbol(style: .circle, color: .white, size: 8)
        symbol.outline = SimpleLineSymbol(style: .solid, color: .black, width: 2)
        let graphic = Graphic(geometry: nil, symbol: symbol)
        return graphic
    }()
    
    /// A graphic to symbolize the end point of the route.
    let destinationGraphic: Graphic = {
        let symbol = SimpleMarkerSymbol(style: .circle, color: .black, size: 12)
        symbol.outline = SimpleLineSymbol(style: .solid, color: .white, width: 2)
        let graphic = Graphic(geometry: nil, symbol: symbol)
        return graphic
    }()
    
    /// A graphic to symbolize the route polyline.
    let routeGraphic: Graphic = {
        let symbol = SimpleLineSymbol(style: .solid, color: UIColor(red: 0.23, green: 0.26, blue: 0.3, alpha: 1.00), width: 8)
        let graphic = Graphic(geometry: nil, symbol: symbol)
        return graphic
    }()
    
    /// A graphics overlay to display the route.
    let routeGraphicsOverlay = GraphicsOverlay()
    
    /// The route task to solve the route between stops, using the online routing service.
    let routeTask = RouteTask(url: URL(string: "https://route-api.arcgis.com/arcgis/rest/services/World/Route/NAServer/Route_World")!)
    
    /// Stops to demo route solving.
    @Published var routeStops = [
        Stop(point: Point(x: -117.205035, y: 34.053667, spatialReference: .wgs84)), // origin
        Stop(point: Point(x: -117.197471, y: 34.057274, spatialReference: .wgs84)) // destination
    ]
    
    /// Sets the geometries and adds graphics to the graphics overlay.
    func makeGraphics() {
        print(routeStops.count)
        originGraphic.geometry = routeStops[0].geometry
        destinationGraphic.geometry = routeStops[1].geometry
        // Adds the graphic to the graphics overlay.
        routeGraphicsOverlay.addGraphics([
            originGraphic,
            stopGraphic,
            destinationGraphic,
            routeGraphic
        ])
    }
    
    func solveRoute(stops: [Stop]) async throws -> [String] {
        let parameters = try await routeTask.makeDefaultParameters()
        // Sets up additional route parameters.
        parameters.setStops(stops)
        parameters.returnsDirections = true
        parameters.directionsLanguage = "en"
        parameters.travelMode = routeTask.info.travelModes.first { $0.name == "Walking Time" }
        // Solves the route.
        let routeResult = try await routeTask.solveRoute(using: parameters)
        // Displays route and print directions.
        let solvedRoute = routeResult.routes.first
        routeGraphic.geometry = solvedRoute!.geometry
        //        try await startRoute(routeResult: routeResult)
        //        return routeResult
        let directions = solvedRoute!.directionManeuvers.map { $0.text }
        print(directions.joined(separator: "\n"))
        return directions
    }
    
    func geocode(address: String) async -> ArcGIS.Point {
        let locatorTask = LocatorTask(url: URL(string: "https://geocode-api.arcgis.com/arcgis/rest/services/World/GeocodeServer")!)
        
        do {
            let geocodeResults = try await locatorTask.geocode(forSearchText: address)
            guard let firstResult = geocodeResults.first else { return  ArcGIS.Point(latitude: 0.0, longitude: 0.0) }
            let newStop = Stop(point: firstResult.displayLocation!)
            routeStops.append(newStop)
            return firstResult.displayLocation!
        } catch {
            print(error)
        }
        return ArcGIS.Point(latitude: 0.0, longitude: 0.0)
    }
}
//}
//    func startRoute(routeResult: RouteResult) async throws {
//        // Creates route parameters and graphics
//        guard let parameters = try? await routeTask.makeDefaultParameters() else {
//            throw NSError(domain: "Could not create route parameters.", code: 0, userInfo: nil)
//        }
//        let (routeAheadGraphic, routeTraveledGraphic) = createRouteGraphics()
//
//        // Creates a route tracker
//        guard let routeTracker = await createRouteTracker(routeResult: routeResult, routeParameters: parameters) else {
//            throw NSError(domain: "Could not create route tracker.", code: 0, userInfo: nil)
//        }
//
//        // Sets up rerouting if supported
//        try await setupReroutingIfSupported(routeTask: routeTask, routeParameters: parameters, routeTracker: routeTracker)
//
//        // Creates and starts a location display
//        try await startLocationDisplay(routeTracker: routeTracker)
//
//        // Monitors the tracking status
//        for await status in routeTracker.$trackingStatus {
//            updateTrackingStatus(status: status, routeAheadGraphic: routeAheadGraphic, routeTraveledGraphic: routeTraveledGraphic)
//        }
//    }
//
//    func createRouteGraphics() -> (Graphic, Graphic) {
//        // Creates a graphic to represent the route that remains to be traveled (initially the entire route).
//        let routeAheadSymbol = SimpleLineSymbol(style: .dash, color: .blue, width: 5)
//        let routeAheadGraphic = Graphic(geometry: routeGraphic.geometry, symbol: routeAheadSymbol)
//
//        // Creates a graphic to represent the route that's been traveled (initially empty).
//        let routeRemainsSymbol = SimpleLineSymbol(style: .solid, color: .green, width: 3)
//        let routeTraveledGraphic = Graphic(symbol: routeRemainsSymbol)
//
//        return (routeAheadGraphic, routeTraveledGraphic)
//    }
//
//    func createRouteTracker(routeResult: RouteResult, routeParameters: RouteParameters) async -> RouteTracker? {
//        // Passes the route result to a new route tracker along with the index of the route to navigate.
//        let routeTracker = RouteTracker(routeResult: routeResult, routeIndex: 0, skipsCoincidentStops: false)
//
//        // Monitors the tracking status stream.
//        guard let trackingStatusStream = routeTracker?.$trackingStatus else {
//            print("Tracking status stream is nil.")
//            return nil
//        }
//
//        for await status in trackingStatusStream {
//            print(status!)
//        }
//
//        return routeTracker
//    }
//
//
//    func setupReroutingIfSupported(routeTask: RouteTask, routeParameters: RouteParameters, routeTracker: RouteTracker) async throws {
//        // Checks if the route task supports rerouting when a user goes off-route.
//        if routeTask.info.supportsRerouting {
//            // Creates rerouting parameters and sets its properties.
//            guard let reroutingParameters = ReroutingParameters(routeTask: routeTask, routeParameters: routeParameters) else {
//                throw NSError(domain: "Could not create rerouting parameters.", code: 0, userInfo: nil)
//            }
//            reroutingParameters.strategy = .toNextWaypoint
//            reroutingParameters.visitsFirstStopOnStart = false
//
//            // Enables rerouting by passing in the rerouting parameters.
//            try await routeTracker.enableRerouting(using: reroutingParameters)
//        }
//        routeTracker.rerouteCompleted = { trackingStatus, error in
//            if let error {
//                print(error)
//            } else {
//                print(trackingStatus)
//            }
//        }
//    }
//
//    func startLocationDisplay(routeTracker: RouteTracker) async throws {
//        // Creates a data source to use as the location display.
//        let routeTrackerLocationDataSource = RouteTrackerLocationDataSource(routeTracker: routeTracker)
//
//        // Creates a location display.
//        let locationDisplay = LocationDisplay(dataSource: routeTrackerLocationDataSource)
//        locationDisplay.autoPanMode = .navigation
//
//        // Starts the map view's location display.
//        try await routeTrackerLocationDataSource.start()
//    }
//
//    func updateTrackingStatus(status: TrackingStatus?, routeAheadGraphic: Graphic, routeTraveledGraphic: Graphic) {
//        if let status, status.isOnRoute {
//            // Gets the lines representing the route ahead and the route already traveled.
//            let lineToTravel = status.routeProgress.remainingGeometry
//            let lineTraveled = status.routeProgress.traversedGeometry
//
//            // Updates the route graphics.
//            routeAheadGraphic.geometry = lineToTravel
//            routeTraveledGraphic.geometry = lineTraveled
//
//            // Prints the remaining distance and time.
//            print("Distance remaining: \(status.routeProgress.remainingDistance.displayText) \(status.routeProgress.remainingDistance.displayTextUnits)")
//            print("Time remaining: \(status.routeProgress.remainingTime)")
//        } else {
//            print("Off Route")
//        }
//    }
//}

