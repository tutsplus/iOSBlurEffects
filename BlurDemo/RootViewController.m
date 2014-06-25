//
//  RootViewController.m
//  BlurDemo
//
//  Created by Sandeep S Kumar on 22/06/14.
//  Copyright (c) 2014 Razorthink. All rights reserved.
//

#import "RootViewController.h"
#import "UIImage+ImageEffects.h"
#import <GPUImage/GPUImage.h>

@interface RootViewController ()

@property UIView *bgMask;
@property UIImageView *blurredBgImage;

@end

@implementation RootViewController

@synthesize bgMask, blurredBgImage;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
}

- (UIView *)createHeaderView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    headerView.backgroundColor = [UIColor colorWithRed:229/255.0 green:39/255.0 blue:34/255.0 alpha:0.6];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 40)];
    title.text = @"Dynamic Blur Demo";
    title.textColor = [UIColor colorWithWhite:1 alpha:1];
    [title setFont:[UIFont fontWithName:@"HelveticaNeue" size:20]];
    [title setTextAlignment:NSTextAlignmentCenter];
    [headerView addSubview:title];
    
    return headerView;
}

- (UIView *)createContentView
{
    UIView *contentView = [[UIView alloc] initWithFrame:self.view.frame];
    
    UIImageView *contentImage = [[UIImageView alloc] initWithFrame:contentView.frame];
    contentImage.image = [UIImage imageNamed:@"demo-bg"];
    [contentView addSubview:contentImage];
    
    UIView *metaViewContainer = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 65, 335, 130, 130)];
    metaViewContainer.backgroundColor = [UIColor whiteColor];
    metaViewContainer.layer.cornerRadius = 65;
    [contentView addSubview:metaViewContainer];
    
    UILabel *photoTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 54, 130, 18)];
    photoTitle.text = @"Peach Garden";
    [photoTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
    [photoTitle setTextAlignment:NSTextAlignmentCenter];
    photoTitle.textColor = [UIColor colorWithWhite:0.4 alpha:1];
    [metaViewContainer addSubview:photoTitle];
    
    UILabel *photographer = [[UILabel alloc] initWithFrame:CGRectMake(0, 72, 130, 9)];
    photographer.text = @"by Cas Cornelissen";
    [photographer setFont:[UIFont fontWithName:@"HelveticaNeue-Thin" size:9]];
    [photographer setTextAlignment:NSTextAlignmentCenter];
    photographer.textColor = [UIColor colorWithWhite:0.4 alpha:1];
    [metaViewContainer addSubview:photographer];
    
    return contentView;
}

- (UIImage *)blurWithImageEffects:(UIImage *)image
{
//    return [image applyLightEffect];
    return [image applyBlurWithRadius:30 tintColor:[UIColor colorWithWhite:1 alpha:0.2] saturationDeltaFactor:1.5 maskImage:nil];
}

- (UIImage *)blurWithCoreImage:(UIImage *)sourceImage
{
    CIImage *inputImage = [CIImage imageWithCGImage:sourceImage.CGImage];
    
    // Apply Affine-Clamp filter to stretch the image so that it does not
    // look shrunken when gaussian blur is applied
    CGAffineTransform transform = CGAffineTransformIdentity;
    CIFilter *clampFilter = [CIFilter filterWithName:@"CIAffineClamp"];
    [clampFilter setValue:inputImage forKey:@"inputImage"];
    [clampFilter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
    
    // Apply gaussian blur filter with radius of 30
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName: @"CIGaussianBlur"];
    [gaussianBlurFilter setValue:clampFilter.outputImage forKey: @"inputImage"];
    [gaussianBlurFilter setValue:@30 forKey:@"inputRadius"];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:gaussianBlurFilter.outputImage fromRect:[inputImage extent]];
    
    // Set up output context.
    UIGraphicsBeginImageContext(self.view.frame.size);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.view.frame.size.height);
    
    // Draw base image.
    CGContextDrawImage(outputContext, self.view.frame, cgImage);
    
    // Apply white tint
    CGContextSaveGState(outputContext);
    CGContextSetFillColorWithColor(outputContext, [UIColor colorWithWhite:1 alpha:0.2].CGColor);
    CGContextFillRect(outputContext, self.view.frame);
    CGContextRestoreGState(outputContext);
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}

- (UIImage *)blurWithGPUImage:(UIImage *)sourceImage
{
    GPUImageGaussianBlurFilter *blurFilter = [[GPUImageGaussianBlurFilter alloc] init];
    blurFilter.blurRadiusInPixels = 30.0;

//    GPUImageBoxBlurFilter *blurFilter = [[GPUImageBoxBlurFilter alloc] init];
//    blurFilter.blurRadiusInPixels = 20.0;

//    GPUImageiOSBlurFilter *blurFilter = [[GPUImageiOSBlurFilter alloc] init];
//    blurFilter.saturation = 1.5;
//    blurFilter.blurRadiusInPixels = 30.0;
    
    return [blurFilter imageByFilteringImage: sourceImage];
}

- (void)performBlur
{
    NSDate *startTime = [NSDate date];
    
    // blurredBgImage.image = [self blurWithImageEffects:[self takeSnapshotOfView:[self createContentView]]];
    // blurredBgImage.image = [self blurWithCoreImage:[self takeSnapshotOfView:[self createContentView]]];
    // blurredBgImage.image = [self blurWithGPUImage:[self takeSnapshotOfView:[self createContentView]]];
    
    NSDate *endTime = [NSDate date];
    NSTimeInterval execTime = [endTime timeIntervalSinceDate:startTime];
    
    NSLog(@"Time taken to blur: %lf", execTime);
    
}

- (UIView *)createScrollView
{
    UIView *containerView = [[UIView alloc] initWithFrame:self.view.frame];
    
    blurredBgImage = [[UIImageView  alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 568)];
    [blurredBgImage setContentMode:UIViewContentModeScaleToFill];
    [containerView addSubview:blurredBgImage];
    
    // Blurred with UIImage+ImageEffects
    blurredBgImage.image = [self blurWithImageEffects:[self takeSnapshotOfView:[self createContentView]]];
    
    // Blurred with Core Image
    // blurredBgImage.image = [self blurWithCoreImage:[self takeSnapshotOfView:[self createContentView]]];
    
    // Blurring with GPUImage framework
    // blurredBgImage.image = [self blurWithGPUImage:[self takeSnapshotOfView:[self createContentView]]];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    [containerView addSubview:scrollView];
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height*2 - 110);
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.bounces = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    
    UIView *slideContentView = [[UIView alloc] initWithFrame:CGRectMake(0, 518, self.view.frame.size.width, 508)];
    slideContentView.backgroundColor = [UIColor clearColor];
    [scrollView addSubview:slideContentView];
    
    // Button to check run time of blurs
//    UIButton *slideUpButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
//    slideUpButton.backgroundColor = [UIColor clearColor];
//    [slideUpButton addTarget:self action:@selector(performBlur) forControlEvents:UIControlEventTouchUpInside];
//    [slideContentView addSubview:slideUpButton];
    
    UILabel *slideUpLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 6, self.view.frame.size.width, 50)];
    slideUpLabel.text = @"Photo information";
    [slideUpLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18]];
    [slideUpLabel setTextAlignment:NSTextAlignmentCenter];
    slideUpLabel.textColor = [UIColor colorWithWhite:0 alpha:0.5];
    [slideContentView addSubview:slideUpLabel];
    
    UIImageView *slideUpImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 12, 4, 24, 22.5)];
    slideUpImage.image = [UIImage imageNamed:@"up-arrow.png"];
    [slideContentView addSubview:slideUpImage];
    
    UITextView *detailsText = [[UITextView alloc] initWithFrame:CGRectMake(25, 100, 270, 350)];
    detailsText.backgroundColor = [UIColor clearColor];
    detailsText.text = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
    [detailsText setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16]];
    [detailsText setTextAlignment:NSTextAlignmentCenter];
    detailsText.textColor = [UIColor colorWithWhite:0 alpha:0.6];
    [slideContentView addSubview:detailsText];
    
    bgMask = [[UIView alloc] initWithFrame:CGRectMake(0, 518, self.view.frame.size.width, self.view.frame.size.height)];
    bgMask.backgroundColor = [UIColor whiteColor];
    blurredBgImage.layer.mask = bgMask.layer;
    
    return containerView;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    bgMask.frame = CGRectMake(bgMask.frame.origin.x, 518 - scrollView.contentOffset.y, bgMask.frame.size.width, bgMask.frame.size.height);
}

- (UIImage *)takeSnapshotOfView:(UIView *)view
{
    CGFloat reductionFactor = 1;
    UIGraphicsBeginImageContext(CGSizeMake(view.frame.size.width/reductionFactor, view.frame.size.height/reductionFactor));
    [view drawViewHierarchyInRect:CGRectMake(0, 0, view.frame.size.width/reductionFactor, view.frame.size.height/reductionFactor) afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // content view
    [self.view addSubview:[self createContentView]];
    
    // header view
    [self.view addSubview:[self createHeaderView]];
    
    // slide view
    [self.view addSubview:[self createScrollView]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
