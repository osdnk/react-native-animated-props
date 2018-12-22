#import "RNAnimatedProps.h"
#import <React/RCTModuleData.h>



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


@implementation RNAnimatedProps {
  RCTUIManager *uiManager;
  NSSet<PropsConncetor *> *connectors;
  NSMutableDictionary<NSNumber *, AnimatedNodeValueListener *> *listerts;
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"onAnimatedValueUpdate"];
}

- (void)animatedNode:(RCTValueAnimatedNode *)node didUpdateValue:(CGFloat)value
{

}

-(void) setBridge:(RCTBridge *)bridge {
  [super setBridge:bridge];
  RCTNativeAnimatedNodesManager *x = [[[[self.bridge valueForKey:@"moduleDataByName"] valueForKey:@"NativeAnimatedModule"] valueForKey: @"instance"] valueForKey:@"nodesManager"];
  x;
}


RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(connect:(nonnull NSNumber *)nodeID
                  withAnimatedNode:(nonnull NSNumber *)tag
                  withPropName:(nonnull NSString *) prop)
{
  RCTNativeAnimatedNodesManager *x = [[[[self.bridge valueForKey:@"moduleDataByName"] valueForKey:@"NativeAnimatedModule"] valueForKey: @"instance"] valueForKey:@"nodesManager"];
}

RCT_EXPORT_METHOD(disconnect:(nonnull NSNumber *)nodeID
                  withAnimatedNode:(nonnull NSNumber *)tag
                  withPropName:(nonnull NSString *) prop)
{
  
}

@end
