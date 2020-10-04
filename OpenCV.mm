//
//  OpenCV.m
//  Sudoku Scan
//
//  Created by Emil Christopher Gjøstøl Strømsvåg on 30/07/2020.
//  Copyright © 2020 Emil Christopher Gjøstøl Strømsvåg. All rights reserved.
//

#import "OpenCV.h"
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#include <opencv2/imgproc.hpp>
#include <opencv2/core/mat.hpp>
#include <vector>

using namespace std;

@implementation OpenCV

+ (NSString *)openCVVersionString {
    return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}

// Comparison function object
bool compareContourAreas ( std::vector<cv::Point> contour1, std::vector<cv::Point> contour2 ) {
    double i = fabs( contourArea(cv::Mat(contour1)) );
    double j = fabs( contourArea(cv::Mat(contour2)) );
    return ( i < j );
}


+ (UIImage *) makeGray:(UIImage *) image rotation:(int)rotationCode{
    cv::Mat imageMat;
    cv::Mat imageInv;
    std::vector<std::vector<cv::Point>> contours;
    UIImageToMat(image, imageMat);
    
    if (imageMat.channels() == 1) return image;
    
    // Downscale: 3 times
    int downscalePercent = 50;
    int width = round(imageMat.size[1] * downscalePercent / 100);
    int height = round(imageMat.size[0] * downscalePercent / 100);
    
    cv::resize(imageMat, imageMat, cv::Size(width, height), cv::INTER_AREA);
    
    // Make grayscale
    cv::Mat grayMat;
    cv::cvtColor(imageMat, grayMat, cv::COLOR_BGR2GRAY);

    if(rotationCode < 4){
        cv::rotate(grayMat, grayMat, rotationCode);
    }
    
    // GaussionBlur
    cv::GaussianBlur(grayMat, grayMat, cv::Size(11,11), 0, 0);
    
    // Adaptive Threshold
    //imageMat.convertTo(imageMat, CV_8UC1);
    cv::adaptiveThreshold(grayMat, grayMat, 255, cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY_INV, 5, 2);
    
    // Dilate
    cv::dilate(grayMat, grayMat, cv::Mat());
    
    // Find contours
    cv::findContours(grayMat, contours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE);
    // Sort contours
    std::sort(contours.begin(), contours.end(), compareContourAreas);

    // Grab contours
    std::vector<cv::Point> biggestContour = contours[contours.size()-1];
    
    // Approximate a square to countour
    //cv::approxPolyDP(biggestContour, biggestContour, 0.1 * cv::arcLength(biggestContour, true), true);

    // Finding corners of the image
    cv::Point2f corners[4];
    cv::Point2f flatCorners[4];
    cv::Size sz = findCorners(biggestContour, corners);
    
    flatCorners[0] = cv::Point2f(0, 0);
    flatCorners[1] = cv::Point2f(sz.width, 0);
    flatCorners[2] = cv::Point2f(sz.width, sz.height);
    flatCorners[3] = cv::Point2f(0, sz.height);
    
    // Warping the image to fit the Sudoku board
    cv::Mat lambda = cv::getPerspectiveTransform(corners, flatCorners);
    cv::warpPerspective(grayMat, grayMat, lambda, sz);


    return MatToUIImage(grayMat);
}


// Find corners within the largest contour for use in performing warp transform
cv::Size findCorners(const vector<cv::Point> largestContour, cv::Point2f corners[]) {
    float dist;
    float maxDist[4] = {0, 0, 0, 0};

    cv::Moments M = cv::moments(largestContour, true);
    float cX = float(M.m10 / M.m00);
    float cY = float(M.m01 / M.m00);

    for (int i = 0; i < 4; i++) {
        maxDist[i] = 0.0f;
        corners[i] = cv::Point2f(cX, cY);
    }
    
    cv::Point2f center(cX, cY);
    
    // find the most distant point in the contour within each quadrant
    for (int i = 0; i < largestContour.size(); i++) {
        cv::Point2f p(largestContour[i].x, largestContour[i].y);
        dist = sqrt(pow(p.x - center.x, 2) + pow(p.y - center.y, 2));
        // cout << "(" << p.x << "," << p.y << ") is " << dist << " from (" << cX << "," << cY << ")" << endl;
        if (p.x < cX && p.y < cY && maxDist[0] < dist) {
            // top left
            maxDist[0] = dist;
            corners[0] = p;
        } else if (p.x > cX && p.y < cY && maxDist[1] < dist) {
            // top right
            maxDist[1] = dist;
            corners[1] = p;
        } else if (p.x > cX && p.y > cY && maxDist[2] < dist) {
            // bottom right
            maxDist[2] = dist;
            corners[2] = p;
        } else if (p.x < cX && p.y > cY && maxDist[3] < dist) {
            // bottom left
            maxDist[3] = dist;
            corners[3] = p;
        }
    }

    // determine the dimensions that we should warp this contour to
    float widthTop = sqrt(pow(corners[0].x - corners[1].x, 2) + pow(corners[0].y - corners[1].y, 2));
    float widthBottom = sqrt(pow(corners[2].x - corners[3].x, 2) + pow(corners[2].y - corners[3].y, 2));

    float heightLeft = sqrt(pow(corners[0].x - corners[3].x, 2) + pow(corners[0].y - corners[3].y, 2));
    float heightRight = sqrt(pow(corners[1].x - corners[2].x, 2) + pow(corners[1].y - corners[2].y, 2));


    return cv::Size(max(widthTop, widthBottom), max(heightLeft, heightRight));
    
    
    
}


@end
