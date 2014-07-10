//
//  DBSettingViewController.m
//  docbasketWeb
//
//  Created by jaecheol kim on 7/10/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import "DBSettingViewController.h"

@interface DBSettingViewController ()

@end

@implementation DBSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DebugLogEventHandler:)
                                                 name:@"DebugLogEventHandler" object:nil];

    
    self.title = @"Debug Log";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DebugLogEventHandler" object:nil];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    [GVALUE.LogList removeAllObjects];
    
    // Dispose of any resources that can be recreated.
}

- (void)refresh
{
    [self.tableView reloadData];
    
    if (GVALUE.LogList.count > 0)
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:GVALUE.LogList.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];

}


#pragma mark - Application's Cookie Handler
- (void)DebugLogEventHandler:(NSNotification *)notification
{
    
    if([[[notification userInfo] objectForKey:@"Msg"] isEqualToString:@"logAdded"])
    {
        [self refresh];
    }
}
#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [GVALUE.LogList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.font = [UIFont systemFontOfSize:12.0];
    cell.textLabel.text = [GVALUE.LogList objectAtIndex:indexPath.row];



    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
