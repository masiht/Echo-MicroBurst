//
//  ViewController.m
//  MB
//
//  Created by Masih Tabrizi on 3/17/15.
//  Copyright (c) 2015 Masih. All rights reserved.
//

#import "ViewController.h"

#define serverIP @"108.229.9.53"
#define serverCtrlProt 62122
#define serverUploadPort 62123


@interface ViewController () {
    
    GCDAsyncSocket *socketCtrl;
    GCDAsyncUdpSocket *socketUplaod;

    int numberOfTestPackets;
    int sizeOfTestPackets;
    BOOL isWatingForResults;
    
    testType currentTest;
    NSArray *dataToSend;
    NSMutableArray *recvTimeStamp;
    NSMutableArray *recvData;
    NSDate *startDate;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    isWatingForResults = NO;
    currentTest = testTypeUpload;
    
    if (currentTest == testTypeUpload) {
//        [self setupUploadTest];
        [self setupControlConnection];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupControlConnection {
    socketCtrl = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error;
    [socketCtrl connectToHost:serverIP onPort:serverCtrlProt error:&error];
    
}

-(void)setupUploadTest {
    socketUplaod = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
}

-(NSData *)makeControlPacketWithNumberOfPackets:(int)numberOfPackets packetSize:(int)size {
    
    numberOfTestPackets = numberOfPackets;
    sizeOfTestPackets = size;
    
    switch (currentTest) {
            
        case testTypeUpload:
            return [[NSString stringWithFormat:@"0:1:%i:%i:%@", numberOfPackets, size, [socketCtrl localHost]] dataUsingEncoding:NSUTF8StringEncoding];;
            break;
            
        case testTypeDownload:
            return [[NSString stringWithFormat:@"0:0:%i:%i:%@", numberOfPackets, size, [socketCtrl localHost]] dataUsingEncoding:NSUTF8StringEncoding];
            break;
            
        default:
            break;
    }
    
}

#pragma mark - TCP socket

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    
    NSLog(@"TCP socket connected to - %@:%i", host, port);
    if (currentTest == testTypeUpload) {
        // send test request
        NSData *controlPacket = [self makeControlPacketWithNumberOfPackets:10 packetSize:996];
        [socketCtrl writeData:controlPacket withTimeout:-1 tag:0];
        
        //wait for response
        [socketCtrl readDataWithTimeout:-1 tag:0];
    }
    
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"TCP data read = %@", response);
}

-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"TCP data written");
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"TCP socket disconnected");
}

@end
