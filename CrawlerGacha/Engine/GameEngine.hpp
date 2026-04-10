//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#ifndef GameEngine_hpp
#define GameEngine_hpp

#include <string>
#include <vector>

enum class GamePhase {
    PlayerTurn,  // 0
    EnemyTurn,   // 1
    Victory,     // 2
    Defeat       // 3
};

struct SkillCard {
    int instanceId;       // Unique serial number for this exact physical card
    int id;               // The type of skill (e.g., 101)
    std::string name;
    int tier;
    
    bool isAoE;
    int baseDamage;
    
    bool canMergeWith(const SkillCard& otherCard) const {
        return (id == otherCard.id) && (tier == otherCard.tier) && (tier < 3);
    }
};

struct Character {
    int characterId;
    std::string name;
    
    int maxHealth;
    int health;
    
    std::vector<SkillCard> characterSkills;
};

struct BattleState {
    std::vector<Character> playerParty;
    std::vector<Character> enemyParty;
    
    std::vector<SkillCard> drawPile;
    std::vector<SkillCard> currentHand;
    
    std::vector<SkillCard> actionQueue;
    
    int maxActionPoints;
    int currentActionPoints;
    int currentTargetIndex;
    
    GamePhase currentPhase;
};

void setTarget(BattleState& state, int enemyIndex);
void executeEnemyTurn(BattleState& state);
void skipAction(BattleState& state);
void queueCard(BattleState& state, int handIndex);
void executeQueue(BattleState& state);
void endTurn(BattleState& state);
void initializeDeck(BattleState& state);
void drawCards(BattleState& state, int amount);
void checkAndMergeCards(BattleState& state);
void moveCard(BattleState& state, int fromIndex, int toIndex);
void checkWinCondition(BattleState& state);

#endif /* GameEngine_hpp */
