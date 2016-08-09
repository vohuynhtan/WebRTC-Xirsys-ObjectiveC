//
//  WebRTCManager.h
//  WebRTC-Xirsys-ObjectiveC
//
//  Created by TanVo on 8/3/16.
//  Copyright © 2016 TanVo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RTCICECandidate.h"
#import "RTCICEServer.h"
#import "RTCPeerConnection.h"
#import "RTCPeerConnectionDelegate.h"
#import "RTCPeerConnectionFactory.h"
#import "RTCSessionDescription.h"
#import "RTCSessionDescriptionDelegate.h"
#import "RTCVideoRenderer.h"
#import "RTCVideoCapturer.h"
#import "RTCMediaStream.h"
#import "RTCMediaConstraints.h"
#import "RTCPair.h"
#import "RTCVideoTrack.h"
#import "RTCEAGLVideoView.h"

#import "XirSys/XSClient.h"
#import "XirSys/Model/XSServer.h"

@interface WebRTCManager : NSObject <RTCPeerConnectionDelegate, RTCSessionDescriptionDelegate>

@property (nonatomic, strong) RTCPeerConnection *peerConnection;
@property (nonatomic, strong) RTCPeerConnectionFactory *peerConnectionFactory;


+ (instancetype)sharedInstance;

- (void)configureConnection;
- (void)createPeerConnectionWithICEServers;

@end
