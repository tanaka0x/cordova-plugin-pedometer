//
//  Pedometer.m
//  Copyright (c) 2014 Lee Crossley - http://ilee.co.uk
//

#import "Cordova/CDV.h"
#import "Cordova/CDVViewController.h"
#import "CoreMotion/CoreMotion.h"
#import "Pedometer.h"

@interface Pedometer ()
    @property (nonatomic, strong) CMPedometer *pedometer;
@end

@implementation Pedometer

- (CMPedometer*) pedometer {
    if (_pedometer == nil) {
        _pedometer = [[CMPedometer alloc] init];
    }
    return _pedometer;
}

- (void) isStepCountingAvailable:(CDVInvokedUrlCommand*)command;
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[CMPedometer isStepCountingAvailable]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) isDistanceAvailable:(CDVInvokedUrlCommand*)command;
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[CMPedometer isDistanceAvailable]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) isFloorCountingAvailable:(CDVInvokedUrlCommand*)command;
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[CMPedometer isFloorCountingAvailable]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) startPedometerUpdates:(CDVInvokedUrlCommand*)command;
{
    __block CDVPluginResult* pluginResult = nil;

    [self.pedometer startPedometerUpdatesFromDate:[NSDate date] withHandler:^(CMPedometerData *pedometerData, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error)
            {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
            }
            else
            {
                NSDictionary* pedestrianData = @{
                    @"startDate": [NSString stringWithFormat:@"%f", [pedometerData.startDate timeIntervalSince1970] * 1000],
                    @"endDate": [NSString stringWithFormat:@"%f", [pedometerData.endDate timeIntervalSince1970] * 1000],
                    @"numberOfSteps": pedometerData.numberOfSteps,
                    @"distance": pedometerData.distance,
                    @"floorsAscended": pedometerData.floorsAscended,
                    @"floorsDescended": pedometerData.floorsDescended
                };
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:pedestrianData];
                [pluginResult setKeepCallbackAsBool:true];
            }

            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        });
    }];
}

- (void) stopPedometerUpdates:(CDVInvokedUrlCommand*)command;
{
    [self.pedometer stopPedometerUpdates];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) queryData:(CDVInvokedUrlCommand*)command;
{
    NSDictionary* args = [command.arguments objectAtIndex:0];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

    NSDate* startDate;
    NSDate* endDate;
    if ([[args objectForKey:@"startDate"] isKindOfClass:[NSDate class]]) {
        startDate = [args objectForKey:@"startDate"];
    } else {
        startDate = [dateFormatter dateFromString:[args objectForKey:@"startDate"]];
    }
    
    if ([[args objectForKey:@"endDate"] isKindOfClass:[NSDate class]]) {
        endDate = [args objectForKey:@"endDate"];
    } else {
        endDate = [dateFormatter dateFromString:[args objectForKey:@"endDate"]];
    }
    
    __block CDVPluginResult* pluginResult = nil;

    [self.pedometer queryPedometerDataFromDate:startDate toDate:endDate withHandler:^(CMPedometerData *pedometerData, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error)
            {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
            }
            else
            {
                NSDictionary* pedestrianData = @{
                    @"numberOfSteps": pedometerData.numberOfSteps,
                    @"distance": pedometerData.distance,
                    @"floorsAscended": pedometerData.floorsAscended,
                    @"floorsDescended": pedometerData.floorsDescended
                };
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:pedestrianData];
            }

            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        });
    }];
}

@end
