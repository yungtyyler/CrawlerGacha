//
//  BridgeModels.h
//  CrawlerGacha
//
//  Created by Tyler Varzeas on 4/9/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IOSSkillCard : NSObject
@property (nonatomic, assign) NSInteger instanceId;
@property (nonatomic, assign) NSInteger cardId;
@property (nonatomic, assign) NSInteger ownerId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger tier;
@property (nonatomic, assign) NSInteger baseDamage;
@property (nonatomic, assign) BOOL isAoE;
@end

@interface IOSCharacter : NSObject
@property (nonatomic, assign) NSInteger characterId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger maxHealth;
@property (nonatomic, assign) NSInteger health;
@end

NS_ASSUME_NONNULL_END
