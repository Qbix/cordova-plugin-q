//
//  MultiTestBaseViewController.m
//  Shipping
//
//  Created by Home on 3/29/16.
//
//

#import "MultiTestBaseViewController.h"

@interface MultiTestBaseViewController () {
    UITapGestureRecognizer *tapGestureRecognizer;
    NSArray *bookmarksList;
}

@end

@implementation MultiTestBaseViewController

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerKeyboardShowHideEvents];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    [self reloadDataToTable];
    // Do any additional setup after loading the view.
}

-(void) reloadDataToTable {
    bookmarksList = [self getBookmarksList];
    [self.tableView reloadData];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if([bookmarksList count] > indexPath.row) {
            [self removeBookmark:[bookmarksList objectAtIndex:indexPath.row]];
            [self reloadDataToTable];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [bookmarksList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *indetifier = @"simpleCell";
    UITableViewCell *tableViewCell = [tableView dequeueReusableCellWithIdentifier:indetifier];
    if(tableViewCell == nil) {
        tableViewCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indetifier];
    }
    
    tableViewCell.textLabel.text = [bookmarksList objectAtIndex:indexPath.row];
    
    return tableViewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([self delegate] != nil && [[self delegate] respondsToSelector:@selector(loadQCordovaApp:)]) {
        [[self delegate] performSelector:@selector(loadQCordovaApp:) withObject:[bookmarksList objectAtIndex:indexPath.row]];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) registerKeyboardShowHideEvents {
    NSLog(@"Register keyboard");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void) keyboardWillShow:(NSNotification*) notification {
    NSLog(@"keyboardWillShow");
    if(tapGestureRecognizer == nil) {
        tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
        [tapGestureRecognizer setCancelsTouchesInView:NO];
        [self.view addGestureRecognizer:tapGestureRecognizer];
    }
}

-(void) keyboardWillHide:(NSNotification*) notification {
    NSLog(@"keyboardWillHide");
    if(tapGestureRecognizer != nil) {
        [self.view removeGestureRecognizer:tapGestureRecognizer];
        tapGestureRecognizer = nil;
    }
}

-(void) dismissKeyboard {
    NSLog(@"dismissKeyboard");
    [self.view endEditing:YES];
}

#define BOOKMARK_FLAG @"bookmarks"

-(NSArray*) getBookmarksList {
    NSArray* tmpBookmarksList = [[NSUserDefaults standardUserDefaults] objectForKey:BOOKMARK_FLAG];
    if(tmpBookmarksList == nil) {
        return [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return tmpBookmarksList;
}


-(void) addNewBookmark:(NSString*) newBookmark {
    NSMutableArray* tmpBookmarksList = [NSMutableArray arrayWithArray:[self getBookmarksList]];
    
    BOOL isDuplicate = NO;
    for(int i=0; i < [tmpBookmarksList count]; i++) {
        if([[tmpBookmarksList objectAtIndex:i] isEqualToString:newBookmark]) {
            isDuplicate = YES;
        }
    }
    if(!isDuplicate) {
        [tmpBookmarksList addObject:newBookmark];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:tmpBookmarksList forKey:BOOKMARK_FLAG];
    
    [self reloadDataToTable];
}

-(void) removeBookmark:(NSString*) bookmark {
    NSMutableArray* tmpBookmarksList = [NSMutableArray arrayWithArray:[self getBookmarksList]];
    
    int positionToDelete = -1;
    for(int i=0; i < [tmpBookmarksList count]; i++) {
        if([[tmpBookmarksList objectAtIndex:i] isEqualToString:bookmark]) {
            positionToDelete = i;
            break;
        }
    }
    
    if(positionToDelete > -1) {
        [tmpBookmarksList removeObjectAtIndex:positionToDelete];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:tmpBookmarksList forKey:BOOKMARK_FLAG];
    
}

-(NSURL*) getNSURLFromString:(NSString*) rawUrl {
    NSURL *url = [NSURL URLWithString:rawUrl];
    if (url && url.scheme && url.host)
    {
        return url;
    }
    
    return nil;
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
