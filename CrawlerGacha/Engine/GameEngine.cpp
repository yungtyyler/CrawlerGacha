//
//  GameEngine.cpp
//  CrawlerGacha
//
//  Created by Tyler Varzeas on 4/6/26.
//

#include "GameEngine.hpp"
#include <random>
#include <algorithm>

static int nextInstanceId = 1;
constexpr int MAX_CARDS = 7;
constexpr int NUM_SKILLS_PER_CHARACTER_IN_DECK = 5;
constexpr int DAMAGE_SCALE_ON_UPGRADE = 2;
constexpr int TIER_INCREASE_ON_UPGRADE = 1;


void initializeDeck(BattleState& state) {
    state.drawPile.clear();
    
    for (const auto& character : state.playerParty) {
        for (const auto& skill : character.characterSkills) {
            for (int i = 0; i < NUM_SKILLS_PER_CHARACTER_IN_DECK; ++i) {
                state.drawPile.push_back(skill);
            }
        }
    }
    
    std::random_device rd;
    std::mt19937 g(rd());
    std::shuffle(state.drawPile.begin(), state.drawPile.end(), g);
};

void drawCards(BattleState& state, int amount) {
    for (int i = 0; i < amount; ++i) {
        if (state.currentHand.size() >= MAX_CARDS) {
            break;
        }
        
        if (state.drawPile.empty()) {
            initializeDeck(state);
        }
        
        if (!state.drawPile.empty()) {
            SkillCard cardToDraw = state.drawPile.back();
            state.drawPile.pop_back();
            
            cardToDraw.instanceId = nextInstanceId;
            nextInstanceId++;
            
            state.currentHand.push_back(cardToDraw);
        }
    }
};

void checkAndMergeCards(BattleState& state) {
    bool merged = true;
    
    while (merged) {
        merged = false;
        
        for (size_t i = 0; i < state.currentHand.size() - 1; ++i) {
            if (state.currentHand[i].canMergeWith(state.currentHand[i+1])) {
                state.currentHand[i].tier += TIER_INCREASE_ON_UPGRADE;
                state.currentHand[i].baseDamage *= DAMAGE_SCALE_ON_UPGRADE;
                
                state.currentHand.erase(state.currentHand.begin() + i + 1);
                
                merged = true;
                break;
            }
        }
    }
}

void setTarget(BattleState& state, int enemyIndex) {
    if (enemyIndex >= 0 && enemyIndex < static_cast<int>(state.enemyParty.size())) {
        state.currentTargetIndex = enemyIndex;
    }
}

void skipAction(BattleState& state) {
    if (state.currentActionPoints <= 0) {
        return;
    }
    
    state.currentActionPoints -= 1;
    
    SkillCard skipReceipt = {0, -2, "Skip", 0, 0};
    state.actionQueue.push_back(skipReceipt);
}

void moveCard(BattleState& state, int fromIndex, int toIndex) {
    if (state.currentPhase != GamePhase::PlayerTurn) return;
    
    if (state.currentActionPoints <= 0) return;
    
    if (fromIndex < 0 || fromIndex >= static_cast<int>(state.currentHand.size()) ||
        toIndex < 0 || toIndex >= static_cast<int>(state.currentHand.size()) ||
        fromIndex == toIndex) {
        return;
    }
    
    state.currentActionPoints -= 1;
    
    SkillCard moveReceipt = {0, -1, "Move", 0, 0};
    state.actionQueue.push_back(moveReceipt);

    SkillCard movingCard = state.currentHand[fromIndex];
    state.currentHand.erase(state.currentHand.begin() + fromIndex);
    state.currentHand.insert(state.currentHand.begin() + toIndex, movingCard);
    
    checkAndMergeCards(state);
}

void executeQueue(BattleState& state) {
    if (state.enemyParty.empty()) return;

    if (state.currentTargetIndex < 0 || state.currentTargetIndex >= static_cast<int>(state.enemyParty.size())) {
        state.currentTargetIndex = 0;
    }

    for (const auto& action : state.actionQueue) {
        if (action.id > 0) {
            if (action.isAoE) {
                for (auto& enemy : state.enemyParty) {
                    enemy.health -= action.baseDamage;
                    if (enemy.health < 0) enemy.health = 0;
                }
            } else {
                state.enemyParty[state.currentTargetIndex].health -= action.baseDamage;
                if (state.enemyParty[state.currentTargetIndex].health < 0) {
                    state.enemyParty[state.currentTargetIndex].health = 0;
                }
            }
        }
    }
    
    checkWinCondition(state);
}

void endTurn(BattleState& state) {
    executeQueue(state);
    state.actionQueue.clear();
    
    state.currentPhase = GamePhase::EnemyTurn;
}

void executeEnemyTurn(BattleState& state) {
    for (auto& enemy : state.enemyParty) {
        if (enemy.health > 0) {
            for (auto& player : state.playerParty) {
                if (player.health > 0) {
                    player.health -= 250;
                    if (player.health < 0) player.health = 0;
                    break;
                }
            }
        }
    }
    
    state.currentActionPoints = state.maxActionPoints;
    
    int missingCards = 7 - static_cast<int>(state.currentHand.size());
    if (missingCards > 0) {
        drawCards(state, missingCards);
    }
    checkAndMergeCards(state);
    
    state.currentPhase = GamePhase::PlayerTurn;
    checkWinCondition(state);
}

void queueCard(BattleState& state, int handIndex) {
    if (state.currentPhase != GamePhase::PlayerTurn) return;
    
    if (state.currentActionPoints <= 0) return;
    
    if (handIndex < 0 || handIndex >= static_cast<int>(state.currentHand.size())) {
        return;
    }
    
    SkillCard cardToPlay = state.currentHand[handIndex];
    state.currentHand.erase(state.currentHand.begin() + handIndex);
    state.actionQueue.push_back(cardToPlay);
    
    state.currentActionPoints -= 1;
    
    checkAndMergeCards(state);
}

void checkWinCondition(BattleState& state) {
    bool allEnemiesDead = true;
    for (const auto& enemy : state.enemyParty) {
        if (enemy.health > 0) allEnemiesDead = false;
    }
    if (allEnemiesDead) {
        state.currentPhase = GamePhase::Victory;
        return;
    }

    bool allPlayersDead = true;
    for (const auto& player : state.playerParty) {
        if (player.health > 0) allPlayersDead = false;
    }
    if (allPlayersDead) {
        state.currentPhase = GamePhase::Defeat;
        return;
    }
}
