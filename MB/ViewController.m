//
//  ViewController.m
//  MB
//
//  Created by Masih Tabrizi on 3/17/15.
//  Copyright (c) 2015 Masih. All rights reserved.
//

#import "ViewController.h"

#define serverIP @"108.229.9.53"
#define serverCtrlPort 62122
#define serverUploadPort 62123


@interface ViewController () {
    
    GCDAsyncSocket *socketCtrl;
    GCDAsyncUdpSocket *socketUpload;

    int numberOfTestPackets;
    int sizeOfTestPackets;
    BOOL isWaitingForResults;
    
    testType currentTest;
    NSArray *dataToSend;
    NSMutableArray *recvTimeStamps;
    NSMutableArray *recvData;
    NSDate *startTime;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    isWaitingForResults = NO;
    currentTest = testTypeUpload;
    
    if (currentTest == testTypeUpload) {
        [self setupUploadTest];
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
    [socketCtrl connectToHost:serverIP onPort:serverCtrlPort error:&error];
    
}

-(void)setupUploadTest {
    socketUpload = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
}

-(NSData *)makeControlPacketWithNumberOfPackets:(int)numberOfPackets packetSize:(int)size {
    
    numberOfTestPackets = numberOfPackets;
    sizeOfTestPackets = size;
    
    if (currentTest == testTypeUpload) {
        return [[NSString stringWithFormat:@"0:1:%i:%i:%@", numberOfPackets, size, [socketCtrl localHost]] dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    else if (currentTest == testTypeDownload) {
        return [[NSString stringWithFormat:@"0:0:%i:%i:%@", numberOfPackets, size, [socketCtrl localHost]] dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    return nil;
    
}

-(NSArray *)makeUploadTestPacket{
    
    NSMutableArray *dataPacket = [[NSMutableArray alloc] init];
    
    for (int i = 1; i <= numberOfTestPackets; i++) {

        NSMutableString *dataStr = [NSMutableString stringWithFormat:@"3:%d:%@:%d:", sizeOfTestPackets, [socketCtrl localHost], i];
        for (int j = (int)dataStr.length; j < sizeOfTestPackets; j++) {
            [dataStr appendString:@"1"];
        }
        NSLog(@"new string is:%@", dataStr);
        [dataPacket addObject:[dataStr dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    return dataPacket;
}

#pragma mark - TCP socket

-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"%@",[socketCtrl localHost]);
    NSLog(@"TCP socket connected to - %@:%i", host, port);
    if (currentTest == testTypeUpload) {
        // send control packet
        NSData *controlPacket = [self makeControlPacketWithNumberOfPackets:10 packetSize:996];
        dataToSend = [self makeUploadTestPacket];
        [socketCtrl writeData:controlPacket withTimeout:-1 tag:0];
        
        //wait for response
        [socketCtrl readDataWithTimeout:-1 tag:0];
    }
    
}

-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"TCP data read = %@", response);
    
    if (!isWaitingForResults) {
        for (int i = 0; i < numberOfTestPackets; i++) {
            [socketUpload sendData:[dataToSend objectAtIndex:i] toHost:serverIP port:serverUploadPort withTimeout:-1 tag:0];
        }
        
        [socketCtrl readDataWithTimeout:-1 tag:0];
        
        isWaitingForResults = YES;
    } else {
        isWaitingForResults = NO;
    }
}

-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"TCP data written");
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"TCP socket disconnected");
}



#pragma mark - UDP sockets

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    
    double interval = [startTime timeIntervalSinceNow];
    NSString *readData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"UDP data read = %@", readData);
    NSLog(@"UDP recv time stamp = %f", interval);
    
    [recvData addObject:readData];
    [recvTimeStamps addObject:[NSNumber numberWithDouble:interval]];
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    
    NSLog(@"Data sent to UPD socket");
    
}

-(void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
    NSLog(@"Connected to %@", address);
}


@end
