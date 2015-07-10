//
//  FISGithubAPIClient.m
//  github-repo-list
//
//  Created by Joe Burgess on 5/5/14.
//  Copyright (c) 2014 Joe Burgess. All rights reserved.
//

#import "FISGithubAPIClient.h"
#import "FISConstants.h"
#import <AFNetworking.h>
#import "FISGithubRepository.h"
@implementation FISGithubAPIClient
NSString *const GITHUB_API_URL=@"https://api.github.com";

+(void)getRepositoriesWithCompletion:(void (^)(NSArray *))completionBlock
{
    NSString *githubURL = [NSString stringWithFormat:@"%@/repositories?client_id=%@&client_secret=%@",GITHUB_API_URL,GITHUB_CLIENT_ID,GITHUB_CLIENT_SECRET];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    [manager GET:githubURL parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        completionBlock(responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Fail: %@",error.localizedDescription);
    }];
}

+ (void)checkIfRepoIsStarredWithFullName:(NSString *)fullName CompletionBlock:(void (^)(BOOL starred))statusCode
{

    NSString *baseURL = @"https://api.github.com/user/starred/";
    NSString *ownerAndRepo = fullName;
    NSString *oAuthToken = @"?access_token=ded9a2b653fbf1aa66a02095fc533ae88080338d";
    NSURLSession *urlSession = [NSURLSession sharedSession];
    NSString *repoToCheck = [NSString stringWithFormat:@"%@%@%@",baseURL, ownerAndRepo, oAuthToken];
    NSURL *url = [NSURL URLWithString:repoToCheck];
    NSURLSessionDataTask *task = [urlSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *theResponse = (NSHTTPURLResponse *)response;
        
        if (theResponse.statusCode == 204) {
            statusCode(YES);
        } else
        {
            statusCode(NO);
        }
    }];

    [task resume];
    
}

+ (void)starRepoWithFullName:(NSString *)fullName CompletionBlock:(void (^)(BOOL starred))statusCode
{
    
    NSString *baseURL = @"https://api.github.com/user/starred/";
    NSString *ownerAndRepo = fullName;
    NSString *oAuthToken = @"?access_token=ded9a2b653fbf1aa66a02095fc533ae88080338d";
    NSURLSession *urlSession = [NSURLSession sharedSession];
    NSString *repoToCheck = [NSString stringWithFormat:@"%@%@%@",baseURL, ownerAndRepo, oAuthToken];
    NSURL *url = [NSURL URLWithString:repoToCheck];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"PUT";
    NSURLSessionDataTask *task = [urlSession dataTaskWithRequest:request
                                           completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                               
                                               NSHTTPURLResponse *theResponse = (NSHTTPURLResponse *)response;
                                               if (theResponse.statusCode == 204) {
                                                   statusCode(YES);
                                               } else if (theResponse.statusCode == 404)
                                               {
                                                   statusCode(NO);
                                               }
                                               
                                               
                                           }];

    
    [task resume];
    
}

+ (void)unstarRepoWithFullName:(NSString *)fullName CompletionBlock:(void (^)(BOOL unstarred))statusCode
{
    
    NSString *baseURL = @"https://api.github.com/user/starred/";
    NSString *ownerAndRepo = fullName;
    NSString *oAuthToken = @"?access_token=ded9a2b653fbf1aa66a02095fc533ae88080338d";
    NSURLSession *urlSession = [NSURLSession sharedSession];
    NSString *repoToCheck = [NSString stringWithFormat:@"%@%@%@",baseURL, ownerAndRepo, oAuthToken];
    NSURL *url = [NSURL URLWithString:repoToCheck];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"DELETE";
    NSURLSessionDataTask *task = [urlSession dataTaskWithRequest:request
                                               completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                   
                                                   NSHTTPURLResponse *theResponse = (NSHTTPURLResponse *)response;
                                                   
                                                   if (theResponse.statusCode == 204) {
                                                       statusCode(YES);
                                                   } else if (theResponse.statusCode == 404)
                                                   {
                                                       statusCode(NO);
                                                   }

                                                   
                                               }];
    
    
    [task resume];
    
}

+(void)toggleStarForRepository:(NSString *)fullName completion:(void (^)(BOOL))completionBlock
{
    [FISGithubAPIClient checkIfRepoIsStarredWithFullName:fullName CompletionBlock:^(BOOL starred) {
        if (starred) {
        [FISGithubAPIClient unstarRepoWithFullName:fullName CompletionBlock:^(BOOL unstarred) {
            completionBlock(NO);
        }];
        
        } else {
            [FISGithubAPIClient starRepoWithFullName:fullName CompletionBlock:^(BOOL starred) {
                completionBlock(YES);
            }];
        }
    }];
}


@end
