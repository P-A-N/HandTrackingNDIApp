#import "NDIWrapper.h"
#import "Processing.NDI.Lib.h"

@implementation NDIWrapper {
    NDIlib_send_instance_t my_ndi_send;
}

+ (void)initialize {
    NDIlib_initialize();
}

- (void)start:(NSString *)name {
    if (my_ndi_send) {
        my_ndi_send = nil;
    }
    NDIlib_send_create_t options;
    NSLog(name);
    options.p_ndi_name = [name cStringUsingEncoding: NSUTF8StringEncoding];
    options.p_groups = NULL;
    options.clock_video = false;
    options.clock_audio = false;
    my_ndi_send = NDIlib_send_create(NULL);
    if (!my_ndi_send) {
        NSLog(@"ERROR: Failed to create sender");
    } else {
        NSLog(@"Successfully created sender");
    }
}

- (void)stop {
    if (my_ndi_send) {
        NDIlib_send_destroy(my_ndi_send);
        my_ndi_send = nil;
    }
}

- (void)send:(CMSampleBufferRef)sampleBuffer
    metadata:(const char*) metadata {
    if (!my_ndi_send) {
        NSLog(@"ERROR: NDI instance is nil");
        return;
    }

    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    int width = (int)CVPixelBufferGetWidth(imageBuffer);
    int height = (int)CVPixelBufferGetHeight(imageBuffer);
    NDIlib_video_frame_v2_t video_frame;
    video_frame.frame_rate_N = 30000;
    video_frame.frame_rate_D = 1001;
    
    video_frame.xres = width;
    video_frame.yres = height;
    video_frame.line_stride_in_bytes = video_frame.xres * 4;
    video_frame.FourCC = NDIlib_FourCC_type_BGRA;
    video_frame.frame_format_type = NDIlib_frame_format_type_progressive;
    video_frame.picture_aspect_ratio = (float)width/(float)height;
//    video_frame.line_stride_in_bytes = 2560;
    video_frame.p_metadata = metadata;

    CVPixelBufferLockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);
    video_frame.p_data = CVPixelBufferGetBaseAddress(imageBuffer);
    CVPixelBufferUnlockBaseAddress(imageBuffer, kCVPixelBufferLock_ReadOnly);

    NDIlib_send_send_video_async_v2(my_ndi_send, &video_frame);
}

@end
