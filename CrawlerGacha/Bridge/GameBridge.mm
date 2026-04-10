//
//  GameBridge.mm
//  CrawlerGacha
//
//  Created by Tyler Varzeas on 4/7/26.
//

#import "GameBridge.h"
#include "GameEngine.hpp"

@implementation IOSSkillCard
@end
@implementation IOSCharacter
@end

@implementation GameBridge {
    BattleState currentState;
}

// ==========================================
// 1. GAME LIFECYCLE
// ==========================================

- (void)startBattle {
    initializeBattle(currentState);
}

- (void)endTurn {
    endTurn(currentState);
}

- (void)executeEnemyTurn {
    executeEnemyTurn(currentState);
}

// ==========================================
// 2. PLAYER ACTIONS
// ==========================================

- (void)queueCardAtIndex:(NSInteger)index {
    queueCard(currentState, (int)index);
}

- (void)skipAction {
    skipAction(currentState);
}

- (void)moveCardFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    moveCard(currentState, (int)fromIndex, (int)toIndex);
}

- (void)setTargetIndex:(NSInteger)index {
    setTarget(currentState, (int)index);
}

- (void)drawCards:(NSInteger)amount {
    drawCards(currentState, (int)amount);
    checkAndMergeCards(currentState);
}

// ==========================================
// 3. STATE SYNCING (C++ -> Swift)
// ==========================================

- (NSInteger)getCurrentPhase {
    return static_cast<NSInteger>(currentState.currentPhase);
}

- (NSInteger)getCurrentActionPoints {
    return currentState.currentActionPoints;
}

- (NSInteger)getMaxActionPoints {
    return currentState.maxActionPoints;
}

- (NSInteger)getCurrentTargetIndex {
    return currentState.currentTargetIndex;
}

- (NSArray<IOSCharacter *> *)getPlayerParty {
    NSMutableArray *array = [NSMutableArray array];
    for (const auto& cppChar : currentState.playerParty) {
        IOSCharacter *iosChar = [[IOSCharacter alloc] init];
        iosChar.characterId = cppChar.characterId;
        iosChar.name = [NSString stringWithUTF8String:cppChar.name.c_str()];
        iosChar.maxHealth = cppChar.maxHealth;
        iosChar.health = cppChar.health;
        [array addObject:iosChar];
    }
    return array;
}

- (NSArray<IOSCharacter *> *)getEnemyParty {
    NSMutableArray *array = [NSMutableArray array];
    for (const auto& cppChar : currentState.enemyParty) {
        IOSCharacter *iosChar = [[IOSCharacter alloc] init];
        iosChar.characterId = cppChar.characterId;
        iosChar.name = [NSString stringWithUTF8String:cppChar.name.c_str()];
        iosChar.maxHealth = cppChar.maxHealth;
        iosChar.health = cppChar.health;
        [array addObject:iosChar];
    }
    return array;
}

- (NSArray<IOSSkillCard *> *)getCurrentHand {
    NSMutableArray *swiftHand = [NSMutableArray array];
    for (size_t i = 0; i < currentState.currentHand.size(); i++) {
        SkillCard cppCard = currentState.currentHand[i];
        IOSSkillCard *iosCard = [[IOSSkillCard alloc] init];
        iosCard.instanceId = cppCard.instanceId;
        iosCard.cardId = cppCard.id;
        iosCard.name = [NSString stringWithUTF8String:cppCard.name.c_str()];
        iosCard.tier = cppCard.tier;
        iosCard.baseDamage = cppCard.baseDamage;
        iosCard.isAoE = cppCard.isAoE;
        [swiftHand addObject:iosCard];
    }
    return swiftHand;
}

- (NSArray<IOSSkillCard *> *)getActionQueue {
    NSMutableArray *swiftQueue = [NSMutableArray array];
    for (size_t i = 0; i < currentState.actionQueue.size(); i++) {
        SkillCard cppCard = currentState.actionQueue[i];
        IOSSkillCard *iosCard = [[IOSSkillCard alloc] init];
        iosCard.instanceId = cppCard.instanceId;
        iosCard.cardId = cppCard.id;
        iosCard.name = [NSString stringWithUTF8String:cppCard.name.c_str()];
        iosCard.tier = cppCard.tier;
        iosCard.baseDamage = cppCard.baseDamage;
        iosCard.isAoE = cppCard.isAoE;
        [swiftQueue addObject:iosCard];
    }
    return swiftQueue;
}

@end
