# LegoKit

A simple & elegant architecture framework inspired by Redux and Lego to build SwiftUI apps

# Introduction 

# Installation

Install using [Swift Package Manager](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app)

To add a package dependency to your Xcode project, select File > Swift Packages > Add Package Dependency and enter its repository URL

```
https://github.com/gabrielleyva/LegoKit.git
```

Supports the following versions:
* `iOS 13+`
* `macOS 10.15+`
* `tvOS 13+`

### NOTE
`LegoKit` is in early `alpha` and currently not ready for production. The following items/features are currently being worked on:

1. Documentation / Framework Comments
2. Navigation
3. Unit Tests
4. Ensure Thread Safety
5. Performance Tests 


# Basic Concepts


## Designs

Let's start with a `Design`. A `Design` is the structured data representation of what will be rendered in your `View`. Essentially, it represents the building blocks of what will be displayed. It is how you will choose to design your data models. That is why we are calling it a `Design`.

When declaring a `Design` it is important to make sure it is conformed to `Equatable`.

```swift
public struct Design: Equatable {
    var name: String = ""
    var address: String = ""
    var city: String = ""
    var state: String = ""
    var zipcode: String = ""
    var images: [Image] = []
}
```

## Changes

A `Change` represents types of requests that will be used to mutate a `Design`. A `Change` can get triggered by user input or an internal process such as an `async` **API** call *(more on this later)*.

When declaring a `Change` it is important to make sure it is conformed to `Equatable`.

```swift
public enum Change: Equatable {
    case name(String)
    case address(String)
    case city(String)
    case state(String)
    case zipcode(String)
}
```

## Blueprints

Now, what happens when we combine a `Design` and `Change`? Well, we get a `Blueprint`. A `Blueprint` is what a `View` will use to access specific `Design`. If you think of blueprints as being a set of instructions a builder can use to build things; then, in our case the builders are the views and they will use our `Blueprint` to put everything together. 

For sake of modularity, a `Blueprint` should focus on specific functionality in the app. You could potentially create them in terms of features your app will have. For example, if our app was a house we could create a `KitchenBlueprint`, `LivingRoomBlueprint`, `MasterBedroomBlueprint` etc. Then you could also combine them all into a `HouseBlueprint` *(more on this later)* 

In order to create a `Blueprint` we first have to declare a `Struct` and have it conform to the protocol `Blueprint`.

```swift
public struct HouseBlueprint: Blueprint {}
```

The `Blueprint` requires a `typealias` `Design` so we can go ahead and add it as follows:

```swift
public struct HouseBlueprint: Blueprint {
    
    // MARK: - Design    
   
    public struct Design: Equatable {
        var name: String = ""
        var address: String = ""
        var city: String = ""
        var state: String = ""
        var zipcode: String = ""
        var images: [Image] = []
    }
}
```

It will also requires a `typealias` `Change` 

```swift
public struct HouseBlueprint: Blueprint {

    ...

    // MARK: - Change

    public enum Change: Equatable {
        case name(String)
        case address(String)
        case city(String)
        case state(String)
        case zipcode(String)
        case onSubmit
    }
}
```

```swift
public struct HouseBlueprint: Blueprint {

        ...

    // MARK: - Perform Changes On Design

    public func change(_ design: inout Design, on change: Change) {
        switch change {
        case .name(let text):
            design.name = text

        case .address(let text):
            design.address = text

        case .city(let text):
            design.city = text

        case .state(let text):
            design.state = text

        case .zipcode(let text):
            design.zipcode = text

        case .onSubmit:
        }
    }
}

```

## Bricks

```swift
public struct HouseBlueprint: Blueprint {
    
    public static var brick: HouseBlueprint = HouseBlueprint()

    ...
}
```

```swift
public extension Bricks {
    var house: HouseBlueprint {
        get { Self[HouseBlueprint.Value.self] }
        set { Self[HouseBlueprint.Value.self] = newValue }
    }
}
```

```swift
public struct AppBlueprint: Blueprint {
    
    // MARK: - Bricks

    @Brick (\.house) private var house
    
     // MARK: - Bricks

    public struct Design: Equatable {
        var title: String = "Lego Kit Demo!"
        var house: HouseBlueprint.Design = HouseBlueprint.Design()
    }

    // MARK: - Change

    public enum Change: Equatable {
        case house(HouseBlueprint.Change)
    }

     // MARK: - Perform Changes On Design

    public func change(_ design: inout Design, on change: Change) {
        switch change {
        case .house(let houseChange):
            house.change(&design.house, on: houseChange)
        }
    }
}
```

## Legos

# Async Capabilities

## Services

```swift
public struct PermissionsService: Service {
    
    public static var contractor: PermissionsService = PermissionsService()
}
```

```swift
public struct PermissionsService: Service {

    ...

    public func requestStatus() -> (camera: PermissionStatus, album: PermissionStatus)  {
        let camera: PermissionStatus = .init(avAuthorizationStatus: AVCaptureDevice.authorizationStatus(for: .video))
        let album: PermissionStatus = .init(phAuthorizationStatus: PHPhotoLibrary.authorizationStatus(for: .readWrite))
        return (camera: camera, album: album)
    }
    
    public func requestCameraAccess() async -> PermissionStatus {
        return await withCheckedContinuation { continuation in
            self.requestCaptureAccess(completion: { status in
                let camera: PermissionStatus = .init(avAuthorizationStatus: status)
                continuation.resume(returning: camera)
            })
        }
    }
    
    private func requestCaptureAccess(completion: @escaping (AVAuthorizationStatus) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            var status: AVAuthorizationStatus = .notDetermined
            if granted {
                status = .authorized
            }
            completion(status)
        }
    }
}
```

## Contractors

```swift
public extension Contractors {
    var permissions: PermissionsService {
        get { Self[PermissionsService.Value.self] }
        set { Self[PermissionsService.Value.self] = newValue }
    }
}
```

```swift
public class PermissionsAdaptor: Adaptor<AppBlueprint> {
    
    // MARK: - Contractors
    
    @Contractor(\.permissions) private var permissionsService: PermissionsService
}
```

## Adaptors

```swift
public class PermissionsAdaptor: Adaptor<AppBlueprint> {
     
     ...

    // MARK: - Connector
    
    public override func connect(_ design: AppBlueprint.Design, on change: AppBlueprint.Change) -> AnyPublisher<AppBlueprint.Change, Never> {
        return Future<AppBlueprint.Change, Never> { promise in
            
            switch change {
            case .permission(let permissionsChange):
                switch permissionsChange {
                case .requestPermissionStatus:
                    let (camera, album) = self.permissionsService.requestStatus()
                    promise(.success(.permission(.permissionStatus(camera: camera, album: album))))
                                        
                case .requestCameraAccess:
                    Task {
                        let camera = await self.permissionsService.requestCameraAccess()
                        promise(.success(.permission(.cameraAccess(camera))))
                    }
                }

            default:
                break
            }
            
        }
        .eraseToAnyPublisher()
    }
}
```

# Usage

### The Redux Approach
```swift
@main
struct MyApp: App {
    
    let lego: Lego<AppBlueprint> = .init(.init(),
                                          blueprint: AppBlueprint(),
                                          adaptors: [DeviceAdaptor()])
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(lego)
        }
    }
}
```

```swift
struct ContentView: View {
    
    @EnvironmentObject private var lego: Lego<AppBlueprint>
    
    var body: some View {
        VStack(spacing: 16) {
            Text(lego.design.title)
                .font(.largeTitle)
            
            Text(lego.design.house.name)
                .font(.largeTitle)
            
            TextField("Address",
                      text: lego.glue(\.house.address, change: {
                .house(.address($0))
            }))
            
            TextField("City",
                      text: lego.glue(\.house.city, change: {
                .house(.city($0))
            }))
            
            TextField("State",
                      text: lego.glue(\.house.address, change: {
                .house(.address($0))
            }))
            
            Button("Submit Change") {
                lego.build(.house(.onSubmit))
            }
            
            Spacer()
        }
        .padding()
    }
}
```

### The MVVM Approach

```swift
struct ContentView: View {
    
    @ObservedObject private var test: Lego<HouseBlueprint> = .init(.init(),
                                                                   blueprint: HouseBlueprint())
    
    var body: some View {
        VStack(spacing: 16) {
            Text(lego.design.title)
                .font(.largeTitle)
            
            Text(lego.design.name)
                .font(.largeTitle)
            
            TextField("Address",
                      text: lego.glue(\.address, change: {
                .house(.address($0))
            }))
            
            TextField("City",
                      text: lego.glue(\.city, change: {
                .house(.city($0))
            }))
            
            TextField("State",
                      text: lego.glue(\.address, change: {
                .house(.address($0))
            }))
            
            Button("Submit Change") {
                lego.build(.onSubmit)
            }
            
            Spacer()
        }
        .padding()
    }
}
```

# Logging

Every `Lego` you create will have the ability to log the changes happening on your designs in a pretty print format.

The logs are disabled by default. If you would like to enable them for a specific `Lego` you can do so by setting the flag through the `init` constructor.

```swift
.init(.init(),
      blueprint: AppBlueprint(),
      adaptors: [PermissionsAdaptor(), ImageAdaptor()],
      enableLogs: true)
```