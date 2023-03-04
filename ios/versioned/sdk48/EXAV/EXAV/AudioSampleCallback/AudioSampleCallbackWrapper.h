// Copyright 2017-present 650 Industries. All rights reserved.

#ifdef __cplusplus

#import <AVFoundation/AVFoundation.h>

#import <ABI48_0_0jsi/ABI48_0_0jsi.h>

// TODO: Replace this with <ReactCommon/TurboModuleUtils.h> after we upgrade to RN 0.66
#import <ABI48_0_0EXAV/CallbackWrapper.h>

namespace jsi = ABI48_0_0facebook::jsi;
using CallInvoker = ABI48_0_0facebook::ABI48_0_0React::CallInvoker;

// TODO: Replace this with just ABI48_0_0facebook::react namespace after we upgrade to RN 0.66
using JsiCallbackWrapper = ABI48_0_0expo::CallbackWrapper;
using LongLivedObjectCollection = ABI48_0_0expo::LongLivedObjectCollection;

namespace ABI48_0_0expo {
namespace av {

// A class managing lifecycle of audio sample buffer callbacks
class AudioSampleCallbackWrapper
{
  std::weak_ptr<JsiCallbackWrapper> weakWrapper;
public:
  AudioSampleCallbackWrapper(jsi::Function &&callback,
                             jsi::Runtime &runtime,
                             std::shared_ptr<CallInvoker> jsInvoker);
  
  ~AudioSampleCallbackWrapper();
  
  void call(AudioBuffer* buffer, double timestamp);
  
  // static members
public:
  // called when JS VM is destroyed to remove all JSI callback objects
  static void removeAllCallbacks() {
    callbackCollection->clear();
  }
  
private:
  static std::shared_ptr<LongLivedObjectCollection> callbackCollection;
};

} // namespace av
} // namespace ABI48_0_0expo

#endif // __cplusplus
