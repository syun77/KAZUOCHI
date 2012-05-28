//
//  Layer2D.h
//  Connect_X_Connect
//
//  Created by OzekiSyunsuke on 12/05/28.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

/**
 * ２次元配列管理クラス
 */
@interface Layer2D : NSObject {
@private
    int                     m_Out;      // 領域外の値
    int                     m_Default;  // 初期値
    int                     m_Width;    // 幅
    int                     m_Height;   // 高さ
    NSMutableDictionary*    m_Data;     // データ
}

@property (readonly)int width;
@property (readonly)int height;

// 生成
- (void)create:(int)w h:(int)h;

// 破棄
//- (void)destroy;

// コピー
- (void)copyWithLayer2D:(Layer2D*)layer;

// 値が設定されているかどうか
- (BOOL)has:(int)x y:(int)y;

// インデックスに変換する
- (int)getIdx:(int)x y:(int)y;

// 領域内かどうか
- (BOOL)isRange:(int)x y:(int)y;

// 領域内かどうか (インデックス指定)
- (BOOL)isRangeFromIdx:(int)idx;

// 値の設定
- (void)set:(int)x y:(int)y val:(int)val;

// 値の設定 (インデックス指定)
- (void)setFromIdx:(int)idx val:(int)val;

// 値の取得
- (int)get:(int)x y:(int)y;

// 初期値を取得する
- (int)getDefault;

// 領域外の値を取得する
- (int)getOut;

// ディクショナリを取得する (コピー用)
- (NSDictionary*)getData;

// デバッグ出力
- (void)dump;

@end
