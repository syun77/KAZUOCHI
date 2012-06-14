//
//  Enemy.mm
//  Connect_X_Connect
//
//  Created by OzekiSyunsuke on 12/06/05.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "Enemy.h"
#import "SceneMain.h"
#import "Exerinya.h"
#import "Particle.h"

// 座標関連
static const int ENEMY_POS_X = 320-64;
static const int ENEMY_POS_Y = 480-80;
static const int ENEMY_POS_LV_Y = ENEMY_POS_Y+64;
static const int ENEMY_POS_DAMAGE = ENEMY_POS_Y-16;

static const int ENEMY_AT_X = 320-128;
static const int ENEMY_AT_Y = 480-120;
static const int ENEMY_AT_W = 64;
static const int ENEMY_AT_H = 4;

// タイマー関連
static const int TIMER_DAMAGE = 30;
static const int TIMER_APPEAR = 30;

// アクティブタイムゲージ関連
static const int AT_MAX = 100;

/**
 * 状態
 */
enum eState {
    eState_Appear,  // 出現状態
    eState_Standby, // 待機中
    eState_Vanish,  // 消滅演出
};

/**
 * 敵の実装
 */
@implementation Enemy

@synthesize m_pFont;

/**
 * コントローラー取得
 */
- (MainCtrl*)_getCtrl {
    
    return [SceneMain sharedInstance].ctrl;
}

- (AtGauge*)_getAtGauge {
    
    return [SceneMain sharedInstance].atGauge;
}


/**
 * コンストラクタ
 */
- (id)init {
    self = [super init];
    if (self == nil) {
        return self;
    }
    
    [self load:@"all.png"];
    [self create];
    
    self._x = ENEMY_POS_X;
    self._y = ENEMY_POS_Y;
    CGRect r = Exerinya_GetRect(eExerinyaRect_Nasu);
    [self setTexRect:r];
    [self setVisible:NO];
    
    m_Id = 0;
    m_Hp = HP_MAX;
    
    m_nAT = 0;
    m_dAT = 40;
    
    return self;
}

/**
 * フォントを登録
 */
- (void)attachLayer:(CCLayer *)layer {
    
    self.m_pFont = [AsciiFont node];
    [self.m_pFont createFont:layer length:24];
    [self.m_pFont setAlign:eFontAlign_Center];
    [self.m_pFont setScale:2];
    [self.m_pFont setPos:32 y:45];
}

/**
 * デストラクタ
 */
- (void)dealloc {
    
    self.m_pFont = nil;
    
    [super dealloc];
}

// ---------------------------------------------------------
// private

/**
 * HPゲージの取得
 */
//- (HpGauge*)_getGauge {
//    
//    return [SceneMain sharedInstance].hpGaugeEnemy;
//}

- (AsciiFont*)_getFontLevel {
    return [SceneMain sharedInstance].fontLevel;
}

/**
 * HPフォント文字の更新
 */
- (void)_setFont {
//    [self.m_pFont setText:[NSString stringWithFormat:@"%d/%d", m_Hp, m_HpMax]];
    [self.m_pFont setText:[NSString stringWithFormat:@"%d", m_Hp]];
}

// ---------------------------------------------------------
// update

/**
 * 更新・出現
 */
- (void)_updateAppear {
    
    [self setVisible:YES];
    
    float x = ENEMY_POS_X;
    float y = ENEMY_POS_Y;
    x += m_Timer * 2;
    self._x = x;
    self._y = y;
    
    m_Timer = m_Timer * 0.9;
    if (m_Timer < 1) {
        
        m_Timer = 0;
        m_State = eState_Standby;
    }
    
}
- (void)_updateStandby {
    
    float rot = 15 * Math_SinEx(m_tPast/2);
    [self setRotation:rot];
    
    [self setColor:ccc3(0xFF, 0xFF, 0xFF)];
    
    self._x = ENEMY_POS_X;
    self._y = ENEMY_POS_Y;
    if (m_tDamage > 0) {
        
        m_tDamage--;
        m_tPast = 0;
        
        if (m_tDamage%8 < 4) {
            
            // ダメージ演出
            [self setColor:ccc3(0xFF, 0, 0)];
        }
        
        self._x += (m_tPast%8 < 4 ? -1 : 1) * Math_Randf(m_tDamage);
        self._y += (-m_tDamage*0.5 + Math_Randf(m_tDamage));
    }
}
- (void)_updateVanish {
    
}

/**
 * 更新
 */
- (void)update:(ccTime)dt {
    
    [self move:0];
    
    m_tPast++;
    
    switch (m_State) {
        case eState_Appear:
            [self _updateAppear];
            break;
            
        case eState_Standby:
            [self _updateStandby];
            break;
            
        case eState_Vanish:
            [self _updateVanish];
            break;
            
        default:
            break;
    }
    
    if ([self isDanger] && m_tPast%48 < 24) {
        
        // HP危険
        [self setColor:ccc3(0xFF, 0, 0)];
    }
    else {
        
        [self setColor:ccc3(0xFF, 0xFF, 0xFF)];
    }
    
    // HPフォントの色設定
    if ([self isDanger]) {
        
        [self.m_pFont setColor:ccc3(0xFF, 0x80, 0x80)];
    }
    else if([self getHpRatio] < 0.5) {
        
        [self.m_pFont setColor:ccc3(0xFF, 0xFF, 0x80)];
    }
    else {
        
        [self.m_pFont setColor:ccc3(0xFF, 0xFF, 0xFF)];
    }
    
}

/**
 * ATゲージの描画
 */
- (void)visit {
    [super visit];
    
//    System_SetBlend(eBlend_Normal);
//    float x = ENEMY_AT_X;
//    float y = ENEMY_AT_Y;
//    float w = ENEMY_AT_W * [self getAtRatio];
//    
//    glColor4f(1, 0, 0, 1);
//    [self fillRectLT:x y:y w:w h:ENEMY_AT_H rot:0 scale:1];
//    glLineWidth(1);
//    glColor4f(1, 1, 1, 1);
//    [self drawRectLT:x y:y w:ENEMY_AT_W h:ENEMY_AT_H rot:0 scale:1];
}

// ----------------------------------------------------
// public

/**
 * レベルを設定する
 */
- (void)setLevel:(int)lv {
    m_nLevel = lv;
}

/**
 * 初期化
 */
- (void)initialize {
    
    [self setVisible:YES];
    
    m_State = eState_Appear;
    m_Timer = TIMER_APPEAR;
    m_tDamage = 0;
    
    // レベル表示
    AsciiFont* fontLevel = [self _getFontLevel];
    [fontLevel setPosScreen:ENEMY_POS_X y:ENEMY_POS_LV_Y];
    [fontLevel setText:[NSString stringWithFormat:@"Lv %d", m_nLevel]];
    [fontLevel setVisible:YES];
    
    // AT初期化
    m_nAT = 0;
    
    // HPを初期化する
    [self initHp];
    
}

/**
 * HPを初期化する
 */
- (void)initHp {
    
    // TODO:
    m_HpMax = 100 + m_nLevel * 10;
    m_Hp = m_HpMax;
    
    // TODO:
//    m_Hp *= 0.1;
    
    // HPゲージ設定
//    HpGauge* hpGauge = [self _getGauge];
//    [hpGauge initHp:[self getHpRatio]];
    
    // ATゲージ設定
    AtGauge* atGauge = [self _getAtGauge];
    [atGauge initAt:[self getAtRatio]];
    
    // 描画座標を設定
//    [hpGauge setPos:320-32-80 y:480-128];
    [atGauge setPos:320-32-80 y:480-128];
    [self.m_pSprite setScale:0.5];
    [self _setFont];
    
    // 出現演出開始
    m_State = eState_Appear;
    m_Timer = TIMER_APPEAR;
}

/**
 * 現在HPの割合を取得する
 */
- (float)getHpRatio {
    return 1.0 * m_Hp / m_HpMax;
}

/**
 * HPの増加
 */
- (void)addHp:(int)v {
    
    // HPを増やす
    m_Hp += v;
    if (m_Hp > m_HpMax) {
        m_Hp = m_HpMax;
    }
//    HpGauge* hpGauge = [self _getGauge];
//    [hpGauge initHp:[self getHpRatio]];
    [self _setFont];
}

/**
 * ダメージを与える
 */
- (void)damage:(int)v {
    
    m_Hp -= v;
    if (m_Hp < 0) {
        m_Hp = 0;
    }
    
//    HpGauge* hpGauge = [self _getGauge];
//    [hpGauge setHp:[self getHpRatio]];
    [self _setFont];
    
    // ダメージ演出開始
    m_tDamage = TIMER_DAMAGE;
    
    if (v > 0) {
        // ダメージ数値表示
        [FontEffect add:eFontEffect_Damage x:ENEMY_POS_X y:ENEMY_POS_DAMAGE text:[NSString stringWithFormat:@"%d", v]];
    }
    
    // TODO: ATゲージを減らす
    m_nAT -= 20;
    if (m_nAT < 0) {
        m_nAT = 0;
    }
    
    AtGauge* atGauge = [self _getAtGauge];
    [atGauge damageAt:[self getAtRatio]];
    
    // ダメージエフェクト再生
    [Particle addDamage:ENEMY_POS_X y:ENEMY_POS_Y];
    
}

/**
 * 危険状態かどうか
 */
- (BOOL)isDanger {
    
    return [self getHpRatio] < 0.3f;
}

/**
 * 死亡したかどうか
 */
- (BOOL)isDead {
    return m_Hp <= 0;
}

// 死亡
- (void)destroy {
    
    [self setVisible:NO];
    
    // レベル表示を消す
    AsciiFont* fontLevel = [self _getFontLevel];
    [fontLevel setVisible:NO];
    
    // 死亡エフェクト生成
    [Particle addDead:ENEMY_POS_X y:ENEMY_POS_Y];
}

/**
 * ターン経過
 */
- (void)doTurn {
    
    // アクティブタイムゲージを増やす
    m_nAT += m_dAT;
    if (m_nAT > AT_MAX) {
        
        m_nAT = AT_MAX;
    }
    
    AtGauge* gauge = [self _getAtGauge];
    [gauge setAt:[self getAtRatio]];
}

/**
 * ターン終了
 */
- (void)endTurn {
    
    m_nAT = 0;
    AtGauge* gauge = [self _getAtGauge];
    [gauge initAt:0];
}

/**
 * 攻撃可能かどうか
 */
- (BOOL)isAttack {
    
    return m_nAT >= AT_MAX;
}

/**
 * 攻撃を実行する
 */
- (void)doAttack {
    
    MainCtrl* ctrl = [self _getCtrl];
    
    // TODO
    int cnt = Math_Rand(m_nLevel) + 1;
    
    ReqBlock req;
    if (cnt < 10) {
        
        // シールド付きブロック
        req.setUpperShield(cnt);
    }
    else {
        
        // 通常ブロック
        req.setUpper(cnt);
    }
    
    if (Math_Rand(1) == 0) {
        
        // ドクロブロック
        req.setUpperSkull(cnt);
    }
    
    // 下から出現
    cnt = Math_Rand(3) + 1;
//    req.setBottom(cnt);
    
    [ctrl reqestBlock:req];
}

/**
 * ATゲージの割合を取得する
 */
- (float)getAtRatio {
    
    return 1.0 * m_nAT / AT_MAX;
}

@end
