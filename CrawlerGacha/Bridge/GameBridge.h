//
//  GameBridge.h
//  CrawlerGacha
//
//  Created by Tyler Varzeas on 4/7/26.
//

#import <Foundation/Foundation.h>
#import "BridgeModels.h"

NS_ASSUME_NONNULL_BEGIN

@interface GameBridge : NSObject

-(void)startBattle;
-(void)drawCards:(NSInteger)amount;
-(NSArray<IOSSkillCard *> *)getCurrentHand;
-(void)moveCardFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

-(NSArray<IOSCharacter *> *)getPlayerParty;
-(NSArray<IOSCharacter *> *)getEnemyParty;

-(void)setTargetIndex:(NSInteger)index;
-(void)executeEnemyTurn;
-(NSInteger)getCurrentPhase;
-(NSInteger)getCurrentTargetIndex;
-(void)skipAction;
-(void)endTurn;
-(void)queueCardAtIndex:(NSInteger)index;
-(NSArray<IOSSkillCard *> *)getActionQueue;
-(NSInteger)getCurrentActionPoints;
-(NSInteger)getMaxActionPoints;

@end

NS_ASSUME_NONNULL_END
