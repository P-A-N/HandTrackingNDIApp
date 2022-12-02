#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>

@class Landmark;
@class HandTracker;

@protocol TrackerDelegate <NSObject>
- (void)handTracker: (HandTracker*)handTracker didOutputLandmarks: (NSArray<NSArray<Landmark *> *> *)landmarks;
- (void)handTracker: (HandTracker*)handTracker didOutputPixelBuffer: (CVPixelBufferRef)pixelBuffer;
@end

@interface HandTracker : NSObject
- (instancetype)init;
- (void)startGraph;
- (void)processVideoFrame:(CVPixelBufferRef)imageBuffer;
// Graph name.
@property(nonatomic) NSString* graphName;

// Graph input stream.
@property(nonatomic) const char* graphInputStream;

// Graph output stream.
@property(nonatomic) const char* graphOutputStream;

@property (weak, nonatomic) id <TrackerDelegate> delegate;
@end

@interface Landmark: NSObject
@property(nonatomic, readonly) float x;
@property(nonatomic, readonly) float y;
@property(nonatomic, readonly) float z;
@end
