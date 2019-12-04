//
//  ModelCapability.m
//  PATerminal
//
//  Created by Oskar Wong on 2018/06/25.
//  Copyright © 2018 Oskar Wong. All rights reserved.
//
//  The printer settings

#import "ModelCapability.h"

typedef NS_ENUM(NSInteger, ModelCapabilityIndex) {
    ModelCapabilityIndexTitle = 0,
    ModelCapabilityIndexEmulation,
    ModelCapabilityIndexCashDrawerOpenActive,
    ModelCapabilityIndexPortSettings,
    ModelCapabilityIndexModelNameArray
};

static const NSArray      *_modelIndexArray;
static const NSDictionary *_modelCapabilityDictionary;

@implementation ModelCapability

+ (void)initialize {
    if (self == [ModelCapability class]) {
        _modelIndexArray = @ [
                              @(ModelIndexMPOP),
                              @(ModelIndexTSP650II),
                              @(ModelIndexTSP700II),
                              @(ModelIndexTSP800II),
                              @(ModelIndexSP700),                 // <-
                              @(ModelIndexSM_L200),               // <-
                              @(ModelIndexSM_L300),               // <-
                              
                              //          @(ModelIndexSM_L200),
                              //          @(ModelIndexSP700),
                              //          @(ModelIndexSM_L300)
                              ];
        
        _modelCapabilityDictionary = @ {
            @(ModelIndexMPOP)              : @[@"mPOP",              @(StarIoExtEmulationStarPRNT),      @NO,  @"",         @[@"POP10"]],
            @(ModelIndexTSP650II)          : @[@"TSP650II",          @(StarIoExtEmulationStarLine),      @YES, @"",         @[@"TSP654II (STR_T-001)",     // Only LAN model->
                                                                                                                              @"TSP654 (STR_T-001)",
                                                                                                                              @"TSP651 (STR_T-001)"]],
            @(ModelIndexTSP700II)          : @[@"TSP700II",          @(StarIoExtEmulationStarLine),      @YES, @"",         @[@"TSP743II (STR_T-001)",
                                                                                                                              @"TSP743 (STR_T-001)"]],
            @(ModelIndexTSP800II)          : @[@"TSP800II",          @(StarIoExtEmulationStarLine),      @YES, @"",         @[@"TSP847II (STR_T-001)",
                                                                                                                              @"TSP847 (STR_T-001)"]],     // <-Only LAN model
            @(ModelIndexSM_L200)           : @[@"SM-L200",           @(StarIoExtEmulationStarPRNT),      @NO,  @"Portable", @[@"SM-L200"]],
            @(ModelIndexSP700)             : @[@"SP700",             @(StarIoExtEmulationStarDotImpact), @YES, @"",         @[@"SP712 (STR-001)",          // Only LAN model
                                                                                                                              @"SP717 (STR-001)",
                                                                                                                              @"SP742 (STR-001)",
                                                                                                                              @"SP747 (STR-001)"]],
            @(ModelIndexSM_L300)           : @[@"SM-L300",           @(StarIoExtEmulationStarPRNTL),     @NO,  @"Portable", @[@"SM-L300"]]
        };
    }
}

+ (NSInteger)modelIndexCount {
    return _modelIndexArray.count;
}

+ (ModelIndex)modelIndexAtIndex:(NSInteger)index {
    return [_modelIndexArray[index] integerValue];
}

+ (NSString *)titleAtModelIndex:(ModelIndex)modelIndex {
    return _modelCapabilityDictionary[@(modelIndex)][ModelCapabilityIndexTitle];
}

+ (StarIoExtEmulation)emulationAtModelIndex:(ModelIndex)modelIndex {
    return [_modelCapabilityDictionary[@(modelIndex)][ModelCapabilityIndexEmulation] integerValue];
}

+ (BOOL)cashDrawerOpenActiveAtModelIndex:(ModelIndex)modelIndex {
    return [_modelCapabilityDictionary[@(modelIndex)][ModelCapabilityIndexCashDrawerOpenActive] boolValue];
}

+ (NSString *)portSettingsAtModelIndex:(ModelIndex)modelIndex {
    return _modelCapabilityDictionary[@(modelIndex)][ModelCapabilityIndexPortSettings];
}

+ (ModelIndex)modelIndexAtModelName:(NSString *)modelName {
    for (id modelIndex in _modelCapabilityDictionary) {
        NSArray *modelNameArray = _modelCapabilityDictionary[modelIndex][ModelCapabilityIndexModelNameArray];
        
        for (int i = 0; i < modelNameArray.count; i++) {
            if ([modelName hasPrefix:modelNameArray[i]] == YES) {
                return [modelIndex integerValue];
            }
        }
    }
    
    return ModelIndexNone;
}

@end
