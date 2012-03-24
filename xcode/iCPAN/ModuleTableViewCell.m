//
//  ModuleTableViewCell.m
//  iCPAN
//
//  Created by WunderSolutions.com on 10-05-01.
//  Copyright 2010 WunderSolutions.com. All rights reserved.
//

#import "ModuleTableViewCell.h"
#import "Author.h"
#import "Distribution.h"


@interface ModuleTableViewCell (SubviewFrames)
- (CGRect)_nameLabelFrame;
- (CGRect)_authorLabelFrame;
- (CGRect)_ratingLabelFrame;
@end


@implementation ModuleTableViewCell

@synthesize module, nameLabel, authorLabel, ratingLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [nameLabel setFont:[UIFont boldSystemFontOfSize:13.0]];
        [nameLabel setTextColor:[UIColor blackColor]];
        [nameLabel setHighlightedTextColor:[UIColor whiteColor]];
        [self.contentView addSubview:nameLabel];
        
        authorLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [authorLabel setFont:[UIFont systemFontOfSize:11.0]];
        authorLabel.minimumFontSize = 7.0;
        [authorLabel setTextColor:[UIColor darkGrayColor]];
        [authorLabel setHighlightedTextColor:[UIColor whiteColor]];
        authorLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:authorLabel];
        
        ratingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        ratingLabel.textAlignment = UITextAlignmentRight;
        [ratingLabel setFont:[UIFont systemFontOfSize:11.0]];
        ratingLabel.minimumFontSize = 7.0;
        [ratingLabel setTextColor:[UIColor redColor]];
        [ratingLabel setHighlightedTextColor:[UIColor whiteColor]];
        ratingLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:ratingLabel];
    }
    
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
	
    [nameLabel setFrame:[self _nameLabelFrame]];
    [authorLabel setFrame:[self _authorLabelFrame]];
    [ratingLabel setFrame:[self _ratingLabelFrame]];

}


#define EDITING_INSET       10.0
#define TEXT_LEFT_MARGIN     8.0
#define TEXT_RIGHT_MARGIN    5.0
#define RATING_WIDTH        100.0


- (CGRect)_nameLabelFrame {
    if (self.editing) {
        return CGRectMake(EDITING_INSET + TEXT_LEFT_MARGIN, 4.0, self.contentView.bounds.size.width - EDITING_INSET - TEXT_LEFT_MARGIN, 16.0);
    }
	else {
        return CGRectMake(TEXT_LEFT_MARGIN, 4.0, self.contentView.bounds.size.width - TEXT_RIGHT_MARGIN, 16.0);
    }
}


- (CGRect)_authorLabelFrame {
    if (self.editing) {
        return CGRectMake(EDITING_INSET + TEXT_LEFT_MARGIN, 22.0, self.contentView.bounds.size.width - EDITING_INSET - TEXT_LEFT_MARGIN, 16.0);
    }
	else {
        return CGRectMake(TEXT_LEFT_MARGIN, 22.0, self.contentView.bounds.size.width - TEXT_LEFT_MARGIN, 16.0);
    }
}


- (CGRect)_ratingLabelFrame {
    return CGRectMake(self.contentView.bounds.size.width - RATING_WIDTH - TEXT_RIGHT_MARGIN, 22.0, RATING_WIDTH, 16.0);
}


- (void)setModule:(Module *)newModule {

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    Author *author = (Author *)newModule.distribution.author;

	nameLabel.text = newModule.name;
	authorLabel.text = author.name;
    authorLabel.text = [authorLabel.text stringByAppendingString:@" ("];
    authorLabel.text = [authorLabel.text stringByAppendingString:author.pauseid];
    authorLabel.text = [authorLabel.text stringByAppendingString:@")"];
    if([[prefs stringForKey:@"name_preference"] isEqualToString:author.pauseid]) {
        [authorLabel setTextColor:[UIColor blueColor]];
    }
    
}

@end
