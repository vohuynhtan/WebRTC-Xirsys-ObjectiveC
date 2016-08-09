//
//  WebRTCManager.m
//  WebRTC-Xirsys-ObjectiveC
//
//  Created by TanVo on 8/3/16.
//  Copyright © 2016 TanVo. All rights reserved.
//

#import "WebRTCManager.h"

@implementation WebRTCManager 

+(instancetype)sharedInstance
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    [self initialize];
    
    return self;
}

- (void)initialize{
    self.peerConnectionFactory = [[RTCPeerConnectionFactory alloc]init];
}

- (void)configureConnection{
    [RTCPeerConnectionFactory initializeSSL];
}

- (NSArray *)getIceServers{
    return @[[[RTCICEServer alloc]initWithURI:[NSURL URLWithString:@"stun:turn02.uswest.xirsys.com"] username:@"" password:@""],
             [[RTCICEServer alloc]initWithURI:[NSURL URLWithString:@"turn:turn02.uswest.xirsys.com:80?transport=udp"] username:@"51e0464a-5938-11e6-9b7d-3dc9359a69f6" password:@"51e046ea-5938-11e6-aa56-29f0e2a7a14f"],
             [[RTCICEServer alloc]initWithURI:[NSURL URLWithString:@"turn:turn02.uswest.xirsys.com:80?transport=tcp"] username:@"51e0464a-5938-11e6-9b7d-3dc9359a69f6" password:@"51e046ea-5938-11e6-aa56-29f0e2a7a14f"],
             [[RTCICEServer alloc]initWithURI:[NSURL URLWithString:@"turn:turn02.uswest.xirsys.com:3478?transport=udp"] username:@"51e0464a-5938-11e6-9b7d-3dc9359a69f6" password:@"51e046ea-5938-11e6-aa56-29f0e2a7a14f"],
             [[RTCICEServer alloc]initWithURI:[NSURL URLWithString:@"turn:turn02.uswest.xirsys.com:3478?transport=tcp"] username:@"51e0464a-5938-11e6-9b7d-3dc9359a69f6" password:@"51e046ea-5938-11e6-aa56-29f0e2a7a14f"]];
}

- (void)createPeerConnectionWithICEServers{
    self.peerConnection = [self.peerConnectionFactory peerConnectionWithICEServers:[self getIceServers] constraints:[self streamSDPConstraints] delegate:self];
    
    RTCMediaStream *lms = [self.peerConnectionFactory mediaStreamWithLabel:@"ARDAMS"];
    
    
    NSLog(@"Adding Audio and Video devices ...");
    RTCAudioTrack* audioTrack = [self.peerConnectionFactory audioTrackWithID:@"ARDAMSa0"];
    [lms addAudioTrack:audioTrack];
    //** add stream
    [self.peerConnection addStream:lms];
    
    // Create Offer
    [self createOfferConnectToPeer:@"1007641467278980447"];
}

#pragma mark - Constraint
- (RTCMediaConstraints *)streamSDPConstraints
{
    NSArray* mandatory = @[[[RTCPair alloc] initWithKey:@"OfferToReceiveAudio" value:@"true"], [[RTCPair alloc] initWithKey:@"OfferToReceiveVideo" value:@"true"]];
    
    NSArray* optional = @[[[RTCPair alloc] initWithKey:@"internalSctpDataChannels" value:@"true"],[[RTCPair alloc] initWithKey:@"DtlsSrtpKeyAgreement" value:@"true"]];
    
    return [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatory optionalConstraints:optional];
}

- (RTCMediaConstraints *)streamOfferConstraints{
    NSArray* mandatory = @[[[RTCPair alloc] initWithKey:@"OfferToReceiveAudio" value:@"true"], [[RTCPair alloc] initWithKey:@"OfferToReceiveVideo" value:@"true"]];
    
    return [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatory optionalConstraints:nil];
}

#pragma mark - Create New Offer
- (void)createOfferConnectToPeer:(NSString *)peerId{
    RTCMediaConstraints *constraints = [self streamOfferConstraints];
    [self.peerConnection createOfferWithDelegate:self constraints:constraints];
}

#pragma mark -
#pragma mark - RTCPeerConnectionDelegate
- (void)peerConnection:(RTCPeerConnection *)peerConnection signalingStateChanged:(RTCSignalingState)stateChanged{
    NSLog(@"---SignalingStateChanged---");
}
- (void)peerConnection:(RTCPeerConnection *)peerConnection addedStream:(RTCMediaStream *)stream{
}
- (void)peerConnection:(RTCPeerConnection *)peerConnection removedStream:(RTCMediaStream *)stream{
}
- (void)peerConnectionOnRenegotiationNeeded:(RTCPeerConnection *)peerConnection{
    NSLog(@"---OnRenegotiationNeeded---");
}
- (void)peerConnection:(RTCPeerConnection *)peerConnection iceConnectionChanged:(RTCICEConnectionState)newState{
    
}
- (void)peerConnection:(RTCPeerConnection *)peerConnection iceGatheringChanged:(RTCICEGatheringState)newState{
    NSLog(@"---IceGatheringChanged---");
}
- (void)peerConnection:(RTCPeerConnection *)peerConnection gotICECandidate:(RTCICECandidate *)candidate{
    NSLog(@"---GotICECandidate---");
}
- (void)peerConnection:(RTCPeerConnection*)peerConnection didOpenDataChannel:(RTCDataChannel*)dataChannel{
    
}

#pragma mark - RTCSessionDescriptionDelegate
- (void)peerConnection:(RTCPeerConnection *)peerConnection didCreateSessionDescription:(RTCSessionDescription *)sdp error:(NSError *)error{
    
    if (error) {
        NSLog(@"SDP didCreateSessionDescription onFailure. %@", error.description);
        return;
    }
    
    RTCSessionDescription *offerSDP = [[RTCSessionDescription alloc]initWithType:sdp.type sdp:[WebRTCManager preferISAC:sdp.description]];
    [self.peerConnection setLocalDescriptionWithDelegate:self sessionDescription:offerSDP];
    
    //Send SDP to other client
    
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didSetSessionDescriptionWithError:(NSError *)error{
    if (peerConnection.signalingState == RTCSignalingHaveLocalOffer) {
        
    }
}

#pragma mark -
#pragma mark - Recieve Message XMPP
//- (void)processSignalingMessage:(NSString *)message {        //Recieve message from other client
//    
//    if (!hasCreatedPeerConnection) {
//        EASYLogError(@"has NOT created peerConnection...");
//        return;
//    }
//    
//    NSString *jsonStr = message;
//    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
//    NSError *error;
//    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
//    NSAssert(!error,@"%@",[NSString stringWithFormat:@"Error: %@", error.description]);
//    NSString *type = [jsonDict objectForKey:@"type"];
//    if ([type compare:@"offer"] == NSOrderedSame) {
//        NSString *sdpString = [jsonDict objectForKey:@"sdp"];
//        RTCSessionDescription *sdp = [[RTCSessionDescription alloc]
//                                      initWithType:type sdp:[RTCWorker preferISAC:sdpString]];
//        [self.peerConnection setRemoteDescriptionWithDelegate:self sessionDescription:sdp];
//        
//        //create answer
//        [self.peerConnection createAnswerWithDelegate:self constraints:self.sdpConstraints];
//        EASYLogInfo(@"crate answer ...");
//        
//    }else if ([type compare:@"answer"] == NSOrderedSame) {
//        NSString *sdpString = [jsonDict objectForKey:@"sdp"];
//        RTCSessionDescription *sdp = [[RTCSessionDescription alloc]
//                                      initWithType:type sdp:[RTCWorker preferISAC:sdpString]];
//        [self.peerConnection setRemoteDescriptionWithDelegate:self sessionDescription:sdp];
//        
//    }else if ([type compare:@"candidate"] == NSOrderedSame) {
//        NSString *mid = [jsonDict objectForKey:@"id"];
//        NSNumber *sdpLineIndex = [jsonDict objectForKey:@"label"];
//        NSString *sdp = [jsonDict objectForKey:@"candidate"];
//        RTCICECandidate *candidate =
//        [[RTCICECandidate alloc] initWithMid:mid
//                                       index:sdpLineIndex.intValue
//                                         sdp:sdp];
//        
//        [self.peerConnection addICECandidate:candidate];
//        
//    }else if ([type compare:@"bye"] == NSOrderedSame) {
//        [self stopRTCTaskAsInitiator:NO];
//    }
//    
//}

#pragma mark -
#pragma mark -

+ (NSString *)firstMatch:(NSRegularExpression *)pattern
              withString:(NSString *)string
{
    NSTextCheckingResult* result =
    [pattern firstMatchInString:string
                        options:0
                          range:NSMakeRange(0, [string length])];
    if (!result)
        return nil;
    return [string substringWithRange:[result rangeAtIndex:1]];
}

+ (NSString *)preferISAC:(NSString *)origSDP
{
    int mLineIndex = -1;
    NSString* isac16kRtpMap = nil;
    NSArray* lines = [origSDP componentsSeparatedByString:@"\n"];
    NSRegularExpression* isac16kRegex = [NSRegularExpression
                                         regularExpressionWithPattern:@"^a=rtpmap:(\\d+) ISAC/16000[\r]?$"
                                         options:0
                                         error:nil];
    for (int i = 0;
         (i < [lines count]) && (mLineIndex == -1 || isac16kRtpMap == nil);
         ++i) {
        NSString* line = [lines objectAtIndex:i];
        if ([line hasPrefix:@"m=audio "]) {
            mLineIndex = i;
            continue;
        }
        isac16kRtpMap = [self firstMatch:isac16kRegex withString:line];
    }
    if (mLineIndex == -1) {
        NSLog(@"No m=audio line, so can't prefer iSAC");
        return origSDP;
    }
    if (isac16kRtpMap == nil) {
        NSLog(@"No ISAC/16000 line, so can't prefer iSAC");
        return origSDP;
    }
    NSArray* origMLineParts =
    [[lines objectAtIndex:mLineIndex] componentsSeparatedByString:@" "];
    NSMutableArray* newMLine =
    [NSMutableArray arrayWithCapacity:[origMLineParts count]];
    int origPartIndex = 0;
    // Format is: m=<media> <port> <proto> <fmt> ...
    [newMLine addObject:[origMLineParts objectAtIndex:origPartIndex++]];
    [newMLine addObject:[origMLineParts objectAtIndex:origPartIndex++]];
    [newMLine addObject:[origMLineParts objectAtIndex:origPartIndex++]];
    [newMLine addObject:isac16kRtpMap];
    for (; origPartIndex < [origMLineParts count]; ++origPartIndex) {
        if ([isac16kRtpMap compare:[origMLineParts objectAtIndex:origPartIndex]]
            != NSOrderedSame) {
            [newMLine addObject:[origMLineParts objectAtIndex:origPartIndex]];
        }
    }
    NSMutableArray* newLines = [NSMutableArray arrayWithCapacity:[lines count]];
    [newLines addObjectsFromArray:lines];
    [newLines replaceObjectAtIndex:mLineIndex
                        withObject:[newMLine componentsJoinedByString:@" "]];
    return [newLines componentsJoinedByString:@"\n"];
}
@end
