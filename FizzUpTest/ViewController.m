//
//  ViewController.m
//  FizzUpTest
//
//  Created by Grégory Meyer on 05/01/2017.
//  Copyright © 2017 Grégory Meyer. All rights reserved.
//

#import "ViewController.h"
#import "SQLiteMgr.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

SQLiteMgr *db;
NSMutableArray *entries;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [entries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:  (NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [[entries objectAtIndex:indexPath.row] objectAtIndex:2];
    
    NSData *b64image = [[NSData alloc] initWithBase64EncodedString:[[entries objectAtIndex:indexPath.row] objectAtIndex:1] options:0];
    cell.imageView.image = [UIImage imageWithData:b64image];
    return cell;
}


- (IBAction)deleteBtn:(UIBarButtonItem *)sender {
    NSLog(@"Trash pressed");
    [db clearAll];
    
}
- (IBAction)refreshBtn:(UIBarButtonItem *)sender {
    NSLog(@"Refresh pressed");
    [db clearAll];
    [self downloadJson];
    [self populateListView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    db = [SQLiteMgr getSharedInstance];
    [self populateListView];
}

- (void)downloadJson{

    NSError *error;
    NSString *url        = [NSString stringWithFormat: @"https://s3-us-west-1.amazonaws.com/fizzup/files/public/sample.json"];
    NSData *data         = [NSData dataWithContentsOfURL: [NSURL URLWithString:url]];
    NSDictionary *json   = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    NSArray *jsonData    = [json objectForKey:@"data"];
    
    for (NSDictionary * jsonObject in jsonData) {
        NSNumber *id        = [jsonObject objectForKey:@"id"];
        NSString *image_url = [jsonObject objectForKey:@"image_url"];
        NSString *image = [[[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: image_url]] base64EncodedStringWithOptions:0];
        NSString *name      = [jsonObject objectForKey:@"name"];
        
        [db saveData:id image:image name:name];
    }
}

- (void)populateListView{
    entries = [db getAll];
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
