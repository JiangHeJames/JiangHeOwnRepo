//
//  ViewController.m
//  简易聊天室
//
//  Created by 吴雪平 on 2017/2/19.
//  Copyright © 2017年 Rong Xin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<NSStreamDelegate>
{

    NSInputStream *_inputStream;  // 对应输入流
    NSOutputStream *_outputStream; // 对应输出流
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

// 实现代理
-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    
//    NSStreamEventOpenCompleted = 1UL << 0,            // 输入输出流打开完成
//    NSStreamEventHasBytesAvailable = 1UL << 1,        // 有字节可读
//    NSStreamEventHasSpaceAvailable = 1UL << 2,        // 可以发送字节
//    NSStreamEventErrorOccurred = 1UL << 3,            // 连接出现错误
//    NSStreamEventEndEncountered = 1UL << 4            // 连接结束
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            break;
        case NSStreamEventHasBytesAvailable:
            [self readData];   // 读取数据
            break;
        case NSStreamEventHasSpaceAvailable:break;
        case NSStreamEventErrorOccurred:break;
        case NSStreamEventEndEncountered:break;
            
        default:
            break;
    }
}

// 连接服务器
- (IBAction)connectF:(id)sender {
    
    // 1.建立连接
    NSString *host = @"127.0.0.1";
    int port = 12345;
    
    // 定义C语言输入输出流
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)host, port, &readStream, &writeStream);
    
    // 把C语言的输入输出流转化成OC对象
    _inputStream = (__bridge NSInputStream *)(readStream);
    _outputStream = (__bridge NSOutputStream *)(writeStream);
    
    // 设置代理
    _inputStream.delegate  = self;
    _outputStream.delegate = self;
    
    // 把输入输出流添加到主运行循环    // 不添加主运行循环，代理有可能不工作
    [_inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [_outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    // 打开输入输出流
    [_inputStream open];
    [_outputStream open];
}


// 登录
- (IBAction)loginF:(id)sender {
    
    // 2.收发数据
    
    // 登录
    // 发送用户名和密码
    // 在这里做的时候，只发用户名，密码不用发送
    
    // 如果要登录，发送的数据格式为 “iam:zhangsan”   <服务器定义>
    // 如果要发送聊天消息，数据格式为 "msg:Did you have dinner" <服务器定义>
    
    // 登录的指令
    NSString *loginStr = @"iam:zhangsan";
    
    // 把Str转成NSData
    NSData *data = [loginStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [_outputStream write:data.bytes maxLength:data.length];
}


# pragma mark 读取服务器返回的数据

- (void)readData{

    // 建立一个缓冲区 可以放1024个字节
    uint8_t buf[1024];
    
    // 返回实际装的字节数
    NSInteger len = [_inputStream read:buf maxLength:sizeof(buf)];
    
    // 把字节数组转化成字符串
    NSData *data = [NSData dataWithBytes:buf length:len];
    
    // 从服务器接收到的数据
    NSString *recStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@",recStr);
}



























- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
