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
constexpr int NUM_SKILLS_PER_CHARACTER_IN_DECK = 5;
constexpr int DAMAGE_SCALE_ON_UPGRADE = 2;
constexpr int TIER_INCREASE_ON_UPGRADE = 1;

// ==========================================
// 1. DECK LOGIC
// ==========================================

void initializeBattle(BattleState& state) {
    // 1. Character: Carl
    Character carl;
    carl.characterId = 1;
    carl.name = "Carl";
    carl.maxHealth = 1000;
    carl.health = 1000;
    
    SkillCard smush = {0, 101, 1, "Smush", 1, false, 300};
    SkillCard explosive = {0, 102, 1, "Doomsday Device", 1, true, 800};
    carl.characterSkills.push_back(smush);
    carl.characterSkills.push_back(explosive);
    
    // 2. Character: Princess Donut
    Character donut;
    donut.characterId = 2;
    donut.name = "Princess Donut";
    donut.maxHealth = 600;
    donut.health = 600;
    
    SkillCard missile = {0, 103, 2, "Magic Missile", 1, false, 600};
    SkillCard goddammit = {0, 104, 2, "Goddammit, Carl!", 1, false, 200};
    donut.characterSkills.push_back(missile);
    donut.characterSkills.push_back(goddammit);
    
    // 3. Enemies
    Character scavenger;
    scavenger.characterId = 999;
    scavenger.name = "Syndicate Scavenger";
    scavenger.maxHealth = 2500;
    scavenger.health = 2500;
    
    Character guard;
    guard.characterId = 998;
    guard.name = "Syndicate Guard";
    guard.maxHealth = 3000;
    guard.health = 3000;
    
    // 4. Form the Parties
    state.playerParty.clear();
    state.playerParty.push_back(carl);
    state.playerParty.push_back(donut);
    
    state.enemyParty.clear();
    state.enemyParty.push_back(scavenger);
    state.enemyParty.push_back(guard);
    
    // 5. Initialize the Rules
    state.maxActionPoints = static_cast<int>(state.playerParty.size());
    state.currentActionPoints = static_cast<int>(state.playerParty.size());
    state.currentTargetIndex = 0;
    state.currentPhase = GamePhase::PlayerTurn;
    
    // 6. Shuffle the deck
    state.currentHand.clear();
    initializeDeck(state);
}

void initializeDeck(BattleState& state) {
    state.drawPile.clear();
    
    for (const auto& character : state.playerParty) {
        if (character.health > 0) {
            for (const auto& skill : character.characterSkills) {
                for (int i = 0; i < NUM_SKILLS_PER_CHARACTER_IN_DECK; ++i) {
                    state.drawPile.push_back(skill);
                }
            }
        }
    }
    
    std::random_device rd;
    std::mt19937 g(rd());
    std::shuffle(state.drawPile.begin(), state.drawPile.end(), g);
};

void drawCards(BattleState& state, int amount) {
    int aliveCount = 0;
    for (const auto& player : state.playerParty) {
        if (player.health > 0) aliveCount++;
    }
    
    int dynamicMaxCards = (aliveCount > 1) ? 7 : 4;
    
    for (int i = 0; i < amount; ++i) {
        if (state.currentHand.size() >= dynamicMaxCards) {
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
}

void checkAndMergeCards(BattleState& state) {
    // If we have 1 or 0 cards, it is mathematically impossible to merge.
    // Kick out immediately to prevent unsigned integer underflow!
    if (state.currentHand.size() < 2) {
        return;
    }
    
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

// ==========================================
// 2. PLAYER ACTIONS
// ==========================================

void moveCard(BattleState& state, int fromIndex, int toIndex) {
    if (state.currentPhase != GamePhase::PlayerTurn) return;
    
    if (state.currentActionPoints <= 0) return;
    
    if (fromIndex < 0 || fromIndex >= static_cast<int>(state.currentHand.size()) ||
        toIndex < 0 || toIndex >= static_cast<int>(state.currentHand.size()) ||
        fromIndex == toIndex) {
        return;
    }
    
    state.currentActionPoints -= 1;
    
    SkillCard moveReceipt = {0, -1, 0, "Move", 0, false, 0};
    state.actionQueue.push_back(moveReceipt);

    SkillCard movingCard = state.currentHand[fromIndex];
    state.currentHand.erase(state.currentHand.begin() + fromIndex);
    state.currentHand.insert(state.currentHand.begin() + toIndex, movingCard);
    
    checkAndMergeCards(state);
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

void skipAction(BattleState& state) {
    if (state.currentActionPoints <= 0) {
        return;
    }
    
    state.currentActionPoints -= 1;
    
    SkillCard skipReceipt = {0, -2, 0, "Skip", 0, false, 0};
    state.actionQueue.push_back(skipReceipt);
}

// ==========================================
// 3. COMBAT & PHASE LOGIC
// ==========================================

void setTarget(BattleState& state, int enemyIndex) {
    if (enemyIndex >= 0 && enemyIndex < static_cast<int>(state.enemyParty.size())) {
        if (state.enemyParty[enemyIndex].health > 0) {
            state.currentTargetIndex = enemyIndex;
        }
    }
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

void executeQueue(BattleState& state) {
    if (state.enemyParty.empty()) return;

    for (const auto& action : state.actionQueue) {
        if (action.id > 0) { // If it's a real attack
            
            // 1. AUTO-SNAP: If our target is dead, find the next living enemy!
            if (state.enemyParty[state.currentTargetIndex].health <= 0) {
                for (int i = 0; i < static_cast<int>(state.enemyParty.size()); ++i) {
                    if (state.enemyParty[i].health > 0) {
                        state.currentTargetIndex = i;
                        break;
                    }
                }
            }

            // 2. DEAL DAMAGE
            if (action.isAoE) {
                for (auto& enemy : state.enemyParty) {
                    if (enemy.health > 0) { // Don't hit corpses
                        enemy.health -= action.baseDamage;
                        if (enemy.health < 0) enemy.health = 0;
                    }
                }
            } else {
                // Double check that we actually found a living target
                if (state.enemyParty[state.currentTargetIndex].health > 0) {
                    state.enemyParty[state.currentTargetIndex].health -= action.baseDamage;
                    if (state.enemyParty[state.currentTargetIndex].health < 0) {
                        state.enemyParty[state.currentTargetIndex].health = 0;
                    }
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
    
    purgeDeadCharacterCards(state);
    
    int aliveCount = 0;
    for (const auto& player : state.playerParty) {
        if (player.health > 0) aliveCount++;
    }
    
    state.maxActionPoints = aliveCount;
    state.currentActionPoints = state.maxActionPoints;
    
    int dynamicMaxCards = (aliveCount > 1) ? 7 : 4;
    int missingCards = dynamicMaxCards - static_cast<int>(state.currentHand.size());
    
    if (missingCards > 0) {
        drawCards(state, missingCards);
    }
    
    checkAndMergeCards(state);
    
    state.currentPhase = GamePhase::PlayerTurn;
    checkWinCondition(state);
}

void purgeDeadCharacterCards(BattleState& state) {
    std::vector<int> aliveIds;
    for (const auto& player : state.playerParty) {
        if (player.health > 0) aliveIds.push_back(player.characterId);
    }
    
    auto isCardDead = [&](const SkillCard& card) {
        if (card.id < 0) return false;
        return std::find(aliveIds.begin(), aliveIds.end(), card.ownerId) == aliveIds.end();
    };
    
    state.currentHand.erase(std::remove_if(state.currentHand.begin(), state.currentHand.end(), isCardDead), state.currentHand.end());
    state.drawPile.erase(std::remove_if(state.drawPile.begin(), state.drawPile.end(), isCardDead), state.drawPile.end());
    state.actionQueue.erase(std::remove_if(state.actionQueue.begin(), state.actionQueue.end(), isCardDead), state.actionQueue.end());
}
