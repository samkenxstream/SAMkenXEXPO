import UIKit
import ObjectiveC

/**
 A protocol that helps in identifying whether the instance of `ViewModuleWrapper` is of a dynamically created class.
 */
@objc
protocol DynamicModuleWrapperProtocol {
  @objc
  optional func wrappedModule() -> ViewModuleWrapper
}

/**
 Each module that has a view manager definition needs to be wrapped by `ABI46_0_0RCTViewManager`.
 Unfortunately, we can't use just one class because ABI46_0_0React Native checks for duplicated classes.
 We're generating its subclasses in runtime as a workaround.
 */
@objc
public final class ViewModuleWrapper: ABI46_0_0RCTViewManager, DynamicModuleWrapperProtocol {
  /**
   A reference to the module holder that stores the module definition.
   Enforced unwrapping is required since it can be set right after the object is initialized.
   */
  var wrappedModuleHolder: ModuleHolder!

  /**
   The designated initializer. At first, we use this base class to hide `ModuleHolder` from Objective-C runtime.
   */
  public init(_ wrappedModuleHolder: ModuleHolder) {
    self.wrappedModuleHolder = wrappedModuleHolder
  }

  /**
   The designated initializer that is used by ABI46_0_0React Native to create module instances.
   Must be called on a dynamic class to get access to underlying wrapped module. Throws fatal exception otherwise.
   */
  @objc
  public override init() {
    super.init()
    guard let module = (self as DynamicModuleWrapperProtocol).wrappedModule?() else {
      fatalError("Something unexpected has happened. Only dynamically created `ViewModuleWrapper` can be initialized without params.")
    }
    self.wrappedModuleHolder = module.wrappedModuleHolder
  }

  /**
   Dummy initializer, for use only in `ABI46_0_0EXModuleRegistryAdapter.extraModulesForModuleRegistry:`.
   */
  @objc
  public init(dummy: Any?) {
    super.init()
  }

  /**
   Returns the original name of the wrapped module.
   */
  @objc
  public func name() -> String {
    return wrappedModuleHolder.name
  }

  /**
   Static function that returns the class name, but keep in mind that dynamic wrappers
   have custom class name (see `objc_allocateClassPair` invocation in `createViewModuleWrapperClass`).
   */
  @objc
  public override class func moduleName() -> String {
    return NSStringFromClass(Self.self)
  }

  /**
   The view manager wrapper doesn't require main queue setup — it doesn't call any UI-related stuff on `init`.
   Also, lazy-loaded modules must return false here.
   */
  @objc
  public override class func requiresMainQueueSetup() -> Bool {
    return false
  }

  /**
   Creates a view from the wrapped module.
   */
  @objc
  public override func view() -> UIView! {
    guard let view = wrappedModuleHolder.definition.viewManager?.createView() else {
      fatalError("Module `\(wrappedModuleHolder.name)` doesn't define the view manager nor view factory.")
    }
    return view
  }

  /**
   The config for `proxiedProperties` prop. In Objective-C style, this function is generated by `ABI46_0_0RCT_CUSTOM_VIEW_PROPERTY` macro.
   */
  @objc
  public class func propConfig_proxiedProperties() -> [String] {
    return ["NSDictionary", "__custom__"]
  }

  /**
   The setter for `proxiedProperties` prop. In Objective-C style, this function is generated by `ABI46_0_0RCT_CUSTOM_VIEW_PROPERTY` macro.
   */
  @objc
  public func set_proxiedProperties(_ json: Any, forView view: UIView, withDefaultView defaultView: UIView) {
    guard let json = json as? [String: Any],
          let props = wrappedModuleHolder.definition.viewManager?.propsDict() else {
      return
    }
    for (key, value) in json {
      if let prop = props[key] {
        let value = Conversions.fromNSObject(value)

        // TODO: @tsapeta: Figure out better way to rethrow errors from here.
        // Adding `throws` keyword to the function results in different
        // method signature in Objective-C. Maybe just call `ABI46_0_0RCTLogError`?
        try? prop.set(value: value, onView: view)
      }
    }
  }

  /**
   Creates a subclass of `ViewModuleWrapper` in runtime. The new class overrides `moduleName` stub.
   */
  @objc
  public static func createViewModuleWrapperClass(module: ViewModuleWrapper) -> ViewModuleWrapper.Type? {
    // We're namespacing the view name so we know it uses our architecture.
    let prefixedViewName = "ViewManagerAdapter_\(module.name())"

    return prefixedViewName.withCString { viewNamePtr in
      // Create a new class that inherits from `ViewModuleWrapper`. The class name passed here, doesn't work for Swift classes,
      // so we also have to override `moduleName` class method.
      let wrapperClass: AnyClass? = objc_allocateClassPair(ViewModuleWrapper.self, viewNamePtr, 0)

      // Dynamically add instance method returning wrapped module to the dynamic wrapper class.
      // ABI46_0_0React Native initializes modules with `init` without params,
      // so there is no other way to pass it to the instances.
      let wrappedModuleBlock: @convention(block) () -> ViewModuleWrapper = { module }
      let wrappedModuleImp: IMP = imp_implementationWithBlock(wrappedModuleBlock)
      class_addMethod(wrapperClass, Selector("wrappedModule"), wrappedModuleImp, "@@:")

      return wrapperClass as? ViewModuleWrapper.Type
    }
  }
}

// The direct event implementation can be cached and lazy-loaded (global and static variables are lazy by default in Swift).
let directEventBlockImplementation = imp_implementationWithBlock({ ["ABI46_0_0RCTDirectEventBlock"] } as @convention(block) () -> [String])
