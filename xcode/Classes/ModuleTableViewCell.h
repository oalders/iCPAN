//
//  ModuleTableViewCell.h
//  iCPAN
//
//  Created by WunderSolutions.com on 10-05-01.
//  Copyright 2010 WunderSolutions.com. All rights reserved.
//

#import "Module.h"


@interface ModuleTableViewCell : UITableViewCell {
    Module *module;

//    UIImageView *gravatarThumb;
    UILabel *nameLabel;
    UILabel *authorLabel;
    UILabel *ratingLabel;
}

@property (nonatomic, retain) Module *module;
//@property (nonatomic, retain) UIImageView *gravatarThumb;
@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *authorLabel;
@property (nonatomic, retain) UILabel *ratingLabel;

@end
