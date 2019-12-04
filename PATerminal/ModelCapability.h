//
//  ModelCapability.h
//  PATerminal
//
//  Created by Oskar Wong on 2018/06/25.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <StarIO_Extension/StarIoExt.h>

typedef NS_ENUM(NSInteger, ModelIndex) {
    ModelIndexNone = 0,
    ModelIndexMPOP,
    ModelIndexTSP650II,
    ModelIndexTSP700II,
    ModelIndexTSP800II,
    ModelIndexSM_L200,
    ModelIndexSP700,
    // V5.3.0
    ModelIndexSM_L300
};

@interface ModelCapability : NSObject

+ (NSInteger)modelIndexCount;

+ (ModelIndex)modelIndexAtIndex:(NSInteger)index;

+ (NSString *)titleAtModelIndex:(ModelIndex)modelIndex;

+ (StarIoExtEmulation)emulationAtModelIndex:(ModelIndex)modelIndex;

+ (BOOL)cashDrawerOpenActiveAtModelIndex:(ModelIndex)modelIndex;

+ (NSString *)portSettingsAtModelIndex:(ModelIndex)modelIndex;

+ (ModelIndex)modelIndexAtModelName:(NSString *)modelName;

@end
