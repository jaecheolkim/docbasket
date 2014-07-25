//
//  DBControlTableViewCell.h
//  docbasketWeb
//
//  Created by jaecheol kim on 7/25/14.
//  Copyright (c) 2014 jaecheol kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBControlTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *controlTitle;
@property (weak, nonatomic) IBOutlet UILabel *controlValue;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UILabel *endLabel;
@property (weak, nonatomic) IBOutlet UISlider *controlSlider;


@end
