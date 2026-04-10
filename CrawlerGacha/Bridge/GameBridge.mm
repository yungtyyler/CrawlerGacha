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

- (void)startBattle {
    // 1. Character: Carl
    Character carl;
    carl.characterId = 1;
    carl.name = "Carl";
    carl.maxHealth = 1000;
    carl.health = 1000;
    
    SkillCard smush = {0, 101, "Smush", 1, false, 150};
    SkillCard explosive = {0, 102, "Doomsday Device", 1, true, 5000};
    carl.characterSkills.push_back(smush);
    carl.characterSkills.push_back(explosive);
    
    // 2. Character: Princess Donut
    Character donut;
    donut.characterId = 2;
    donut.name = "Princess Donut";
    donut.maxHealth = 600;
    donut.health = 600;
    
    SkillCard missile = {0, 103, "Magic Missile", 1, false, 100};
    SkillCard goddammit = {0, 104, "Goddammit, Carl!", 1, false, 50};
    donut.characterSkills.push_back(missile);
    donut.characterSkills.push_back(goddammit);
    
    // 3.1 Enemy: Syndicate Scavenger
    Character scavenger;
    scavenger.characterId = 999;
    scavenger.name = "Syndicate Scavenger";
    scavenger.maxHealth = 2500;
    scavenger.health = 2500;
    // (Enemies don't need deck skills right now)
    
    // 3.2 Enemy: Guard
    Character guard;
    guard.characterId = 998;
    guard.name = "Syndicate Guard";
    guard.maxHealth = 3000;
    guard.health = 3000;
    
    // 4. Form the Parties
    currentState.playerParty.clear();
    currentState.playerParty.push_back(carl);
    currentState.playerParty.push_back(donut);
    
    currentState.enemyParty.clear();
    currentState.enemyParty.push_back(scavenger);
    currentState.enemyParty.push_back(guard);
    
    // 5. Shuffle the deck
    currentState.currentHand.clear();
    initializeDeck(currentState);
    
    // 6. Give player action points
    currentState.maxActionPoints = 3;
    currentState.currentActionPoints = 3;
    
    currentState.currentPhase = GamePhase::PlayerTurn;
    
    currentState.currentHand.clear();
    initializeDeck(currentState);
}

- (void)drawCards:(NSInteger)amount {
    drawCards(currentState, (int)amount);
    checkAndMergeCards(currentState);
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

- (void)skipAction {
    skipAction(currentState);
}

- (void)moveCardFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    moveCard(currentState, (int)fromIndex, (int)toIndex);
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

- (void)endTurn {
    endTurn(currentState);
}

- (void)queueCardAtIndex:(NSInteger)index {
    queueCard(currentState, (int)index);
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

- (NSInteger)getCurrentActionPoints {
    return currentState.currentActionPoints;
}

- (NSInteger)getMaxActionPoints {
    return currentState.maxActionPoints;
}

- (void)setTargetIndex:(NSInteger)index {
    setTarget(currentState, (int)index);
}

- (void)executeEnemyTurn {
    executeEnemyTurn(currentState);
}

- (NSInteger)getCurrentPhase {
    return static_cast<NSInteger>(currentState.currentPhase);
}

- (NSInteger)getCurrentTargetIndex {
    return currentState.currentTargetIndex;
}

@end
