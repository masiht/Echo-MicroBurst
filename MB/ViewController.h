//
//  ViewController.h
//  MB
//
//  Created by Masih Tabrizi on 3/17/15.
//  Copyright (c) 2015 Masih. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"

typedef NS_ENUM(NSUInteger, testType) {
  testTypeUpload,
  testTypeDownload
};

@interface ViewController : UIViewController <GCDAsyncSocketDelegate, GCDAsyncUdpSocketDelegate>

@end

