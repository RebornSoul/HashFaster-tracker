//
//  SCDashboardVC.m
//  HashFaster tracker
//
//  Created by Yury Nechaev on 05.02.14.
//  Copyright (c) 2014 Slowpoke Codemasters. All rights reserved.
//

#import "SCDashboardVC.h"
#import "PoolItem.h"
#import "SCMPOSAPI.h"
#import "BlockCount.h"

@interface SCDashboardVC ()
@property (nonatomic, strong) PoolItem *currentPoolItem;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UILabel *currentBlockLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *userHashrateIndicator;
@property (nonatomic, strong) IBOutlet UILabel *userHashrateLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *networkIndicator;
@property (nonatomic, strong) IBOutlet UILabel *confirmedBalanceLabel;
@property (nonatomic, strong) IBOutlet UILabel *unconfirmedBalanceLabel;
@property (nonatomic, strong) IBOutlet UILabel *orphanedBalanceLabel;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *balanceIndicator;

@end

@implementation SCDashboardVC

- (id) initWithPoolItem:(PoolItem*)pool {
    self = [super init];
    if (self) {
        self.currentPoolItem = pool;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateData];
    UIBarButtonItem *updateButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateData)];
    [self.navigationItem setRightBarButtonItem:updateButton];
    // Do any additional setup after loading the view from its nib.
}

- (void) updateData {
    [self updateNetworkState];
    [self updateUserBalance];
    [self updateUserHashrate];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width, 10000.0f)];
    [self.scrollView setScrollEnabled:YES];
}

- (void) updateUserBalance {
    [self.balanceIndicator startAnimating];
    [SCMPOSAPI getUserBalance:self.currentPoolItem success:^(id responseObject) {
        NSDictionary *data = [responseObject valueForKey:@"data"];
        [self.confirmedBalanceLabel setText:[NSString stringWithFormat:@"Confirmed: %@",[[data valueForKey:@"confirmed"] stringValue]]];
        [self.unconfirmedBalanceLabel setText:[NSString stringWithFormat:@"Unconfirmed: %@",[[data valueForKey:@"unconfirmed"] stringValue]]];
        [self.orphanedBalanceLabel setText:[NSString stringWithFormat:@"Orphaned: %@",[[data valueForKey:@"orphaned"] stringValue]]];
        [self.balanceIndicator stopAnimating];
    } failure:^(NSError *error) {
        [self.balanceIndicator stopAnimating];
    }];
}

- (void) updateUserHashrate {
    [self.userHashrateIndicator startAnimating];
    [SCMPOSAPI getUserHashrate:self.currentPoolItem success:^(id responseObject) {
        [self.userHashrateLabel setText:[NSString stringWithFormat:@"Current hashrate: %@", [[responseObject valueForKey:@"data"] stringValue]]];
        [self.userHashrateIndicator stopAnimating];
    } failure:^(NSError *error) {
        [self.userHashrateIndicator stopAnimating];
    }];
}

- (void) updateNetworkState {
    [self.networkIndicator startAnimating];
    [SCMPOSAPI getBlockCount:self.currentPoolItem success:^(id responseObject) {
        [self.currentBlockLabel setText:[NSString stringWithFormat:@"Current block: %i", [[responseObject valueForKey:@"data"] integerValue]]];
        [self.networkIndicator stopAnimating];
    } failure:^(NSError *error) {
        [self.networkIndicator stopAnimating];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
