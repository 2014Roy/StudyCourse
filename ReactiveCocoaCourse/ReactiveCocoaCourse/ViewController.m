//
//  ViewController.m
//  ReactiveCocoaCourse
//
//  Created by Zonyet on 15/10/29.
//  Copyright © 2015年 Zonyet. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Course";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"first" sender:self];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray().count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    cell.textLabel.text = dataArray()[indexPath.row];
    
    return cell;
}

#pragma mark - c
static NSArray* dataArray() {
    static NSArray *array = nil;
    @synchronized(array) {
        array = @[@"First Course", @"Second Course", @"Third Course"];
    }
    
    return array;
}
@end
