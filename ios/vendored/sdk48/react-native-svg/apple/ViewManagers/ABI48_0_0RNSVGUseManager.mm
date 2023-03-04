/**
 * Copyright (c) 2015-present, Horcrux.
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ABI48_0_0RNSVGUseManager.h"
#import "ABI48_0_0RNSVGUse.h"

@implementation ABI48_0_0RNSVGUseManager

ABI48_0_0RCT_EXPORT_MODULE()

- (ABI48_0_0RNSVGNode *)node
{
  return [ABI48_0_0RNSVGUse new];
}

ABI48_0_0RCT_EXPORT_VIEW_PROPERTY(href, NSString)
ABI48_0_0RCT_CUSTOM_VIEW_PROPERTY(x, id, ABI48_0_0RNSVGUse)
{
  view.x = [ABI48_0_0RCTConvert ABI48_0_0RNSVGLength:json];
}
ABI48_0_0RCT_CUSTOM_VIEW_PROPERTY(y, id, ABI48_0_0RNSVGUse)
{
  view.y = [ABI48_0_0RCTConvert ABI48_0_0RNSVGLength:json];
}
ABI48_0_0RCT_CUSTOM_VIEW_PROPERTY(height, id, ABI48_0_0RNSVGUse)
{
  view.useheight = [ABI48_0_0RCTConvert ABI48_0_0RNSVGLength:json];
}
ABI48_0_0RCT_CUSTOM_VIEW_PROPERTY(width, id, ABI48_0_0RNSVGUse)
{
  view.usewidth = [ABI48_0_0RCTConvert ABI48_0_0RNSVGLength:json];
}

@end
