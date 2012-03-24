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
    UILabel *nameLabel;
    UILabel *authorLabel;
    UILabel *ratingLabel;
}

@property (nonatomic, strong) Module *module;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *ratingLabel;

@end
