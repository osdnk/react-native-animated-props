#import "RNAnimatedProps.h"
#import <React/RCTModuleData.h>


@interface NativeValueObserver : NSObject<RCTValueAnimatedNodeObserver>

@end

@interface RNAnimatedProps()
- (void)animatedNode:(RCTValueAnimatedNode *)node
      didUpdateValue:(CGFloat)value;
@end


@implementation NativeValueObserver {
  RNAnimatedProps *_nativeModule;
}


- (instancetype) initWithModule:(RNAnimatedProps *)nativeModule
{
  if (self = [super init]) {
    _nativeModule = nativeModule;
  }
  return self;
}

- (void)animatedNode:(RCTValueAnimatedNode *)node
      didUpdateValue:(CGFloat)value
{
  [_nativeModule animatedNode:node didUpdateValue:value];
}

@end


@interface RCTUIManager ()

- (void)updateView:(nonnull NSNumber *)reactTag
          viewName:(NSString *)viewName
             props:(NSDictionary *)props;

- (void)setNeedsLayout;

@end



@interface PropsConncetor : NSObject

- (instancetype)initWithViewTag:(NSNumber *) viewTag
                     withNodeID:(NSNumber *) nodeID
                       withProp:(NSString *) prop;

@property (nonatomic) NSNumber *viewTag;
@property (nonatomic) NSNumber *nodeID;
@property (nonatomic) NSString *prop;

@end

@implementation PropsConncetor

- (instancetype) initWithViewTag:(NSNumber *)viewTag
                      withNodeID:(NSNumber *)nodeID
                        withProp:(NSString *)prop
{
  if ((self = [super init])) {
    _viewTag = viewTag;
    _nodeID = nodeID;
    _prop = prop;
  }
  return self;
}

@end

@interface AnimatedNodeValueListener

@end

typedef void (^AnimatedOperation)(RCTNativeAnimatedNodesManager *nodesManager);

@implementation RNAnimatedProps {
  RCTUIManager *_uiManager;
  NSMutableSet<PropsConncetor *> *_connectors;
  NSMutableDictionary<NSNumber *, NativeValueObserver *> *_listeners;
  RCTNativeAnimatedNodesManager *_nodesManager;
  NSMutableArray<AnimatedOperation> *_operations;
}

- (NSArray<NSString *> *)supportedEvents
{
  // Need to implement it in order to fill in bridge protocol.
  return nil;
}

- (void)animatedNode:(RCTValueAnimatedNode *)node
      didUpdateValue:(CGFloat)value
{
  RCTExecuteOnUIManagerQueue(^{
    for (PropsConncetor *p in _connectors) {
      if (p.nodeID == node.nodeTag) {
        NSMutableDictionary *nativeProps = [NSMutableDictionary new];
        NSString *viewName = [_uiManager viewNameForReactTag:p.viewTag];
        nativeProps[p.prop] = [[NSNumber alloc] initWithFloat:value];
        [_uiManager updateView:p.viewTag viewName:viewName props:nativeProps];
      }
    }
    [_uiManager setNeedsLayout];
  });
}

- (void)setBridge:(RCTBridge *)bridge {
  [super setBridge:bridge];
  NSObject *m = [[[self.bridge valueForKey:@"moduleDataByName"] valueForKey:@"NativeAnimatedModule"] valueForKey: @"instance"];
  _nodesManager = (RCTNativeAnimatedNodesManager *)[m valueForKey:@"nodesManager"];
  _operations = (NSMutableArray<AnimatedOperation> *)[m valueForKey:@"operations"];
  _connectors = [[NSMutableSet alloc] init];
  _uiManager = self.bridge.uiManager;
}


- (void)addListenerIfNeeded:(NSNumber *)nodeID
{
  BOOL foundRegisteredListener = NO;
  for (PropsConncetor * c in _connectors)
  {
    if (c.nodeID == nodeID)
    {
      foundRegisteredListener = YES;
      break;
    }
  }
  if (!foundRegisteredListener) {
    NativeValueObserver * n = [[NativeValueObserver alloc] initWithModule:self];
    [_operations addObject:^(RCTNativeAnimatedNodesManager *nodesManager) {
      [nodesManager startListeningToAnimatedNodeValue:nodeID valueObserver:n];
    }];
  }
  
}

- (void)removeListenerIfPossbile:(NSNumber *)nodeID
{
  BOOL foundRegisteredListener = NO;
  for (PropsConncetor * c in _connectors)
  {
    if (c.nodeID == nodeID)
    {
      foundRegisteredListener = YES;
      break;
    }
  }
  if (!foundRegisteredListener) {
    [_listeners removeObjectForKey:nodeID];
    [_operations addObject:^(RCTNativeAnimatedNodesManager *nodesManager) {
      [nodesManager stopListeningToAnimatedNodeValue:nodeID];
    }];
  }
  
}

- (dispatch_queue_t)methodQueue
{
  return RCTGetUIManagerQueue();
}


RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(connect:(nonnull NSNumber *)viewTag
                  withAnimatedNode:(nonnull NSNumber *)nodeID
                  withPropName:(nonnull NSString *) prop)
{
  [self addListenerIfNeeded:nodeID];
  [_connectors addObject:[[PropsConncetor alloc] initWithViewTag:viewTag withNodeID:nodeID withProp:prop]];
}

RCT_EXPORT_METHOD(disconnect:(nonnull NSNumber *)viewTag
                  withAnimatedNode:(nonnull NSNumber *)nodeID
                  withPropName:(nonnull NSString *) prop)
{
  for (PropsConncetor * c in _connectors)
  {
    if (c.nodeID == nodeID && c.viewTag == viewTag && c.prop == prop)
    {
      [_connectors removeObject:c];
    }
  }
  [self removeListenerIfPossbile:nodeID];
}

@end
