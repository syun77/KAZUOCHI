//
//  SceneMain.mm
//  Connect_X_Connect
//
//  Created by OzekiSyunsuke on 12/05/28.
//  Copyright 2012年 2dgame.jp. All rights reserved.
//

#import "SceneMain.h"
#import "FieldMgr.h"
#import "BlockMgr.h"

/**
 * 描画プライオリティ
 */
enum ePrio {
    ePrio_Back,         // 背景
    ePrio_Grid,         // グリッド線
    ePrio_Block,        // ブロック
    ePrio_Number,       // ブロックの数字
    ePrio_Cursor,       // カーソル
    ePrio_Player,       // プレイヤー
    ePrio_Enemy,        // 敵
    ePrio_RedBar,       // 危険バー
    ePrio_BlockNext,    // 次に出現するブロック
    ePrio_Effect,       // エフェクト
    ePrio_HpGauge,      // HPゲージ
    ePrio_UI,           // ユーザインターフェース
};

enum eState {
    eState_Init,
    eState_Main,
    eState_End,
};

// シングルトン
static SceneMain* scene_ = nil;

@implementation SceneMain

@synthesize interfaceLayer;
@synthesize baseLayer;

@synthesize fontGameover;
@synthesize fontLevelup;
@synthesize fontLevel;
@synthesize fontNextBlock1;
@synthesize fontNextBlock2;
@synthesize fontNextBlock3;

@synthesize fontTest;
@synthesize fontTest2;
@synthesize fontTest3;

@synthesize mgrBlock;
@synthesize mgrBezierEffect;
@synthesize mgrFontEffect;
@synthesize mgrParticle;

@synthesize cursor;
@synthesize grid;
@synthesize hpGauge;
@synthesize hpGaugeEnemy;
@synthesize player;
@synthesize enemy;
@synthesize back;
@synthesize chain;
@synthesize redbar;
@synthesize blockNext1;
@synthesize blockNext2;
@synthesize blockNext3;

@synthesize layer;
@synthesize ctrl;


/**
 * シングルトンを取得する
 */
+ (SceneMain*)sharedInstance {
    if (scene_ == nil) {
        scene_ = [SceneMain node];
    }
    
    return scene_;
}

/**
 * インスタンスを解放する
 */
+ (void)releaseInstance {
    scene_ = nil;
}

/**
 * コンストラクタ
 */
- (id)init {
    
    self = [super init];
    if (self == nil) {
        return self;
    }
    
    // 基準レイヤー
    self.baseLayer = [CCLayer node];
    [self addChild:self.baseLayer];
    
    // 入力受け取り
    self.interfaceLayer = [InterfaceLayer node];
    [self.baseLayer addChild:self.interfaceLayer];
    
    // 描画関連
    
    self.fontTest = [AsciiFont node];
    [self.fontTest createFont:self.baseLayer length:24];
    [self.fontTest setScale:3];
    [self.fontTest setPos:5 y:16];
    [self.fontTest setVisible:NO];
    
    self.fontTest2 = [AsciiFont node];
    [self.fontTest2 createFont:self.baseLayer length:24];
    [self.fontTest2 setScale:3];
    [self.fontTest2 setPos:5 y:13];
    [self.fontTest2 setVisible:NO];
    
    self.fontTest3 = [AsciiFont node];
    [self.fontTest3 createFont:self.baseLayer length:24];
    [self.fontTest3 setScale:3];
    [self.fontTest3 setPos:5 y:10];
    [self.fontTest3 setVisible:NO];
    
    self.fontGameover = [AsciiFont node];
    [self.fontGameover createFont:self.baseLayer length:24];
    [self.fontGameover setScale:3];
    [self.fontGameover setPos:18 y:3];
    [self.fontGameover setAlign:eFontAlign_Center];
    [self.fontGameover setText:@"GAME OVER"];
    [self.fontGameover setVisible:NO];
    
    self.fontLevelup = [AsciiFont node];
    [self.fontLevelup createFont:self.baseLayer length:24];
    [self.fontLevelup setScale:3];
    [self.fontLevelup setPos:20 y:36];
    [self.fontLevelup setAlign:eFontAlign_Center];
    [self.fontLevelup setText:@"Level up"];
    [self.fontLevelup setVisible:NO];
    
    self.fontLevel = [AsciiFont node];
    [self.fontLevel createFont:self.baseLayer length:24];
    [self.fontLevel setScale:2];
    [self.fontLevel setPos:24 y:36];
    [self.fontLevel setAlign:eFontAlign_Center];
    [self.fontLevel setText:@"Lv"];
    [self.fontLevel setVisible:NO];
    
    self.fontNextBlock1 = [AsciiFont node];
    [self.fontNextBlock1 createFont:self.baseLayer length:2];
    [self.fontNextBlock1 setScale:3];
    [self.fontNextBlock1 setPos:20 y:43];
    [self.fontNextBlock1 setAlign:eFontAlign_Center];
    [self.fontNextBlock1 setText:@""];
    [self.fontNextBlock1 setVisible:NO];
    
    self.fontNextBlock2 = [AsciiFont node];
    [self.fontNextBlock2 createFont:self.baseLayer length:2];
    [self.fontNextBlock2 setScale:2];
    [self.fontNextBlock2 setPos:20 y:46];
    [self.fontNextBlock2 setAlign:eFontAlign_Center];
    [self.fontNextBlock2 setText:@""];
    [self.fontNextBlock2 setVisible:NO];
    
    self.fontNextBlock3 = [AsciiFont node];
    [self.fontNextBlock3 createFont:self.baseLayer length:2];
    [self.fontNextBlock3 setScale:1];
    [self.fontNextBlock3 setPos:20 y:48];
    [self.fontNextBlock3 setAlign:eFontAlign_Center];
    [self.fontNextBlock3 setText:@""];
    [self.fontNextBlock3 setVisible:NO];
    
    self.mgrBlock = [TokenManager node];
    [self.mgrBlock setPrio:ePrio_Block];
    [self.mgrBlock create:self.baseLayer size:FIELD_BLOCK_COUNT_X*(FIELD_BLOCK_COUNT_Y+2) className:@"Block"];
    
    self.mgrBezierEffect = [TokenManager node];
    [self.mgrBezierEffect setPrio:ePrio_Effect];
    [self.mgrBezierEffect create:self.baseLayer size:512 className:@"BezierEffect"];
    
    self.mgrFontEffect = [TokenManager node];
    [self.mgrFontEffect setPrio:ePrio_Effect];
    [self.mgrFontEffect create:self.baseLayer size:16 className:@"FontEffect"];
    
    self.mgrParticle = [TokenManager node];
    [self.mgrParticle setPrio:ePrio_Effect];
    [self.mgrParticle create:self.baseLayer size:512 className:@"Particle"];
    
    self.cursor = [Cursor node];
    [self.baseLayer addChild:self.cursor z:ePrio_Cursor];
    [self.cursor setDraw:NO chipX:3];
    
    self.grid = [Grid node];
    [self.baseLayer addChild:self.grid z:ePrio_Grid];
    
    self.hpGauge = [HpGauge node];
    [self.baseLayer addChild:self.hpGauge z:ePrio_HpGauge];
    
    self.hpGaugeEnemy = [HpGauge node];
    [self.baseLayer addChild:self.hpGaugeEnemy z:ePrio_HpGauge];
    
    self.player = [Player node];
    [self.baseLayer addChild:self.player z:ePrio_Player];
    
    self.enemy = [Enemy node];
    [self.baseLayer addChild:self.enemy z:ePrio_Enemy];
    
    self.back = [Back node];
    [self.baseLayer addChild:self.back z:ePrio_Back];
    
    self.chain = [Chain node];
    [self.baseLayer addChild:self.chain z:ePrio_UI];
    [self.chain attachLayer:self.baseLayer];
    
    self.redbar = [RedBar node];
    [self.baseLayer addChild:self.redbar z:ePrio_RedBar];
    
    self.blockNext1 = [BlockNext node];
    [self.baseLayer addChild:self.blockNext1 z:ePrio_BlockNext];
    
    self.blockNext2 = [BlockNext node];
    [self.baseLayer addChild:self.blockNext2 z:ePrio_BlockNext];
    
    self.blockNext3 = [BlockNext node];
    [self.baseLayer addChild:self.blockNext3 z:ePrio_BlockNext];
    
    // レイヤー
    [[self.layer = [Layer2D alloc] init] autorelease];
    [self.layer create:FIELD_BLOCK_COUNT_X h:FIELD_BLOCK_COUNT_Y];
    
    // ゲーム制御
    self.ctrl = [MainCtrl node];
    [self.interfaceLayer addCB:self.ctrl];
    
    // 変数初期化
    m_State = eState_Init;
    m_Timer = 0;
    
    
    // ■更新開始
    [self scheduleUpdate];
    
    return self;
}

/**
 * デストラクタ
 */
- (void)dealloc {
    
    // コールバックから削除
    [self.interfaceLayer delCB];
    
    // ゲーム制御
    self.ctrl = nil;
    
    self.blockNext3 = nil;
    self.blockNext2 = nil;
    self.blockNext1 = nil;
    self.redbar = nil;
    self.chain = nil;
    self.back = nil;
    self.enemy = nil;
    self.player = nil;
    self.hpGaugeEnemy = nil;
    self.hpGauge = nil;
    
    self.grid = nil;
    self.cursor = nil;
    
    // レイヤー
    self.layer = nil;
    
    // ■描画オブジェクト
    // トークン
    self.mgrParticle = nil;
    self.mgrFontEffect = nil;
    self.mgrBezierEffect = nil;
    self.mgrBlock = nil;
    
    // フォント
    self.fontNextBlock3 = nil;
    self.fontNextBlock2 = nil;
    self.fontNextBlock1 = nil;
    self.fontLevel = nil;
    self.fontLevelup = nil;
    self.fontGameover = nil;
    self.fontTest = nil;
    
    self.interfaceLayer = nil;
    
    self.baseLayer = nil;
    
    [super dealloc];
}

- (void)update:(ccTime)dt {
    
    switch (m_State) {
        case eState_Init:
            m_State = eState_Main;
            break;
            
        case eState_Main:
            
            [self.ctrl update:dt];
            if ([self.ctrl isEnd]) {
                m_State = eState_End;
            }
            
        case eState_End:
            break;
            
        default:
            break;
    }
    
    //[self.fontTest setText:[NSString stringWithFormat:@"%d", s_cnt]];
    //[self.fontTest2 setText:[NSString stringWithFormat:@"%06d", s_cnt]];
    //[self.fontTest3 setText:[NSString stringWithFormat:@"%09d", s_cnt]];
    
}

@end
