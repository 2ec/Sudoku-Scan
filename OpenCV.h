//
//  OpenCV.h
//  Sudoku Scan
//
//  Created by Emil Christopher Gjøstøl Strømsvåg on 30/07/2020.
//  Copyright © 2020 Emil Christopher Gjøstøl Strømsvåg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCV : NSObject

+ (NSString *)openCVVersionString;

+ (UIImage *) makeGray:(UIImage *)image rotation:(int)rotationCode;

@end

NS_ASSUME_NONNULL_END
