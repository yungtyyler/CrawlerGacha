//
//  GameTypes.hpp
//  CrawlerGacha
//
//  Created by Tyler Varzeas on 4/9/26.
//

#ifndef GameTypes_hpp
#define GameTypes_hpp

#include <string>
#include <vector>

// --- THE STATE MACHINE ---
enum class GamePhase {
    PlayerTurn,  // 0
    EnemyTurn,   // 1
    Victory,     // 2
    Defeat       // 3
};

// --- THE GAME OBJECTS ---
struct SkillCard {
    int instanceId;
    int id;
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

// --- THE WORLD STATE ---
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

#endif /* GameTypes_hpp */
