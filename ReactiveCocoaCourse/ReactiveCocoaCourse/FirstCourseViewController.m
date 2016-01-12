//
//  FirstCourseViewController.m
//  ReactiveCocoaCourse
//
//  Created by Zonyet on 16/1/4.
//  Copyright © 2016年 Zonyet. All rights reserved.
//http://benbeng.leanote.com/post/ReactiveCocoaTutorial-part1

#import "FirstCourseViewController.h"
#import <ReactiveCocoa.h>

@implementation FirstCourseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"First Course";
//    [self.nameTextField.rac_textSignal subscribeNext:^(id x) {
//        NSLog(@"subscribe %@", x);
//    }];
    
//    [[self.nameTextField.rac_textSignal filter:^BOOL(id value) {
//        NSString *text = value;
//        return text.length > 4;
//    }] subscribeNext:^(id x) {
//        NSLog(@"subscribe %@", x);
//    }];
    
    //map操作通过block改变了事件的数据
    [[[self.nameTextField.rac_textSignal map:^id(NSString *text) {
        return @(text.length);
    }] filter:^BOOL(NSNumber *number) {
        return [number integerValue] > 4;
    }] subscribeNext:^(id x) {
        NSLog(@"subscribe %@", x);
    }];
    
    //进一步转换跟踪信号
    RACSignal *validUserNameSingle = [self.nameTextField.rac_textSignal map:^id(NSString *text) {
        return @(text.length);
    }];
    RACSignal *validPassWordSingle = [self.passwordTextField.rac_textSignal map:^id(NSString *text) {
        return @(text.length);
    }];
    
//    [[validUserNameSingle map:^id(NSNumber *number) {
//        return [number boolValue]?[UIColor clearColor]:[UIColor greenColor];
//    }] subscribeNext:^(id x) {
//        UIColor *color = (UIColor *)x;
//        self.nameTextField.backgroundColor = color;
//    }];
    
    //推荐更好的用法
    RAC(self.nameTextField, backgroundColor) = [validUserNameSingle map:^id(NSNumber *number) {
        return [number boolValue]?[UIColor greenColor]:[UIColor clearColor];
    }];
    RAC(self.passwordTextField, backgroundColor) = [validPassWordSingle map:^id(NSNumber *number) {
        return [number boolValue]?[UIColor greenColor]:[UIColor clearColor];
    }];
    
    //聚合信号 （把2个信号合并 每个信号有变化 block 都会执行）
    RACSignal *singUpSingle = [RACSignal combineLatest:@[validPassWordSingle, validPassWordSingle] reduce:^id(NSNumber *validName, NSNumber *validPassword){
        return @([validName boolValue] && [validPassword boolValue]);
    }];
    
    @weakify(self)
    [singUpSingle subscribeNext:^(NSNumber * number) {
        @strongify(self)
        self.singUpButton.enabled = [number boolValue];
    }];
    
    
    //添加按钮方法事件
    [[self.singUpButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSLog(@" login ....");
    }];
    
    
    //创建信号
   // 幸运的是，把已有的异步API用信号的方式来表示相当简单。首先把RWViewController.m中的signInButtonTouched:删掉。你会用响应式的的方法来替换这段逻辑。
    
    //点击事件和登陆流程连接起来。。。。
    [[[self.singUpButton rac_signalForControlEvents:UIControlEventTouchUpInside] map:^id(id value) {
        return [self signInSignal];
    }] subscribeNext:^(id x) {
//        NSLog(@"x___%@", x);
    }];
    //上面问题的解决方法，有时候叫做信号中的信号，换句话说就是一个外部信号里面还有一个内部信号。你可以在外部信号的subscribeNext:block里订阅内部信号。不过这样嵌套太混乱啦，还好ReactiveCocoa已经解决了这个问题。
    //上面更好的处理方法  //关键是subscribe 订阅了 谁。。。。。《上面的订阅了 点击事件返回的map 事件  flattenMap订阅的是生产的RacSingle 的内部信号》
    [[[self.singUpButton rac_signalForControlEvents:UIControlEventTouchUpInside]  flattenMap:^RACStream *(id value) {
        return [self signInSignal];
    }] subscribeNext:^(id x) {
        NSLog(@"x___%@", x);
    }];
    
    
    
    //你注意到这个应用现在有一些用户体验上的小问题了吗？当登录service正在校验用户名和密码时，登录按钮应该是不可点击的。这会防止用户多次执行登录操作。还有，如果登录失败了，用户再次尝试登录时，应该隐藏错误信息
    //这个逻辑应该怎么添加呢？改变按钮的可用状态并不是转换（map）、过滤（filter）或者其他已经学过的概念。其实这个就叫做“副作用”，换句话说就是在一个next事件发生时执行的逻辑，而该逻辑并不改变事件本身。
    
    //添加附加操作（Adding side-effects）
    [[[[self.singUpButton rac_signalForControlEvents:UIControlEventTouchUpInside] doNext:^(id x) {
        self.singUpButton.enabled = NO;
    }] flattenMap:^RACStream *(id value) {
        return [self signInSignal];
    }] subscribeNext:^(NSNumber *success) {
        self.singUpButton.enabled = YES;
        if ([success boolValue]) {
            //登陆成功。跳转
            [self performSegueWithIdentifier:@"firstDetail" sender:self];
        }
    }];
}




- (RACSignal *)signInSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber){
        [subscriber sendNext:[NSNumber numberWithBool:YES]];
        [subscriber sendCompleted];
//        [self.signInService
//         signInWithUsername:self.usernameTextField.text
//         password:self.passwordTextField.text
//         complete:^(BOOL success){
//             [subscriber sendNext:@(success)];
//             [subscriber sendCompleted];
//         }];
        return nil;
    }];
}
@end
