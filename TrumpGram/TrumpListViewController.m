//
//  ViewController.m
//  TrumpGram
//
//  Created by Joffrey Mann on 8/7/15.
//  Copyright (c) 2015 Nutech. All rights reserved.
//

#import "TrumpListViewController.h"
#import "TrumpPost.h"

#define IG_POSTS_REQUEST_URL @"https://api.instagram.com/v1/tags/donaldtrump/media/recent?access_token=502037425.1fb234f.63730a15ec14473cae56abdc1688e680"


@interface TrumpListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *posts;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (atomic) unsigned long largestRequestedRow;

@property (atomic, strong) NSString *nextURL;

@property (nonatomic, strong) NSString *tag;

@property (nonatomic, strong) NSMutableArray *URLs;

@property (strong, nonatomic) NSURLSession *session;

@end

@implementation TrumpListViewController
NSURL *imageURL;
NSString *createdTime;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _posts = [[NSMutableArray alloc]init];
    [self downloadTrumpPosts];
    _largestRequestedRow = 0;
}


-(void)downloadTrumpPosts
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session = [NSURLSession sessionWithConfiguration:config
                                                          delegate:nil
                                                     delegateQueue:nil];
    NSURLSessionTask *task = [_session dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:IG_POSTS_REQUEST_URL]] completionHandler:
                              ^(NSData *data, NSURLResponse *response, NSError *error)
                              {
                                  NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data
                                                                                               options:0
                                                                                                 error:nil];
                                  NSDictionary *pagination = responseData[@"pagination"];
                                      NSString *nextURLString = pagination[@"next_url"];
                                      //NSURL *nextURL = [NSURL URLWithString:nextURLString];
                                  if (responseData) {
                                      NSArray *immutablePosts = responseData[@"data"];
                                      // ... But now we are blog posts in a more mutable array
                                      for (NSDictionary *postDictionary in immutablePosts) {
                                          createdTime = postDictionary[@"created_time"];
                                          NSDictionary *imageDict = postDictionary[@"images"];
                                                  if(![imageDict isEqual:[NSNull null]])
                                                  {
                                                      NSDictionary *thumbnail = imageDict[@"thumbnail"];
                                                      NSString *imageString = thumbnail[@"url"];
                                          
                                                      UIImage *postImage = [self imagewithURL:imageString];
                                          
                                                      NSDictionary *caption = postDictionary[@"caption"];
                                                      NSString *username;
                                                      NSString *captionString;
                                                      if(![caption isEqual:[NSNull null]])
                                                      {
                                                          captionString = caption[@"text"];
                                                          NSDictionary *fromUserDict = caption[@"from"];
                                                          username = fromUserDict[@"username"];
                                                          NSLog(@"%@", username);
                                                      }
                                                      
                                                      else
                                                      {
                                                          captionString = @"There is no caption here";
                                                      }
                                                      
                                                      TrumpPost *trumpPost = [[TrumpPost alloc]initWithPost:username andCaption:captionString andImage:postImage];
                                                      [self.posts addObject:trumpPost];
                                                  }
                                      }
                                  }
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      if(nextURLString)
                                      {
                                          [self downloadTrumpPosts];
                                      } else {
                                          _nextURL = nextURLString;
                                      }
                                      [self.tableView reloadData];
                                  });
                            }];
                    [task resume];
}

//-(void)fetchTrumpFeed:(NSMutableData *)data
//{
//    NSError *error = nil;
//    //Create a dictionary for the json document
//    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data
//                                                               options:0
//                                                                 error:&error];
//    
////    NSDictionary *pagination = jsonObject[@"pagination"];
////    
////    NSString *nextURLString = pagination[@"next_url"];
////    NSURL *nextURL = [NSURL URLWithString:nextURLString];
////    TrumpPostDelegate *postDelegate = [[TrumpPostDelegate alloc]init];
////    [postDelegate downloadForNextURLS:nextURL];
////    postDelegate.delegate = self;
//    
//    NSLog(@"%@", jsonObject);
//    self.posts = [[NSMutableArray alloc]init];
//    NSArray *immutablePosts = jsonObject[@"data"];
//    for(NSDictionary *dict in immutablePosts){
//        createdTime = dict[@"created_time"];
//        NSDictionary *imageDict = dict[@"images"];
//        if(![imageDict isEqual:[NSNull null]])
//        {
//            NSDictionary *thumbnail = imageDict[@"thumbnail"];
//            NSString *imageString = thumbnail[@"url"];
//            
//            UIImage *postImage = [self imagewithURL:imageString];
//            
//            NSDictionary *caption = dict[@"caption"];
//            NSString *username;
//            NSString *captionString;
//            if(![caption isEqual:[NSNull null]])
//            {
//                captionString = caption[@"text"];
//                NSDictionary *fromUserDict = caption[@"from"];
//                username = fromUserDict[@"username"];
//            }
//            
//            else
//            {
//                captionString = @"There is no caption here";
//            }
//            
//            self.trumpPost = [[TrumpPost alloc]initWithPost:username andCaption:captionString andImage:postImage];
//            [self.posts addObject:self.trumpPost];
//        }
//    }
//    [self.tableView reloadData];
//}

-(UIImage *)imagewithURL:(NSString *)url
{
    NSURL *imgURL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:imgURL];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    UIImage *img = [UIImage imageWithData:data];
    
    return img;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_posts count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"TrumpCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    TrumpPost *post = _posts[indexPath.row];
    
    cell.textLabel.text = post.username;
    cell.detailTextLabel.text = post.caption;
    cell.imageView.image = post.trumpImage;
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
