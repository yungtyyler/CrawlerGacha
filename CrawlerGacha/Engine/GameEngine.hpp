//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#ifndef GameEngine_hpp
#define GameEngine_hpp

#include "GameTypes.hpp"

// --- COMBAT LOGIC ---
void setTarget(BattleState& state, int enemyIndex);
void executeEnemyTurn(BattleState& state);
void checkWinCondition(BattleState& state);
void executeQueue(BattleState& state);
void endTurn(BattleState& state);

// --- PLAYER ACTIONS ---
void skipAction(BattleState& state);
void queueCard(BattleState& state, int handIndex);
void moveCard(BattleState& state, int fromIndex, int toIndex);

// --- DECK LOGIC ---
void initializeDeck(BattleState& state);
void drawCards(BattleState& state, int amount);
void checkAndMergeCards(BattleState& state);

#endif /* GameEngine_hpp */
