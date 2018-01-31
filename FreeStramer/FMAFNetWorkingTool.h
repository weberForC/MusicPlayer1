//
//  FMAFNetWorkingTool.h
//  LuNu1
//
//  Created by flg on 15/11/24.
//  Copyright © 2015年 flg. All rights reserved.
//

#import <Foundation/Foundation.h>

// 返回值的数据类型枚举
typedef enum : NSUInteger {
    FMData,
    FMJSON,
    FMXML,
} FMResult;

// 网络请求Body的类型枚举
typedef enum : NSUInteger {
    FMRequestJSON,
    FMRequestString,
} FMRequestStyle;

@interface FMAFNetWorkingTool : NSObject
/**
 *  Get请求
 *
 *  @param url        网络请求地址
 *  @param body       请求体
 *  @param result     返回值的数据类型
 *  @param headerFile 请求头
 *  @param success    网络请求成功回调覅
 *  @param failure    网络请求失败回调
 */
+ (void)getUrl:(NSString *)url
          body:(id)body
        result:(FMResult)result
    headerFile:(NSDictionary *)headerFile
       success:(void (^)(id result))success
       failure:(void (^)(NSError *error))failure;

/**
 *  post请求
 *
 *  @param url          网络请求地址
 *  @param body         请求体
 *  @param result       返回值数据类型
 *  @param requestStyle 网络请求Body的类型
 *  @param headerFile   网络请求头
 *  @param success      成功回调
 *  @param failure      失败回调
 */
+(void)postUrl:(NSString *)url
          body:(id)body
        result:(FMResult)result
  requsetStyle:(FMRequestStyle)requestStyle
    headerFile:(NSDictionary *)headerFile
       success:(void (^)(id result))success
       failure:(void (^)(NSError *error))failure;
@end
