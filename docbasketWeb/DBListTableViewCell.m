//
//  DBListTableViewCell.m
//  docbasketWeb
//
//  Created by jaecheol kim on 7/14/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import "DBListTableViewCell.h"
@interface DBListTableViewCell ()
{
}
@end

@implementation DBListTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setImageFromURL:(NSURL*)url
{
    [self.imageView setImageWithURL:url];
}

@end
