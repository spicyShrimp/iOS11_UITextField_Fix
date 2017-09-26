# iOS11_UITextField_Fix
iOS11存在UITextField内存泄漏的bug解决
博文地址:[http://blog.csdn.net/spicyShrimp/article/details/78092109](http://blog.csdn.net/spicyShrimp/article/details/78092109)

昨天工作忙完,闲来无事的时候,逛逛论坛,贴吧啥的,偶然间就发现了有人发bug帖.
[http://www.jianshu.com/p/b51ead39c55d](http://www.jianshu.com/p/b51ead39c55d)

上面说的神乎其神呢...
大家可以去看看.

怀着好奇的态度,下载了源码
干净的很,任何代码都没有
只有sotryboard 拖拽了几个控件, 绑定了present和dismiss的事件而已,除此以外没有任何代码
类似这样
![这里写图片描述](http://img.blog.csdn.net/20170926084039306?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvc3BpY3lTaHJpbXA=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

于是编译运行项目
按照他说的,确实出现了这个小而且偏的bug复现

于是想要解决bug

 - 解决bug第一步

首先不管理内存什么的问题,怀疑是不是vc没有释放?
于是在vc的dealloc中添加打印

```

-(void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

```

运行.返现没有任何问题,vc能够正常释放,但是textField确实没有被释放.排除vc引用

 - 解决bug第二步
关闭bug描述中所说的第一个关键条件
![这里写图片描述](http://img.blog.csdn.net/20170926084921651?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvc3BpY3lTaHJpbXA=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

编译运行,发现bug已经没有复现了,项目运行正常,vc能够释放,textField也能够释放.所以下定解决,出现bug的原因就是这个属性了.

 - 解决bug第三步
既然关闭了该属性,就能解决bug,那么bug肯定是这个属性导致的,
于是考虑能否使用手写的方式.于是在vc中给这些小控件命名,  且手动设置该属性
![这里写图片描述](http://img.blog.csdn.net/20170926085345434?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvc3BpY3lTaHJpbXA=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

编译运行,bug复现,说明该属性在iOS11下确实会强引用控件,导致不能释放,

 - 解决bug第四步
既然强引用导致的释放问题,那么调整引用时机即可, 这里能想到的是使用弱指针,或者其他弱引用打破强引用即可
	思路一,使用block来打破,这里因为UITextField没有相关的block方法,添加方法也没有什么意思,放弃
	思路二,使用UITextField的代理,因为使用过代理的开发者都知道,其实weak属性,所以其已经打破了强引用的条件,我们只需在适当的代理方法中设置即可
	于是添加代理
	![这里写图片描述](http://img.blog.csdn.net/20170926090057290?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvc3BpY3lTaHJpbXA=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

代理完毕之后,找到合适的地方写需要的代码即可
	![这里写图片描述](http://img.blog.csdn.net/20170926090137581?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvc3BpY3lTaHJpbXA=/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
	遍历代理方法,发现这三个方法应该都是可以使用的,于是选择第一条,在准备编辑的时候便开始设置相关属性,于一开始就设置应该是一样的效果,完全不影响之前的效果
	于是添加代码
	

```
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField == self.psdTextField) {
        textField.secureTextEntry = YES;
    } else {
        textField.secureTextEntry = NO;
    }
    return YES;
}
```

再次编译运行,
bug已经不见了释放问题得到解决.

 - 解决bug第五步
为了防止会再次出现其他莫名bug,需要设置一些通用的设置,比如界面释放结束编辑,vc释放前释放代理等

```
- (IBAction)back:(id)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
```

所以整个bug修复的过程就是取消storyboard的secureTextEntry属性,改为手动添加,防止强引用,改为到代理里面设置,让系统自动帮我们打破强引用即可
	


