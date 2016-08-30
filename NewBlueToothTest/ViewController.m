//
//  ViewController.m
//  NewBlueToothTest
//
//  Created by Fillinse on 14/10/19.
//  Copyright (c) 2014年 ichronocloud. All rights reserved.
//

//屏幕宽
#define WIN_WIDTH [UIScreen mainScreen].bounds.size.width
#define WIN_WIDTH_SCALE [UIScreen mainScreen].bounds.size.width/320

//屏幕高
#define WIN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define WIN_HEIGHT_SCALE [UIScreen mainScreen].bounds.size.height/480


#import "ViewController.h"

#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,CBPeripheralDelegate,CBCentralManagerDelegate>


{
    UITableView *_tableView;
    UIButton *_scanBtn;
    UIButton *_connectBtn;
    
    CBCentralManager *_manager;
    NSMutableArray *_perialArray;
    NSMutableArray *_serviceArray;
    NSMutableArray *_charactArray;
    
    CBPeripheral *_peripheral;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //初始化蓝牙管理器
    _manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    NSLog(@"哈哈哈哈");
    
    [self loadSubviews];
}

- (void)loadSubviews
{
    _scanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _scanBtn.frame = CGRectMake(20, 20, 40, 40);
    [_scanBtn setTitle:@"扫描" forState:normal];
    [_scanBtn setBackgroundColor:[UIColor blueColor]];
    [_scanBtn addTarget:self action:@selector(scan) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_scanBtn];
    
    _connectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _connectBtn.frame = CGRectMake(WIN_WIDTH - 60, 20, 40, 40);
    [_connectBtn setTitle:@"连接" forState:normal];
    [_connectBtn setBackgroundColor:[UIColor blueColor]];
    [_connectBtn addTarget:self action:@selector(connect) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_connectBtn];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 80, WIN_WIDTH, 300)style:UITableViewStylePlain];
    _tableView.rowHeight = 40;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    _perialArray = [NSMutableArray array];
    _serviceArray = [NSMutableArray array];
    _charactArray = [NSMutableArray array];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _perialArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    
    CBPeripheral *p = _perialArray[indexPath.row];
    cell.textLabel.text = p.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _peripheral = _perialArray[indexPath.row];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma Blue tooth delegate 

//开始查看服务，蓝牙开启 每次蓝牙设备改变状态的时候都会调用，比如蓝牙开，蓝牙关
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    //	CBCentralManagerStateUnsupported,
    // CBCentralManagerStateUnauthorized,
    // CBCentralManagerStatePoweredOff,
    // CBCentralManagerStatePoweredOn,
    switch (central.state)
    {
        case CBCentralManagerStateUnsupported:
        {
            NSLog(@"CBCentralManagerStateUnsupported");
        }
            break;
        case CBCentralManagerStatePoweredOff:
        {
            NSLog(@"CBCentralManagerStatePoweredOff");

        }
            break;
        case CBCentralManagerStatePoweredOn:
        {
            NSLog(@"CBCentralManagerStatePoweredOn");

        }
            break;
            
        default:
            break;
    }
    
}
#pragma  mark- 扫描结果
//查到外设后，停止扫描，连接设备
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"_peripheral%@",peripheral);
    // Match if we have this device from before
    BOOL replace = NO;
    for (int i=0; i < _perialArray.count; i++)
    {
        CBPeripheral *p = [_perialArray objectAtIndex:i];
        if ([p isEqual:peripheral])
        {
            [_perialArray replaceObjectAtIndex:i withObject:peripheral];
            replace = YES;
        }
    }
    
    if (!replace)
    {
        [_perialArray addObject:peripheral];
    }
    [_tableView reloadData];
}
//连接外设成功，开始发现服务
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"连接成功！");
    [_peripheral setDelegate:self];
    [_peripheral discoverServices:nil];
    //    [_nCharacteristics removeAllObjects];
}
//连接外设失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"%@----连接失败",error);
}
//已发现服务
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService *s in peripheral.services)
    {
        [_serviceArray addObject:s];
    }
    for (CBService *s in peripheral.services)
    {
        [peripheral discoverCharacteristics:nil forService:s];
        NSLog(@"发现服务");
    }
    NSLog(@"发现服务");
}
#pragma  mark - 搜索到特征值
//已搜索到Characteristics
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    
    for (CBCharacteristic *c in service.characteristics)
    {
        [_peripheral readValueForCharacteristic:c];
        BOOL replace = NO;
        for (int i=0; i < _charactArray.count; i++)
        {
            CBCharacteristic *p = [_charactArray objectAtIndex:i];
            if ([p isEqual:c])
            {
                [_charactArray replaceObjectAtIndex:i withObject:c];
                replace = YES;
            }
        }
        
        if (!replace)
        {
            [_charactArray addObject:c];
        }

    }
    NSLog(@"搜索到特征值");
}

#pragma  mark - 获取链接数据
//获取外设发来的数据，不论是read和notify,获取数据都是从这个方法中读取。
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"987654321Measure");
    // BOOL isSaveSuccess;
    
    //    NSLog(@"  characteristic---%@",characteristic);
    const unsigned char *hexBytesLight = [characteristic.value bytes];
    NSLog(@"   %s  --222222",hexBytesLight);
    
    NSString *str = [NSString stringWithFormat:@"%s",hexBytesLight];
    
    NSLog(@"返回值--%@",str);
}
//开始测量
- (IBAction)startMeasureBtnClick:(id)sender  /**< 此方法是无效的  只是让你知道用法的 */
{
    //与外设的信息交互  即往蓝牙写数据，，这个需要根据蓝牙的具体情况而定
    NSData *data = [@"a" dataUsingEncoding:NSUTF8StringEncoding];
    //    NSLog(@"%@-=-=-characteristic%@",self.peripheral,self.nCharacteristics);
    [_peripheral writeValue:data forCharacteristic:_charactArray[0] type:CBCharacteristicWriteWithoutResponse];
}


- (void)scan
{
    //允许重复扫描到相同的设备 CBCentralManagerScanOptionAllowDuplicatesKey
        [_manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES}];
    
}

- (void)connect
{
    //连接设备
    //已选择外设时才能连接 （即扫描到设备时候）
    if (_peripheral)
    {
        [_manager connectPeripheral:_peripheral options:nil];

    }
}

@end
