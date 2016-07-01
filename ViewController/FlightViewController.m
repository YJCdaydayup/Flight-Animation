
//
//  FlightViewController.m
//  FlightAnimation
//
//  Created by 杨力 on 24/5/2016.
//  Copyright © 2016 杨力. All rights reserved.
//

#import "FlightViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "GifView.h"
#import "YLAutoLayOut.h"
#import "Tools.h"
#import "CommonDefin.h"
#import "flight_param.h"

@interface FlightViewController ()

/*装昵称前图标的数组*/
@property (nonatomic,strong) NSMutableArray * picArray;
/*昵称的父视图*/
@property (nonatomic,strong) UIView * bgView;


@property (nonatomic,strong) GifView * gifImageView1;
@property (nonatomic,strong) GifView * gifImageView2;

@end

@implementation FlightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"飞机";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"zhubo"]];
    [self setNiceNameAndImages1];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [UIView animateWithDuration:TEXTSHOWSPEED animations:^{
        
        self.bgView.transform = CGAffineTransformMakeTranslation(-Wscreen+35*ScreenMultipleIn6, 0);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //Action－01
            [self flight1ShowOut];
        });
    }];
}

//设置昵称前面的图标数组，可能0-4张，存放到一个数
-(void)setNiceNameAndImages1{
#pragma mark - 先存放假数据
    
    NSArray * array = @[@"01",@"02",@"03",@"04"];
    
    [self.picArray removeAllObjects];
    
    [self.picArray addObjectsFromArray:array];
    
    //创建富文本
    NSMutableAttributedString * attri = [[NSMutableAttributedString alloc]init];
    
    //添加昵称前面的图标
    for(int i=0;i<self.picArray.count;i++){
        
        NSTextAttachment * attachImage = [[NSTextAttachment alloc]init];
        attachImage.image = [UIImage imageNamed:self.picArray[i]];
        attachImage.bounds = CGRectMake(0*ScreenMultipleIn6, -3*ScreenMultipleIn6, 31*ScreenMultipleIn6, 15*ScreenMultipleIn6);
        NSAttributedString  * imageString = [NSAttributedString attributedStringWithAttachment:attachImage];
        [attri appendAttributedString:imageString];
    }
    //添加昵称
    NSMutableAttributedString * nickname = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@" %@",@"八戒"]];
    //昵称大小
    [nickname addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:NAME_SIZE*ScreenMultipleIn6] range:NSMakeRange(0, nickname.length)];
    //昵称颜色
    [nickname addAttribute:NSForegroundColorAttributeName value:NAME_COLOR range:NSMakeRange(0, nickname.length)];
    [attri appendAttributedString:nickname];
    
    //添加文案
    NSMutableAttributedString * text = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@",@"送了一架国产战斗机"]];
    //文案大小
    [text addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:CONTENTSIZE*ScreenMultipleIn6] range:NSMakeRange(0, text.length)];
    //文案颜色
    [text addAttribute:NSForegroundColorAttributeName value:CONTENT_COLOR range:NSMakeRange(0, text.length)];
    [attri appendAttributedString:text];
    
    UILabel * nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, Wscreen/2.0+120*ScreenMultipleIn6, 10)];
    nameLabel.attributedText = attri;
    nameLabel.numberOfLines = 0;
    [nameLabel sizeToFit];
    [self.view addSubview:nameLabel];
    
    CGFloat width = nameLabel.frame.size.width;
    CGFloat height = nameLabel.frame.size.height;
    
    nameLabel.frame = CGRectMake(15, 2.5*ScreenMultipleIn6, width, height);
    self.bgView = [[UIView alloc]initWithFrame:CGRectMake(Wscreen, 115*ScreenMultipleIn6, width+25*ScreenMultipleIn6, height+6*ScreenMultipleIn6)];
    self.bgView.backgroundColor = RGB_COLOR(28, 28, 28, 0.5);
    [self.view addSubview:self.bgView];
    [self.bgView addSubview:nameLabel];
    
    //将小黄圈圈添加到Label上
    UIImageView * spotImageView = [[UIImageView alloc]initWithFrame:CGRectMake(-12*ScreenMultipleIn6, 3.5*ScreenMultipleIn6, 11*ScreenMultipleIn6, 11*ScreenMultipleIn6)];
    spotImageView.image = [UIImage imageNamed:@"spot"];
    [nameLabel addSubview:spotImageView];
    
    //设置圆角等
    self.bgView.layer.cornerRadius = 12*ScreenMultipleIn6;
    self.bgView.layer.masksToBounds = YES;
}

-(void)flight1ShowOut{
    
    /*播放音效*/
    [self playSound];
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
    CATransform3D scaleTransform = CATransform3DMakeScale(2.2, 2.1, 1);
    CATransform3D positionTransform = CATransform3DMakeTranslation(-0.4*Wscreen*ScreenMultipleIn6,25*ScreenMultipleIn6, 50*ScreenMultipleIn6); //位置移动
    CATransform3D combinedTransform = CATransform3DConcat(scaleTransform, positionTransform); //Concat就是combine的意思
    
    [anim setFromValue:[NSValue valueWithCATransform3D:CATransform3DIdentity]]; //放在3D坐标系中最正的位置
    [anim setToValue:[NSValue valueWithCATransform3D:combinedTransform]];
    [anim setDuration:FLIGHT01_SPEED1];
    
    [self.gifImageView1.layer addAnimation:anim forKey:nil];
    
    [self.gifImageView1.layer setTransform:combinedTransform];//如果没有这句，layer执行完动画又会返回最初的state
    
    //Action-02
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((FLIGHT01_SPEED1+FLIGHT01_STAYTIME) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self flight1FlyAway];
    });
}

-(void)flight1FlyAway{
    
    /*先记录上一次的状态*/
    CATransform3D scaleTransform = CATransform3DMakeScale(2.2,2.1, 1);
    CATransform3D positionTransform = CATransform3DMakeTranslation(-0.4*Wscreen*ScreenMultipleIn6,25*ScreenMultipleIn6, 50*ScreenMultipleIn6); //位置移动
    CATransform3D combinedTransform = CATransform3DConcat(scaleTransform, positionTransform); //Concat就是combine的意思
    
    /*飞出参数动画*/
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform"];
    CATransform3D scaleTransform1 = CATransform3DMakeScale(3.4,3.3,1);
    CATransform3D positionTransform1 = CATransform3DMakeTranslation(-1.2*Wscreen-135*ScreenMultipleIn6,45*ScreenMultipleIn6,50*ScreenMultipleIn6); //位置移动
    CATransform3D combinedTransform1 = CATransform3DConcat(scaleTransform1, positionTransform1); //Concat就是combine的意思
    
    [anim setFromValue:[NSValue valueWithCATransform3D:combinedTransform]]; //放在3D坐标系中最正的位置
    [anim setToValue:[NSValue valueWithCATransform3D:combinedTransform1]];
    [anim setDuration:FLIGHT01_SPEED2];
    
    [self.gifImageView1.layer addAnimation:anim forKey:nil];
    
    [self.gifImageView1.layer setTransform:combinedTransform1];  //如果没有这句，layer执行完动画又会返回最初的state
    
    //Action－03
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((FLIGHT01_SPEED2+0.5f) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        self.gifImageView1 = nil;
        [self flight2ShowOut];
    });
}

-(void)flight2ShowOut{
    
    /*播放音效*/
    [self playSound];
    
    [UIView animateWithDuration:FLIGHT02_SPEED animations:^{
        
        self.gifImageView2.transform = CGAffineTransformMakeTranslation(1.5*Wscreen+50*ScreenMultipleIn6, -250*ScreenMultipleIn6);
        
    } completion:^(BOOL finished) {
        
        self.gifImageView2 = nil;
        [UIView animateWithDuration:TEXTFLYOUTSPEED animations:^{
            
            self.bgView.transform = CGAffineTransformMakeTranslation(-2*Wscreen, 0);
            
        } completion:^(BOOL finished) {
            
            //            self.bgView = nil;
        }];
    }];
}

//播放飞机音效
-(void) playSound
{
    static SystemSoundID soundIDTest = 0;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"flight_voice" ofType:@"wav"];
    if (path) {
        
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&soundIDTest);
        AudioServicesPlaySystemSound(soundIDTest);
    }
}

//懒加载
-(GifView *)gifImageView1{
    
    if(_gifImageView1 == nil){
        
        //获取本地图片
        _gifImageView1 = [[GifView alloc]initWithFrame:CGRectMake(Wscreen/2.0 + 60*ScreenMultipleIn6, 125*ScreenMultipleIn6, flight1_Width*ScreenMultipleIn6,flight1_Width*1334/750.0*ScreenMultipleIn6) filePath:[[NSBundle mainBundle] pathForResource:@"flight1" ofType:@"gif"]];
        [self.view addSubview:_gifImageView1];
    }
    
    return _gifImageView1;
}

-(GifView *)gifImageView2{
    
    if(_gifImageView2 == nil){
        
        //获取本地图片
        _gifImageView2 = [[GifView alloc]initWithFrame:CGRectMake(-Wscreen/2.0-30*ScreenMultipleIn6, Hscreen-450*ScreenMultipleIn6, flight2_Width*ScreenMultipleIn6, flight2_Width*1334/750.0*ScreenMultipleIn6) filePath:[[NSBundle mainBundle] pathForResource:@"flight2" ofType:@"gif"]];
        [self.view addSubview:_gifImageView2];
    }
    
    return _gifImageView2;
}
-(NSMutableArray *)picArray{
    
    if(_picArray == nil){
        
        _picArray = [[NSMutableArray alloc]init];
    }
    
    return _picArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
