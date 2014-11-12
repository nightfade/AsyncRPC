//
//  ViewController.m
//  AsyncRPC-iOS
//
//  Created by Meng on 14/11/7.
//  Copyright (c) 2014年 nightfade. All rights reserved.
//

#import "ViewController.h"
#import "RPCEntity.h"
#import "ProtobufRPCCodec.h"

#define SERVER_HOST @"127.0.0.1"
#define SERVER_PORT 65432
#define CONNECTING_TIMEOUT 5

@interface ViewController () <RPCEntityDelegate, RPCServiceDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) RPCEntity *rpc;
@property (strong, nonatomic) NSMutableArray *messages;

@property (weak, nonatomic) IBOutlet UITextField *inputField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)onBackgroundTapped:(UIControl *)sender;
- (IBAction)onSendPressed:(UIButton *)sender;

- (void)addNewMessage:(NSString *)message;

@property (nonatomic, strong) UIActivityIndicatorView *indicator;
- (void)startActivityIndicator;
- (void)stopActivityIndicator;

@end

@implementation ViewController

#pragma mark View Controller Callback

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.messages = [[NSMutableArray alloc] init];
    
    self.inputField.delegate = self;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"MessageCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    self.rpc = [[RPCEntity alloc] initWithCodec:[[ProtobufRPCCodec alloc] init]];
    self.rpc.delegate = self;
    self.rpc.service = self;
    [self.rpc connectHost:SERVER_HOST andPort:SERVER_PORT withTimeout:CONNECTING_TIMEOUT];
    [self startActivityIndicator];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.rpc disconnectAfterFinished:NO];
}


- (IBAction)onBackgroundTapped:(UIControl *)sender {
    [self.view endEditing:YES];
}

- (IBAction)onSendPressed:(UIButton *)sender {
    [self.rpc callMethod:@"sendMessage" usingParams:@{@"message": self.inputField.text}
            withCallback:^(NSDictionary *retvalue) {
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:retvalue options:NSJSONWritingPrettyPrinted error:nil];
                NSString *printValue = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                NSLog(@"Method Called With Return Value: %@", printValue);
            }];
    [self.inputField resignFirstResponder];
    self.inputField.text = @"";
}

- (void)startActivityIndicator {
    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicator.center = self.view.center;
    [self.indicator setFrame:self.view.frame];
    [self.indicator.layer setBackgroundColor:[[UIColor colorWithWhite:0.0 alpha:0.3] CGColor]];
    [self.indicator startAnimating];
    [self.view addSubview:self.indicator];
}

- (void)stopActivityIndicator {
    [self.indicator removeFromSuperview];
    self.indicator = nil;
}

#pragma mark TextField Callback

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    NSLog(@"textFieldShouldEndEditing");
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"textFieldShouldReturn");
    [textField resignFirstResponder];
    return YES;
}

#pragma mark TableView DataSource Callback

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
    NSString *message = self.messages[indexPath.row];
    cell.textLabel.text = message;
    return cell;
}

#pragma mark TableView Callback

#pragma mark Message Operation


- (void)addNewMessage:(NSString *)message {
    [self.messages addObject:message];
    NSInteger lastRow = [self.messages count] - 1;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastRow inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
}

#pragma mark RPCServiceDelegate

- (RPCResponse *)handleRequest:(RPCRequest *)request {
    NSData *data = [NSJSONSerialization dataWithJSONObject:request.params options:NSJSONWritingPrettyPrinted error:nil];
    NSString *printValue = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Serve Method: %@ with Params: %@ andCallid: %d", request.methodName, printValue, request.callid);
    
    RPCResponse *response = [[RPCResponse alloc] init];
    
    if ([request.methodName isEqualToString:@"sendMessage"]) {
        [self addNewMessage:request.params[@"message"]];
        response.callid = request.callid;
        response.returnValue = @{@"status": @"ok"};
    } else {
        response.callid = request.callid;
        response.returnValue = @{@"status": @"unknown method"};
    }
    return response;
}

#pragma mark RPCEntityDelegate

- (void)connectionOpened:(RPCEntity *)entity {
    [self stopActivityIndicator];
}

- (void)connectionClosed:(RPCEntity *)entity {
    [self stopActivityIndicator];
    exit(0);
}


@end
