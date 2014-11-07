//
//  ViewController.m
//  AsyncRPC-iOS
//
//  Created by Meng on 14/11/7.
//  Copyright (c) 2014年 nightfade. All rights reserved.
//

#import "ViewController.h"
#import <GCDAsyncSocket.h>

#define SERVER_HOST @"127.0.0.1"
#define SERVER_PORT 65432
#define CONNECTING_TIMEOUT 5

@interface ViewController () <GCDAsyncSocketDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) GCDAsyncSocket *socket;
@property (strong, nonatomic) NSMutableArray *messages;

@property (weak, nonatomic) IBOutlet UITextField *inputField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)onBackgroundTapped:(UIControl *)sender;
- (IBAction)onSendPressed:(UIButton *)sender;

- (void)connectToHost:(NSString *)host andPort:(uint16_t)port withTimeout:(NSTimeInterval)timeout;
- (void)writeData:(NSData *)data;
- (void)tryRead;

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
    [self connectToHost:SERVER_HOST andPort:SERVER_PORT withTimeout:CONNECTING_TIMEOUT];
    [self tryRead];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.socket disconnectAfterReadingAndWriting];
}


- (IBAction)onBackgroundTapped:(UIControl *)sender {
    [self.view endEditing:YES];
}

- (IBAction)onSendPressed:(UIButton *)sender {
    [self writeData:[self.inputField.text dataUsingEncoding:NSUTF8StringEncoding]];
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

#pragma mark Network Operation

- (void)connectToHost:(NSString *)host andPort:(uint16_t)port withTimeout:(NSTimeInterval)timeout{
    [self startActivityIndicator];
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *err = nil;
    if (![self.socket connectToHost:host onPort:port withTimeout:timeout error:&err]) {
        NSLog(@"Invalid socket setting!");
        exit(-1);
    }   
}

- (void)writeData:(NSData *)data {
    [self.socket writeData:data withTimeout:-1 tag:1];
}

- (void)tryRead {
    [self.socket readDataWithTimeout:-1 tag:0];
}

#pragma mark Network Callback

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"socket did connect to host %@ %d", host, port);
    [self stopActivityIndicator];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"socket did disconnect with error: %@", err);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"socket did read data: %@", message);
    [self addNewMessage:message];
    [self tryRead];
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

@end
