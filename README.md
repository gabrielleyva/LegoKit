# LegoKit

A simple & elegant architecture framework inspired by Redux and Lego to build SwiftUI apps

# Introduction 

# Installation 📩

Install using [Swift Package Manager](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app)

To add a package dependency to your Xcode project, select File > Swift Packages > Add Package Dependency and enter its repository URL

```
https://github.com/gabrielleyva/LegoKit.git
```

Supports the following versions:
* `iOS 13+`
* `macOS 10.15+`
* `tvOS 13+`

### NOTE ☠️
`LegoKit` is in early `alpha` and currently not ready for production. The following items/features are currently being worked on:

1. Documentation
3. Unit Tests
4. Thread Safety
5. Performance Tests 

# Basic Concepts

## Designs 🎨 

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

## Changes 🚀

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

## Blueprints 🧬 

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

## Bricks 🧱

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

## Legos 🏰

# Async Capabilities

## Services 📡

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

## Contractors 👷

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

## Adaptors 🔌

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

# Logging 🐞

Every `Lego` you create will have the ability to log the changes happening on your designs in a pretty print format.

The logs are disabled by default. If you would like to enable them for a specific `Lego` you can do so by setting the flag through the `init` constructor.

```swift
.init(.init(),
      blueprint: AppBlueprint(),
      adaptors: [PermissionsAdaptor(), ImageAdaptor()],
      enableLogs: true)
```

# Routing 🏎️

In today's `SwiftUI` there are plenty of great custom solutions for routing and navigation. There are frameworks that act as view builders and even SDKs that use declarative programming to create custom routes. 

In `LegoKit`, we provide you with an optional built in solution that takes care of routing for you. However, you are free to use your preferred method if our routing does not get the job done. 

Let's dive into `LegoKit` routing!

## Routing 

The first step is to create a service, resolver or provider that confroms to the `Routing` protocol. In this `Struct` is where you will be able to implement your routing logic.

If you are familiar with `Stores`, `Reducers` and `Actions` this should feel pretty familiar with some minor differences. Or if you already undertand how the `LegoKit` framework works then this should be pretty straightforward as well. 

So... you might end up with something like this:

```swift
public struct RoutingService: Routing {
    
    public struct State: RouterState {
        public enum Views {
            case splash
            case loading
            case home
        }
        
        public var view: Views = .loading
    }

    public enum Route {
        case splash
        case loading
        case home
    }
    
    public func route(to route: Route, on state: inout State) {}
    
    public func route(with url: URL, on state: inout State) {}
}
```

The main idea here is that your `RouterState` will declare an `enum` that contains all the types of views that are routable within your app. It will also hold a `view` property that will reference which view should be rendered (more on this later).

You will also get two functions that are responsbile for updating your `RouterState` using a `Route` or `URL`. 

Now, think of your `Route` as an action or change that will trigger a specific update on your `RouterState`. Your `Route` cases don't necessarily need to match your `View` cases, but for the most part they will.

A more complete routing service may look as follows:

```swift
public struct RoutingService: Routing {
    
    public struct State: RouterState {
        
        public enum Views {
            case splash
            case loading
            case permissions
            case editor
            case export
        }
        
        public var view: Views = .loading
        public var displayToolsSheet: Bool = false
    }

    public enum Route {
        case splash
        case loading
        case permissions
        case editor
        case export
        case tools(Bool)
    }
    
    public func route(to route: Route, on state: inout State) {
        switch route {
        case .splash:
            state.view = .splash
            
        case .loading:
            state.view = .loading
            
        case .permissions:
            state.view = .permissions
            
        case .editor:
            state.view = .editor
            
        case .export:
            state.view = .export
            
        case .tools(let display):
            if state.view != .editor {
                state.view = .editor
            }
            state.displayToolsSheet = display
        }
    }
    
    public func route(with url: URL, on state: inout State) {}
}
```

As you can see above, I've added a `displayToolsSheet` property in my `RouterState` that will be responsible for toggleing a `sheet` that is specific to the `editor` view. We will cover how the `Binding` of the sheet works later on. 

You might also note that when I'm routing to the `editor` view, I just update the `RouterState` `view` property to `editor`. However, when I'm routing to `tools`, I'm only updating the `view` property if it doesn't already equal do `editor`. This is to avoid an unecessary change that could cause a `SwiftUI` `View` to perfrom a redraw from a parent `View`. 

So, if I want to route from `loading` to `tools`, and my `ToolSheet()` is part of the `editor` view, then I need to update my `view` property to `editor` first. Then, I can update my `displayToolsSheet` property. However, if I want to route to `tools` and I'm already rendering my `editor` view. Then all I have to do is update my `displayToolsSheet` property. 

I'll show you how this all works on a `View` later on. 

## Router State

Your `State` wihtin your `Routing` service needs to conform to `RouterState`. This is the place where you will define and declare all the properties that make up the data structure that will decide what `View` will be rendered in your app. 

Inside your `RouterState` you will also need to define and declare all the `Views` you want to route to in your app. And of course, the `RouterState` will hold a reference to the current view that needs to be displayed.  

So again, you might have something like this:

```swift
public struct State: RouterState {
    public enum Views {
        case splash
        case loading
        case home
    }
        
    public var view: Views = .loading
    public var displaySheet: Bool = false // Custom property
}
```
## Route

Your `Route` will hold all the routes that will be used to make a specific update to your `RouterState` `view` property and custom properties.

You might end up with something like this:

```swift
public enum Route {
    case splash
    case loading
    case home
    case sheet(Bool)
}
```

Again, your `Route` and `Views` don't have to be the same. The `Views` is used to decide which `View` to display. The `Route` is used to update your current view to a new one. 

## Router

The `Router` represents the overall process of how your `Routing` logic is executed. It is a fully built `class` that you use with the flexibility to incorporate your own routing logic. Your `Routing` service handles how you want to route and the `Router` takes care of the rest!

Your `Router` will be a `singleton` that stores one unique instance of your `RouterState`. No need for multiple routers, that is why we use the `singleton` pattern: To esnure there is only one. 

Once you've created your service that confomrs to `Routing`, here is how you initialize your router:

```swift
@main
struct DemoApp: App {
    
    // MARK: - Properties
        
    private let router: Router<RoutingService> = .init(.init(),
                                                       routing: RoutingService())
    
    // MARK: - Scene
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

We also need to inject our `Router` into the `LegoKit` framework. By doing so, it safely ensures the use of your `singleton` `Router` instance throughout the app. 

```swift
struct DemoApp: App {
    
    ...
    
    // MARK: - Init
    
    init() {
        LegoKit.router(router)
    }
    
    ...
}
```

BOOM 💥 Now we can use our router in the app!

## Rendering Simple Router Updates

The first step here is to define and create all the `View` structures of our app. 

Then, on a root, content or parent view we want to have something like this:

```swift
struct ContentView: View {
    
    // MARK: - Properties
    
    @ObservedRoutes private var router: Router<RoutingService>
        
    // MARK: - Init
    
    init() {}
    
    // MARK: - View
    
    var body: some View {
        Group {
            switch router.state.view {
            case .splash:
                SplashView()
                
            case .loading:
                LoadingView()
                
            case .home:
                HomeView()
            }
        }
    }
}
```

We can access our `singleton` `Router` using a dynamic propery wrapper called `ObservedRoutes`. This will ensure a `View` redraw happens when a change is made the the `RouterState`. 

So now, each `View` will render depending on what the value of our `RouterState` `view` property is. 

## Simple Routing in a View

Let's take it a step further, by routing to a new `View` like this:

```swift
struct ContentView: View {

    ...
    
    // MARK: - View
    
    var body: some View {
        Group {
            switch router.state.view {
            case .splash:
                SplashView()
                .onAppear {
                    router.route(to: .home)
                }
                
            case .loading:
                LoadingView()
                
            case .home:
                HomeView()
            }
        }
    }
}
```

In the example above, I'm using a simple `onAppear` closure to route to a new `View`. However, you could do this with button actions or any other callbacks/closure.

Pretty cool 😎 

## Bindable Router

We probably all know how much of a pain it is to deal with `Binding` values when we have a `private(set)` property somehwere in a `class`.

Fear not! You can safely bind a `RouterState` property with the power of `KeyPath` and the custom built in `Binding` functions in the `Router` class. 

Here is an example of how to get a `sheet` to toggle in your view:

```swift
struct HomeView: View {
    
    // MARK: - Properties
    
    @ObservedRoutes private var router: Router<RoutingService>
    
    // MARK: - Init
    
    init() {}
    
    // MARK: - View
    
    var body: some View {
        VStack {
            Text("Home")
            Button("Display Settings Sheet") {
                router.route(to: .sheet(true))
            }
        }
        .sheet(isPresented: router.routable(\.displaySheet,
                                             route: .sheet(false))) {
            SheetsView()
        }
    }
}
```

We can leverage the awesome `routable` function in `Router` to toggle a `Sheet`! 

The main idea here, is that we are accessing a specific property in `RouterState` that derives a two-way binding by updating the `RouterState` based on a `Route`. 

## Routing Outside a View

So clearly, there will be situations where you might need to route based on events that happen outside of a `View`. For example, if you are using the `LegoKit` architecture, then you might want to route in one of your `Blueprint` changes. Maybe, you want to route once an async task is completed. 

Well, here is how you do that:

```swift
public struct AuthBlueprint: Blueprint {
    
    // MARK: - Router
    
    @Routes private var router: Router<RoutingService>
    
    // MARK: - Design
    
    public struct Design: Equatable {
        public var user: User?
    }
    
    // MARK: - Change
    
    public enum Change: Equatable {
        case signIn(username: String, password: String)
        case signInComplete(Result<User, Error>)
    }
    
    // MARK: - Changes
    
    public func change(_ design: inout Design, on change: Change) {
        switch change {
        case .signIn:
            break
        
        case .signInComplete(let response):
            switch response {
              case .success(let user):
                design.user = user
                router.route(to: .home)
               
              case .failure(let error):
                design.user = nil
                router.route(to: .help)
            }
    }
}
``` 
The first thing you'll need is to access the `Router` instance via e property wrapper called `@Routes`. 
The main reason we use `@Routes` instead of `@ObservedRoutes` is becuase `@ObservedRoutes` is a `DynamicProperty` that requires a `View` due to the `View` redraw it triggers when the `RouterState` updates.

The idea is essentially the same. It is a way we can safely access our `Router` instance outside a `View` and still successfully perfrom a route change on our `RouterState`.


## Router Warning

The current routing capabilities are still not 100% complete. Here are some of the things that are still missing or not working at 100%. 

1. Deep Link Routing
2. Push Notification Routing
3. NavigationView & NavigationLink Support
4. Asynchronous capabilities withtin the `Router` class. 

# Conclusion 🎉

Although `LegoKit` is still very much under early development, I would love anyone to try it out and submit some feedback! And if you are feeling dangerous, submit some PRs with improvements 😏

