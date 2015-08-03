//
//  VideoPlayerViewController.m
//  Gifted Kids
//
//  Created by 李诣 on 5/15/14.
//  Copyright (c) 2014 Yi Li 李诣. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import "Video.h"


@interface VideoPlayerViewController ()

@property (strong, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) Video* video;

@end


@implementation VideoPlayerViewController

@synthesize context = _context;

@synthesize videoName = _videoName;

@synthesize webView = _webView;

@synthesize video = _video;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    
    self.navigationItem.title = self.videoName;
    
    [self getVideo];
    [self loadVideo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Load Video

- (void)getVideo
{
    NSArray* components = [self.videoName componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" ."]];
    int unit = [components[components.count - 2] intValue];
    int index = [components[components.count - 1] intValue];
    size_t videoID = unit * 1000000 + index;
    
    NSFetchRequest* request_video = [NSFetchRequest fetchRequestWithEntityName:@"Video"];
    request_video.predicate = [NSPredicate predicateWithFormat:@"uid == %ld", videoID];
    NSError* error = nil;
    NSArray* match_video = [self.context executeFetchRequest:request_video error:&error];
    
    if (! match_video || [match_video count] > 1) {
        NSLog(@"ERROR: Error when fetching video with ID %ld", videoID);
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if ([match_video count] == 0) {
        NSLog(@"ERROR: No video exists with ID %ld", videoID);
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        self.video = [match_video lastObject];
    }
}

- (void)loadVideo
{
    float width, height;
    
    NSString* frameSize = self.video.frameSize;
    if (! frameSize || [frameSize isEqualToString:@""]) {
        width = self.webView.frame.size.width;
        height = width * 320 / 480;
    }
    else {
        NSArray* components = [frameSize componentsSeparatedByString:@"x"];
        if ([components count] != 2) {
            width = self.webView.frame.size.width;
            height = width * 320 / 480;
        }
        else {
            float videoWidth = [components[0] floatValue];
            float videoHeight = [components[1] floatValue];
            width = self.webView.frame.size.width;
            height = width * videoHeight / videoWidth;
        }
    }
    
    NSString* youkuID = self.video.youkuID;
    
    NSString* htmlString = [NSString stringWithFormat:@"\
                            <html><body style=\"background:#00;margin-top:0px;margin-left:0px\"><div>\
                                <video width=\"%f\" height=\"%f\" src=\"http://v.youku.com/player/getRealM3U8/vid/%@/type//video.m3u8\" controls>\
                                    <embed src=\"http://player.youku.com/player.php/sid/%@/v.swf\" \
                                        allowFullScreen=\"true\" quality=\"high\" width=\"%f\" height=\"%f\" \
                                        align=\"middle\" allowScriptAccess=\"always\" \
                                        type=\"application/x-shockwave-flash\">\
                                    </embed>\
                                </video>\
                            </div></body></html>",
                            width, height, youkuID, youkuID, width, height];
    NSString* htmlString2 = [NSString stringWithFormat:@"\
                             <html><body style=\"background:#00;margin-top:0px;margin-left:0px\">\
                                <div id=\"youkuplayer\" style=\"width:%fpx;height:%fpx\"></div>\
                                <script type=\"text/javascript\" src=\"http://player.youku.com/jsapi\">\
                                    player = new YKU.Player('youkuplayer',{\
                                        styleid: '0',\
                                        client_id: 'a5e09e84722a682c',\
                                        vid: '%@'\
                                        show_related: false\
                                    });\
                                </script>\
                             </body></html>",
                             width, height, youkuID];
    [self.webView loadHTMLString:htmlString2 baseURL:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playbackEnded:) name:@"UIMoviePlayerControllerDidEnterFullscreenNotification"
                                               object:self.webView];
}

- (IBAction)playbackEnded:(id)sender
{
    NSLog(@"Full Screen");
}


#pragma mark - Interface Orientation

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
