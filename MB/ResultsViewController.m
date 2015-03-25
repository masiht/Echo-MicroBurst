//
//  ResultsViewController.m
//  MB
//
//  Created by Masih Tabrizi on 3/25/15.
//  Copyright (c) 2015 Masih. All rights reserved.
//

#import "ResultsViewController.h"

@interface ResultsViewController ()

@end

@implementation ResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background"]];
    NSLog(@"%@", _speed);
}

- (void)viewWillAppear:(BOOL)animated {
    self.downloadLabel.text = [NSString stringWithFormat:@"%.2f MB/s", [_speed doubleValue] / 1000000.0];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
