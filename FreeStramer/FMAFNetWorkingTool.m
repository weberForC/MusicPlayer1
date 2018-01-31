//
//  FMAFNetWorkingTool.m
//  LuNu1
//
//  Created by flg on 15/11/24.
//  Copyright © 2015年 flg. All rights reserved.
//

#import "FMAFNetWorkingTool.h"
#import <AFNetworking.h>

@implementation FMAFNetWorkingTool

+(void)getUrl:(NSString *)url
         body:(id)body
       result:(FMResult)result
   headerFile:(NSDictionary *)headerFile
      success:(void (^)(id result))success
      failure:(void (^)(NSError *error))failure{
    
    //0.判断网络状况
    AFNetworkReachabilityManager *netManager = [AFNetworkReachabilityManager sharedManager];
    [netManager startMonitoring];  //开始监听
    [netManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
        if (status == AFNetworkReachabilityStatusNotReachable)
        {
            //NSLog(@"没有网络");
            failure(nil);
            return ;
        }else if (status == AFNetworkReachabilityStatusUnknown){
            
            //NSLog(@"未知网络");
            
        }else if (status == AFNetworkReachabilityStatusReachableViaWWAN){
            
            //NSLog(@"WiFi");
            
        }else if (status == AFNetworkReachabilityStatusReachableViaWiFi){
            
            //NSLog(@"手机网络");
            
        }
    }];
    
    //1.获取网络请求管理类
    // 使用这个方法会产生内存泄露，改用单利创建，可以避免
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
    
    ///给网址添加头///可能会用到
    //3.对网络请求加请求头
    if (headerFile) {
        for (NSString *key in headerFile.allKeys) {
            [manager.requestSerializer setValue:headerFile[key] forHTTPHeaderField:key];
        }
    }
    //4.网络请求返回值的类型
    switch (result) {
        case FMData:
            ///返回NSData
            manager.responseSerializer=[AFHTTPResponseSerializer serializer];
            break;
        case FMJSON:
            ///返回JSON类型
            manager.responseSerializer=[AFJSONResponseSerializer serializer];
            break;
        case FMXML:
            ///返回XML数据
            manager.responseSerializer=[AFXMLParserResponseSerializer serializer];
            break;
        default:
            break;
    }
    //2.设置网络请求返回值支持类型
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/css",@"text/plain", nil]];
    
    //5.发送网络请求
    [manager GET:url parameters:body progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            failure(error);
        }
    }];
}

+(void)postUrl:(NSString *)url
          body:(id)body
        result:(FMResult)result
  requsetStyle:(FMRequestStyle)requestStyle
    headerFile:(NSDictionary *)headerFile
       success:(void (^)(id result))success
       failure:(void (^)(NSError *error))failure{
    
    //0.判断网络状况
    AFNetworkReachabilityManager *netManager = [AFNetworkReachabilityManager sharedManager];
    [netManager startMonitoring];  //开始监听
    [netManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
        if (status == AFNetworkReachabilityStatusNotReachable)
        {
            //NSLog(@"没有网络");
            failure(nil);
            return ;
        }else if (status == AFNetworkReachabilityStatusUnknown){
            
            //NSLog(@"未知网络");
            
        }else if (status == AFNetworkReachabilityStatusReachableViaWWAN){
            
            //NSLog(@"WiFi");
            
        }else if (status == AFNetworkReachabilityStatusReachableViaWiFi){
            
            //NSLog(@"手机网络");
            
        }
    }];
    
    //1.获取网络请求管理类
    // 使用这个方法会产生内存泄露，改用单利创建，可以避免
    AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];

    //3.发送数据类型
    switch (requestStyle) {
        case FMRequestJSON:
            ///返回NSData
            manager.responseSerializer=[AFJSONResponseSerializer serializer];
            break;
        case FMRequestString:
            [manager.requestSerializer setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request, id parameters, NSError *__autoreleasing *error) {
                return parameters;
            }];
        default:
            break;
    }
    //4.给网络请求添加请求头///可能会用到
    if (headerFile) {
        for (NSString *key in headerFile.allKeys) {
            [manager.requestSerializer setValue:headerFile[key] forHTTPHeaderField:key];
        }
    }
    //5.网络请求返回值的类型
    switch (result) {
        case FMData:
            ///返回NSData
            manager.responseSerializer=[AFHTTPResponseSerializer serializer];
            break;
        case FMJSON:
            ///返回JSON类型
            manager.responseSerializer=[AFJSONResponseSerializer serializer];
            break;
        case FMXML:
            ///返回XML数据
            manager.responseSerializer=[AFXMLParserResponseSerializer serializer];
            break;
        default:
            break;
    }
    //2.设置网络请求返回值支持的参数类型
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/css",@"text/plain", nil]];
    //6.发送网络请求
    [manager POST:url parameters:body progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {
            //成功回调
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            //失败回调
            failure(error);
        }
    }];
}

@end
