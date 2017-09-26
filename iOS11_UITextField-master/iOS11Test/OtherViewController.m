//
//  OtherViewController.m
//  iOS11Test
//
//  Created by styf on 2017/9/22.
//  Copyright © 2017年 styf. All rights reserved.
//

#import "OtherViewController.h"
#import "MyTextField.h"

@interface OtherViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet MyTextField *userTextField;
@property (weak, nonatomic) IBOutlet MyTextField *psdTextField;

@end

@implementation OtherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //第二步,关闭stroyboard中对应textField的secureTextEntry属性,看看是否是因为该属性导致
    
    //第三步,手动设置属性,看看是否是stroyboard引起的
    //self.psdTextField.secureTextEntry = YES;
    
    //第四步,添加代理,使用代理的方式打破强引用导致的内存无法释放
    self.userTextField.delegate = self;
    self.psdTextField.delegate = self;
    
}

//第四步(2),在代理中设置属性
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == self.psdTextField) {
        textField.secureTextEntry = YES;
    } else {
        textField.secureTextEntry = NO;
    }
    return YES;
}

- (IBAction)back:(id)sender {
    //第五步,添加结束编辑,防止后续出现其他bug
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//第一步,添加vc释放打印,看看是否是vc没有被释放
-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
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
