//
//  SCViewController.m
//  HashFaster tracker
//
//  Created by Yury Nechaev on 05.02.14.
//  Copyright (c) 2014 Slowpoke Codemasters. All rights reserved.
//

#import "SCViewController.h"
#import <CDZQRScanningViewController/CDZQRScanningViewController.h>
#import <AVFoundation/AVFoundation.h>
#import "NSString+filePath.h"
#import "PoolItem.h"
#import <MagicalRecord/CoreData+MagicalRecord.h>
#import "SCDashboardVC.h"
#import <CoreGraphics/CoreGraphics.h>

@interface SCViewController ()
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) AVAudioPlayer *player;
@end

@implementation SCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didPressQRCodeButton:)];
    [self.navigationItem setRightBarButtonItem:buttonItem];
    [self.navigationItem setTitle:@"Your pools"];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didPressQRCodeButton:(id)sender {
    NSError *error = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"cash-register" ofType:@"aac"];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    if (!self.player) self.player = [[AVAudioPlayer alloc] initWithData:fileData error:&error];
    [self.player setVolume:0.7f];
    [self.player prepareToPlay];
    CDZQRScanningViewController *scanVC = [[CDZQRScanningViewController alloc] init];
    UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:scanVC];
    [scanVC setResultBlock:^(NSString *scanResult){
        NSLog(@"%@", scanResult);
        [self dismissViewControllerAnimated:YES completion:^{
            [self refreshLocalData];
            [UIView animateWithDuration:0.3f animations:^{
                [self.tableView reloadData];
            }];
        }];
        NSMutableArray *components = [[scanResult componentsSeparatedByString:@"|"] mutableCopy];
        [components removeLastObject];
        [components removeObjectAtIndex:0];
        NSDictionary *infoParams = [self paramsFromQRArray:components];
        PoolItem *foundItem = [[PoolItem findAllWithPredicate:[NSPredicate predicateWithFormat:@"url == %@", [infoParams valueForKey:@"url"]]] firstObject];
        if ([self validateQRCodeArray:components]) {
            if (!foundItem) foundItem = [PoolItem createEntity];
            [foundItem setAddedDate:[NSDate date]];
            [foundItem setValuesForKeysWithDictionary:infoParams];
        }
        if (error) {
            NSLog(@"Failed to initialize a player: %@", error.localizedDescription);
        } else {
            [self.player play];
        }
    }];
    [self presentViewController:navC animated:YES completion:^{
        UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissQRCodePicker:)];
        [scanVC.navigationItem setLeftBarButtonItem:cancel];
        UIColor *color = [UIColor cyanColor];
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(scanVC.view.bounds, -40.0f, -40.0f) cornerRadius:20.0f];
        [color setStroke];
        bezierPath.lineWidth = 2.0f;
        [bezierPath stroke];
    }];
}

- (void)dismissQRCodePicker:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) refreshLocalData {
    self.dataArray = [PoolItem findAll];
}

- (NSDictionary*)paramsFromQRArray:(NSArray*)array {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:[array objectAtIndex:0] forKey:@"url"];
    [dict setObject:[array objectAtIndex:1] forKey:@"apiKey"];
    [dict setObject:[array objectAtIndex:2] forKey:@"userID"];
    return dict;
}

- (BOOL)validateQRCodeArray:(NSArray*)array {
    if (array.count != 3) return NO;
    return ([self compoundValidateApiKey:[array objectAtIndex:1] userID:[array objectAtIndex:2] poolURL:[array objectAtIndex:0]]);
}

- (BOOL) compoundValidateApiKey:(NSString*)apiKey userID:(NSString*)userID poolURL:(NSString*)poolURL {
    return ([self validateApiKey:apiKey] && [self validateUserID:userID] && [self validatePoolURL:poolURL]);
}

- (BOOL) validateApiKey:(NSString*)apiKey {
    return [self validateAlphanumeric:apiKey];
}

- (BOOL) validateUserID:(NSString*)userID {
    return [self validateAlphanumeric:userID];
}

- (BOOL)validateAlphanumeric:(NSString*)string {
    NSMutableCharacterSet *charset = [NSMutableCharacterSet alphanumericCharacterSet];
    NSCharacterSet *othercharset = [charset invertedSet];
    NSRange range = [string rangeOfCharacterFromSet:othercharset];
    if (range.location == NSNotFound) return YES;
    return NO;
}

- (BOOL) validatePoolURL:(NSString*)poolURL {
    NSURL *url = [NSURL URLWithString:poolURL];
    if (url) return YES;
    return NO;
}

#pragma mark - UITableView dataSource & delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        PoolItem *item = [self.dataArray objectAtIndex:indexPath.row];
        [item deleteEntity];
        [self refreshLocalData];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PoolItem *item = [self.dataArray objectAtIndex:indexPath.row];
    SCDashboardVC *dashboard = [[SCDashboardVC alloc] initWithPoolItem:item];
    [self.navigationController pushViewController:dashboard animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    PoolItem *item = [self.dataArray objectAtIndex:indexPath.row];
    NSURL *apiURL = [NSURL URLWithString:item.url];
    [cell.textLabel setText:apiURL.host];
    [cell.detailTextLabel setText:item.apiKey];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

@end
