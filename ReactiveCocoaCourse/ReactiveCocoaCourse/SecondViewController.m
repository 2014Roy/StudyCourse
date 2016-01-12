//
//  SecondViewController.m
//  ReactiveCocoaCourse
//
//  Created by Zonyet on 16/1/4.
//  Copyright © 2016年 Zonyet. All rights reserved.
//

/*
在本系列教程的第二部分，你将会学到一些ReactiveCocoa的高级功能，包括：

另外两个事件类型：error 和 completed
节流
线程
延伸
其他
*/
#import "SecondViewController.h"
#import <ReactiveCocoa.h>


@implementation SecondViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [[self requestAccessToTwitterSignal] subscribeNext:^(id x) {
        
    } error:^(NSError *error) {
        NSLog(@"An error occurred: %@", error);
    }];
    
    //更换下面代码
    @weakify(self)
    [[[self requestAccessToTwitterSignal]
      then:^RACSignal *{
          @strongify(self)
          return /*self.searchText.rac_textSignal*/nil;
      }]
     subscribeNext:^(id x) {
         NSLog(@"%@", x);
     } error:^(NSError *error) {
         NSLog(@"An error occurred: %@", error);
     }];
    //then方法会等待completed事件的发送，然后再订阅由then block返回的signal。这样就高效地把控制权从一个signal传递给下一个。
    //then方法会跳过error事件，因此最终的subscribeNext:error:  block还是会收到获取访问权限那一步发送的error事件。
    
    
    //接下来，在管道中添加一个filter操作来过滤掉无效的输入。在本例里就是长度不够3个字符的字符串：
    [[[[self requestAccessToTwitterSignal]
       then:^RACSignal *{
           @strongify(self)
           return /*self.searchText.rac_textSignal*/nil;
       }]
      filter:^BOOL(NSString *text) {
          @strongify(self)
          return YES;
      }]
     subscribeNext:^(id x) {
         NSLog(@"%@", x);
     } error:^(NSError *error) {
         NSLog(@"An error occurred: %@", error);
     }];
    
    
    //线程
    //所以接下来你要怎么更新UI呢？通常的做法是使用操作队列（参见教程如何使用 NSOperations 和 NSOperationQueues）。但是ReactiveCocoa有更简单的解决办法。
    
    
    
    //像下面的代码一样，在flattenMap：之后添加一个deliverOn：操作：
    /*
    [[[[[[self requestAccessToTwitterSignal]
         then:^RACSignal *{
             @strongify(self)
             return self.searchText.rac_textSignal;
         }]
        filter:^BOOL(NSString *text) {
            @strongify(self)
            return [self isValidSearchText:text];
        }]
       flattenMap:^RACStream *(NSString *text) {
           @strongify(self)
           return [self signalForSearchWithText:text];
       }]
      deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(id x) {
         NSLog(@"%@", x);
     } error:^(NSError *error) {
         NSLog(@"An error occurred: %@", error);
     }];
     */
    
    
    //搜索 数据 节流
    //你可能注意到了，每次输入一个字，搜索Twitter都会马上执行。如果你输入很快（或者只是一直按着删除键），这可能会造成应用在一秒内执行好几次搜索。这很不理想，原因如下：首先，多次调用Twitter搜索API，但大部分返回结果都没有用。其次，不停地更新界面会让用户分心。
    //更好的解决方法是，当搜索文本在短时间内，比如说500毫秒，不再变化时，再执行搜索。
    //在filter之后添加一个throttle步骤：
    /*
    [[[[[[[self requestAccessToTwitterSignal]
          then:^RACSignal *{
              @strongify(self)
              return self.searchText.rac_textSignal;
          }]
         filter:^BOOL(NSString *text) {
             @strongify(self)
             return [self isValidSearchText:text];
         }]
        throttle:0.5]
       flattenMap:^RACStream *(NSString *text) {
           @strongify(self)
           return [self signalForSearchWithText:text];
       }]
      deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(NSDictionary *jsonSearchResult) {
         NSArray *statuses = jsonSearchResult[@"statuses"];
         NSArray *tweets = [statuses linq_select:^id(id tweet) {
             return [RWTweet tweetWithStatus:tweet];
         }];
         [self.resultsViewController displayTweets:tweets];
     } error:^(NSError *error) {
         NSLog(@"An error occurred: %@", error);
     }];
     */
}


- (RACSignal *)requestAccessToTwitterSignal {
    /*
    // 1 - define an error
    NSError *accessError = [NSError errorWithDomain:RWTwitterInstantDomain
                                               code:RWTwitterInstantErrorAccessDenied
                                           userInfo:nil];
    
    // 2 - create the signal
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id subscriber) {
        // 3 - request access to twitter
        @strongify(self)
        [self.accountStore requestAccessToAccountsWithType:self.twitterAccountType
                                                   options:nil
                                                completion:^(BOOL granted, NSError *error) {
                                                    // 4 - handle the response
                                                    if (!granted) {
                                                        [subscriber sendError:accessError];
                                                    } else {
                                                        [subscriber sendNext:nil];
                                                        [subscriber sendCompleted]; 
                                                    } 
                                                }]; 
        return nil; 
    }]; 
     */
    
    return nil;
}

-(RACSignal *)signalForLoadingImage:(NSString *)imageUrl {
    RACScheduler *scheduler = [RACScheduler
                               schedulerWithPriority:RACSchedulerPriorityBackground];
    
    return [[RACSignal createSignal:^RACDisposable *(id subscriber) {
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        UIImage *image = [UIImage imageWithData:data];
        [subscriber sendNext:image];
        [subscriber sendCompleted];
        return nil;
    }] subscribeOn:scheduler];
}
@end
