//
//  SRStitcher.cpp
//  Stitcher
//
//  Created by sirui on 2017/2/19.
//  Copyright © 2017年 sirui. All rights reserved.
//

#include "SRStitcher.hpp"
#import "ConvertTool.h"
#import "FileUtils.h"

#define ENABLE_LOG 1

using namespace cv;

namespace sr {
    
    SRStitcher SRStitcher::createDefault(bool try_use_gpu)
    {
        SRStitcher stitcher;
        stitcher.setRegistrationResol(0.1);
        stitcher.setCompositingResol(ORIG_RESOL);
        stitcher.setSeamEstimationResol(0.01);
        stitcher.setPanoConfidenceThresh(1);
        stitcher.setWaveCorrection(true);
        stitcher.setWaveCorrectKind(cv::detail::WAVE_CORRECT_HORIZ);
        stitcher.setFeaturesMatcher(cv::makePtr<cv::detail::BestOf2NearestMatcher>(try_use_gpu, 0.65));
        stitcher.setBundleAdjuster(cv::makePtr<cv::detail::BundleAdjusterRay>());
        
#ifdef HAVE_CUDA
        if (try_use_gpu && cuda::getCudaEnabledDeviceCount() > 0)
        {
#ifdef HAVE_OPENCV_XFEATURES2D
            stitcher.setFeaturesFinder(makePtr<detail::SurfFeaturesFinderGpu>());
#else
            stitcher.setFeaturesFinder(makePtr<detail::OrbFeaturesFinder>());
#endif
            stitcher.setWarper(makePtr<SphericalWarperGpu>());
            stitcher.setSeamFinder(makePtr<detail::GraphCutSeamFinderGpu>());
        }
        else
#endif
        {
#ifdef HAVE_OPENCV_XFEATURES2D
            stitcher.setFeaturesFinder(cv::makePtr<cv::detail::SurfFeaturesFinder>());
#else
            stitcher.setFeaturesFinder(makePtr<detail::OrbFeaturesFinder>());
#endif
            stitcher.setSeamFinder(cv::makePtr<cv::detail::NoSeamFinder>());
            stitcher.setWarper(cv::makePtr<cv::SphericalWarper>());
            
        }
        

        stitcher.setExposureCompensator(cv::detail::ExposureCompensator::createDefault(0));
//        stitcher.setBlender(cv::makePtr<cv::detail::MultiBandBlender>(try_use_gpu));
        
        return stitcher;
    }
    
    
    SRStitcher::Status SRStitcher::estimateTransform(InputArrayOfArrays images)
    {
        return estimateTransform(images, std::vector<std::vector<cv::Rect> >());
    }
    
    
    SRStitcher::Status SRStitcher::estimateTransform(cv::InputArrayOfArrays images, const std::vector<std::vector<cv::Rect> > &rois)
    {
        images.getUMatVector(imgs_);
        rois_ = rois;
        
        Status status;
        
        [[NSNotificationCenter defaultCenter]postNotificationName:PANO_PROGRESS object:@{@"progress":@(0.2), @"hint":JELocalizedString(@"Match images...", nil)}];

        
        if ((status = matchImages()) != OK)
            return status;
        
        [[NSNotificationCenter defaultCenter]postNotificationName:PANO_PROGRESS object:@{@"progress":@(0.3), @"hint":JELocalizedString(@"Estimate cameraParams...", nil)}];

        
        if ((status = estimateCameraParams()) != OK)
            return status;
        
//        for (int i = 0; i < cameras_.size(); i++)
//        {
//            cv::detail::CameraParams param = cameras_[i];
//            NSLog(@"%f", param.focal);
//        }
        
        return OK;
    }

    
    SRStitcher::Status SRStitcher::getWrapImageAndMask(cv::InputArrayOfArrays &images, size_t &warpCnt)
    {
        NSLog(@"Warping images (auxiliary)... ");
        
        Status status = estimateTransform(images);
        
        if (status != OK)
            return status;
        
        cv::UMat pano_;
        
#if ENABLE_LOG
        int64 t = getTickCount();
#endif
        
        std::vector<cv::Point> corners(imgs_.size());
        std::vector<cv::UMat> masks_warped(imgs_.size());
        std::vector<cv::UMat> images_warped(imgs_.size());
        std::vector<cv::Size> sizes(imgs_.size());
        std::vector<cv::UMat> masks(imgs_.size());
        
        warpCnt = imgs_.size();
        
        // Prepare image masks
        for (size_t i = 0; i < imgs_.size(); ++i)
        {
            masks[i].create(seam_est_imgs_[i].size(), CV_8U);
            masks[i].setTo(cv::Scalar::all(255));
        }
        
        [[NSNotificationCenter defaultCenter]postNotificationName:PANO_PROGRESS object:@{@"progress":@(0.35), @"hint":JELocalizedString(@"Warp images and their masks...", nil)}];

        // Warp images and their masks
        cv::Ptr<cv::detail::RotationWarper> w = warper_->create(float(warped_image_scale_ * seam_work_aspect_));
        for (size_t i = 0; i < imgs_.size(); ++i)
        {
            cv::Mat_<float> K;
            cameras_[i].K().convertTo(K, CV_32F);
            K(0,0) *= (float)seam_work_aspect_;
            K(0,2) *= (float)seam_work_aspect_;
            K(1,1) *= (float)seam_work_aspect_;
            K(1,2) *= (float)seam_work_aspect_;
            
            corners[i] = w->warp(seam_est_imgs_[i], K, cameras_[i].R, cv::INTER_LINEAR, cv::BORDER_CONSTANT, images_warped[i]);
            sizes[i] = images_warped[i].size();
            
            [[NSNotificationCenter defaultCenter]postNotificationName:PANO_PROGRESS object:@{@"progress":@(0.35+i*0.02), @"hint":[NSString stringWithFormat:JELocalizedString(@"Warping %zu/%zu image...", nil), i, imgs_.size()]}];

            w->warp(masks[i], K, cameras_[i].R, cv::INTER_NEAREST, cv::BORDER_CONSTANT, masks_warped[i]);
        }
        
        std::vector<cv::UMat> images_warped_f(imgs_.size());
        for (size_t i = 0; i < imgs_.size(); ++i)
            images_warped[i].convertTo(images_warped_f[i], CV_32F);
        

        NSLog(@"%@", [NSString stringWithFormat:@"Warping images, time: %f sec", ((getTickCount() - t) / getTickFrequency())]);
        
        // Find seams
        exposure_comp_->feed(corners, images_warped, masks_warped);
        seam_finder_->find(images_warped_f, corners, masks_warped);
        
        // Release unused memory
        seam_est_imgs_.clear();
        images_warped.clear();
        images_warped_f.clear();
        masks.clear();
        

        NSLog(@"Compositing...");
#if ENABLE_LOG
        t = getTickCount();
#endif
        
        cv::UMat img_warped, img_warped_s;
        cv::UMat dilated_mask, seam_mask, mask, mask_warped;
        
        //double compose_seam_aspect = 1;
        double compose_work_aspect = 1;
        
        double compose_scale = 1;
        bool is_compose_scale_set = false;
        
        cv::UMat full_img, img;
        NSMutableArray *nsconners = [NSMutableArray array];
        NSMutableArray *nssizes = [NSMutableArray array];

        for (size_t img_idx = 0; img_idx < imgs_.size(); ++img_idx)
        {
            @autoreleasepool {
            
            [[NSNotificationCenter defaultCenter]postNotificationName:PANO_PROGRESS object:@{@"progress":@(0.55+0.02*img_idx), @"hint":[NSString stringWithFormat:JELocalizedString(@"Compositing %zu/%zu images...", nil), img_idx, imgs_.size()]}];

            NSLog(@"%@", [NSString stringWithFormat:@"Compositing image #%d", indices_[img_idx] + 1] );
#if ENABLE_LOG
            int64 compositing_t = getTickCount();
#endif
            
            // Read image and resize it if necessary
            full_img = imgs_[img_idx];
            if (!is_compose_scale_set)
            {
                if (compose_resol_ > 0)
                    compose_scale = std::min(1.0, std::sqrt(compose_resol_ * 1e6 / full_img.size().area()));
                is_compose_scale_set = true;
                
                // Compute relative scales
                //compose_seam_aspect = compose_scale / seam_scale_;
                compose_work_aspect = compose_scale / work_scale_;
                
                // Update warped image scale
                warped_image_scale_ *= static_cast<float>(compose_work_aspect);
                w = warper_->create((float)warped_image_scale_);
                
                // Update corners and sizes
                for (size_t i = 0; i < imgs_.size(); ++i)
                {
                    // Update intrinsics
                    cameras_[i].focal *= compose_work_aspect;
                    cameras_[i].ppx *= compose_work_aspect;
                    cameras_[i].ppy *= compose_work_aspect;
                    
                    // Update corner and size
                    cv::Size sz = full_img_sizes_[i];
                    if (std::abs(compose_scale - 1) > 1e-1)
                    {
                        sz.width = cvRound(full_img_sizes_[i].width * compose_scale);
                        sz.height = cvRound(full_img_sizes_[i].height * compose_scale);
                    }
                    
                    cv::Mat K;
                    cameras_[i].K().convertTo(K, CV_32F);
                    cv::Rect roi = w->warpRoi(sz, K, cameras_[i].R);
                    corners[i] = roi.tl();
                    sizes[i] = roi.size();
                }
            }
            if (std::abs(compose_scale - 1) > 1e-1)
            {
#if ENABLE_LOG
                int64 resize_t = getTickCount();
#endif
                resize(full_img, img, cv::Size(), compose_scale, compose_scale);
                NSLog(@"%@", [NSString stringWithFormat:@"resize time: %f sec", ((getTickCount() - resize_t) / getTickFrequency())]);
            }
            else
                img = full_img;
            full_img.release();
            cv::Size img_size = img.size();
            
            NSLog(@"%@", [NSString stringWithFormat:@"after resize time: %f sec", ((getTickCount() - compositing_t) / getTickFrequency())]);
            
            cv::Mat K;
            cameras_[img_idx].K().convertTo(K, CV_32F);
            
#if ENABLE_LOG
            int64 pt = getTickCount();
#endif
            // Warp the current image
            w->warp(img, K, cameras_[img_idx].R, cv::INTER_LINEAR, cv::BORDER_CONSTANT, img_warped);
            NSLog(@"%@", [NSString stringWithFormat:@"warp the current image:  %f sec", ((getTickCount() - pt) / getTickFrequency())]);

#if ENABLE_LOG
            pt = getTickCount();
#endif
            
            // Warp the current image mask
            mask.create(img_size, CV_8U);
            mask.setTo(cv::Scalar::all(255));
            w->warp(mask, K, cameras_[img_idx].R, cv::INTER_NEAREST, cv::BORDER_CONSTANT, mask_warped);
            NSLog(@"%@", [NSString stringWithFormat:@"warp the current image mask:  %f sec", ((getTickCount() - pt) / getTickFrequency())]);

#if ENABLE_LOG
            pt = getTickCount();
#endif
            
            // Compensate exposure
            exposure_comp_->apply((int)img_idx, corners[img_idx], img_warped, mask_warped);
            NSLog(@"%@", [NSString stringWithFormat:@"compensate exposure:  %f sec", ((getTickCount() - pt) / getTickFrequency())]);
#if ENABLE_LOG
            pt = getTickCount();
#endif
            
            img_warped.convertTo(img_warped_s, CV_16S);
            img_warped.release();
            img.release();
            mask.release();
            
            // Make sure seam mask has proper size
            dilate(masks_warped[img_idx], dilated_mask, cv::Mat());
            resize(dilated_mask, seam_mask, mask_warped.size());
            
            bitwise_and(seam_mask, mask_warped, mask_warped);
            
            NSLog(@"%@", [NSString stringWithFormat:@"other:  %f sec", ((getTickCount() - pt) / getTickFrequency())]);
            
            cv::UMat matToStorage;
            img_warped_s.convertTo(matToStorage, 0);
            img_warped_s.release();
            UIImage *img = [ConvertTool imageFromUMat:matToStorage];
            UIImage *mask = [ConvertTool imageFromUMat:mask_warped];
//
            matToStorage.release();
            mask_warped.release();
            seam_mask.release();


            NSData *imageData = UIImagePNGRepresentation(img);
            NSData *maskData = UIImagePNGRepresentation(mask);
            [imageData writeToFile:[FileUtils warpImagePath:img_idx] atomically:YES];
            [maskData writeToFile:[FileUtils maskImagePath:img_idx] atomically:YES];
        
            [nsconners addObject:[NSValue valueWithCGPoint:CGPointMake(corners[img_idx].x, corners[img_idx].y)]];
            [nssizes addObject:[NSValue valueWithCGSize:CGSizeMake(sizes[img_idx].width, sizes[img_idx].height)]];
            }
        }

        [NSKeyedArchiver archiveRootObject:nsconners toFile:[FileUtils connersPath]];
        [NSKeyedArchiver archiveRootObject:nssizes toFile:[FileUtils sizesPath]];

        return OK;
    }
    
    
    SRStitcher::Status SRStitcher::matchImages()
    {
        if ((int)imgs_.size() < 2)
        {
//            LOGLN("Need more images");
            return ERR_NEED_MORE_IMGS;
        }
        
        work_scale_ = 1;
        seam_work_aspect_ = 1;
        seam_scale_ = 1;
        bool is_work_scale_set = false;
        bool is_seam_scale_set = false;
        UMat full_img, img;
        features_.resize(imgs_.size());
        seam_est_imgs_.resize(imgs_.size());
        full_img_sizes_.resize(imgs_.size());
        
//        LOGLN("Finding features...");
#if ENABLE_LOG
        int64 t = getTickCount();
#endif
        
        std::vector<UMat> feature_find_imgs(imgs_.size());
        std::vector<std::vector<cv::Rect> > feature_find_rois(rois_.size());
        
        for (size_t i = 0; i < imgs_.size(); ++i)
        {
            full_img = imgs_[i];
            full_img_sizes_[i] = full_img.size();
            
            if (registr_resol_ < 0)
            {
                img = full_img;
                work_scale_ = 1;
                is_work_scale_set = true;
            }
            else
            {
                if (!is_work_scale_set)
                {
                    work_scale_ = std::min(1.0, std::sqrt(registr_resol_ * 1e6 / full_img.size().area()));
                    is_work_scale_set = true;
                }
                resize(full_img, img, cv::Size(), work_scale_, work_scale_);
            }
            if (!is_seam_scale_set)
            {
                seam_scale_ = std::min(1.0, std::sqrt(seam_est_resol_ * 1e6 / full_img.size().area()));
                seam_work_aspect_ = seam_scale_ / work_scale_;
                is_seam_scale_set = true;
            }
            
            if (rois_.empty())
                feature_find_imgs[i] = img;
            else
            {
                feature_find_rois[i].resize(rois_[i].size());
                for (size_t j = 0; j < rois_[i].size(); ++j)
                {
                    cv::Point tl(cvRound(rois_[i][j].x * work_scale_), cvRound(rois_[i][j].y * work_scale_));
                    cv::Point br(cvRound(rois_[i][j].br().x * work_scale_), cvRound(rois_[i][j].br().y * work_scale_));
                    feature_find_rois[i][j] = cv::Rect(tl, br);
                }
                feature_find_imgs[i] = img;
            }
            features_[i].img_idx = (int)i;
//            LOGLN("Features in image #" << i+1 << ": " << features_[i].keypoints.size());
            
            resize(full_img, img, cv::Size(), seam_scale_, seam_scale_);
            seam_est_imgs_[i] = img.clone();
        }
        
        // find features possibly in parallel
        if (rois_.empty())
            (*features_finder_)(feature_find_imgs, features_);
        else
            (*features_finder_)(feature_find_imgs, features_, feature_find_rois);
        
        // Do it to save memory
        features_finder_->collectGarbage();
        full_img.release();
        img.release();
        feature_find_imgs.clear();
        feature_find_rois.clear();
        
//        LOGLN("Finding features, time: " << ((getTickCount() - t) / getTickFrequency()) << " sec");
        
//        LOG("Pairwise matching");
#if ENABLE_LOG
        t = getTickCount();
#endif
        (*features_matcher_)(features_, pairwise_matches_, matching_mask_);
        features_matcher_->collectGarbage();
//        LOGLN("Pairwise matching, time: " << ((getTickCount() - t) / getTickFrequency()) << " sec");
        
        // Leave only images we are sure are from the same panorama
        indices_ = detail::leaveBiggestComponent(features_, pairwise_matches_, (float)conf_thresh_);
        std::vector<UMat> seam_est_imgs_subset;
        std::vector<UMat> imgs_subset;
        std::vector<cv::Size> full_img_sizes_subset;
        for (size_t i = 0; i < indices_.size(); ++i)
        {
            imgs_subset.push_back(imgs_[indices_[i]]);
            seam_est_imgs_subset.push_back(seam_est_imgs_[indices_[i]]);
            full_img_sizes_subset.push_back(full_img_sizes_[indices_[i]]);
        }
        seam_est_imgs_ = seam_est_imgs_subset;
        imgs_ = imgs_subset;
        full_img_sizes_ = full_img_sizes_subset;
        
        if ((int)imgs_.size() < 2)
        {
//            LOGLN("Need more images");
            return ERR_NEED_MORE_IMGS;
        }
        
        return OK;
    }
    
    
    SRStitcher::Status SRStitcher::estimateCameraParams()
    {
        /* TODO OpenCV ABI 4.x
         get rid of this dynamic_cast hack and use estimator_
         */
        Ptr<detail::Estimator> estimator;
        if (dynamic_cast<detail::AffineBestOf2NearestMatcher*>(features_matcher_.get()))
            estimator = makePtr<detail::AffineBasedEstimator>();
        else
            estimator = makePtr<detail::HomographyBasedEstimator>();
        
        if (!(*estimator)(features_, pairwise_matches_, cameras_))
            return ERR_HOMOGRAPHY_EST_FAIL;
        
        for (size_t i = 0; i < cameras_.size(); ++i)
        {
            Mat R;
            cameras_[i].R.convertTo(R, CV_32F);
            cameras_[i].R = R;
            //LOGLN("Initial intrinsic parameters #" << indices_[i] + 1 << ":\n " << cameras_[i].K());
        }
        
        bundle_adjuster_->setConfThresh(conf_thresh_);
        if (!(*bundle_adjuster_)(features_, pairwise_matches_, cameras_))
            return ERR_CAMERA_PARAMS_ADJUST_FAIL;
        
        // Find median focal length and use it as final image scale
        std::vector<double> focals;
        for (size_t i = 0; i < cameras_.size(); ++i)
        {
            //LOGLN("Camera #" << indices_[i] + 1 << ":\n" << cameras_[i].K());
            focals.push_back(cameras_[i].focal);
        }
        
        std::sort(focals.begin(), focals.end());
        if (focals.size() % 2 == 1)
            warped_image_scale_ = static_cast<float>(focals[focals.size() / 2]);
        else
            warped_image_scale_ = static_cast<float>(focals[focals.size() / 2 - 1] + focals[focals.size() / 2]) * 0.5f;
        
        if (do_wave_correct_)
        {
            std::vector<Mat> rmats;
            for (size_t i = 0; i < cameras_.size(); ++i)
                rmats.push_back(cameras_[i].R.clone());
            detail::waveCorrect(rmats, wave_correct_kind_);
            for (size_t i = 0; i < cameras_.size(); ++i)
                cameras_[i].R = rmats[i];
        }
        
        return OK;
    }
    
    
    cv::Ptr<SRStitcher> createStitcher(bool try_use_gpu)
    {
        cv::Ptr<SRStitcher> stitcher = cv::makePtr<SRStitcher>();
        stitcher->setRegistrationResol(0.6);
        stitcher->setSeamEstimationResol(0.1);
        stitcher->setCompositingResol(SRStitcher::ORIG_RESOL);
        stitcher->setPanoConfidenceThresh(1);
        stitcher->setWaveCorrection(true);
        stitcher->setWaveCorrectKind(cv::detail::WAVE_CORRECT_HORIZ);
        stitcher->setFeaturesMatcher(cv::makePtr<cv::detail::BestOf2NearestMatcher>(try_use_gpu));
        stitcher->setBundleAdjuster(cv::makePtr<cv::detail::BundleAdjusterRay>());
        
#ifdef HAVE_CUDA
        if (try_use_gpu && cuda::getCudaEnabledDeviceCount() > 0)
        {
#ifdef HAVE_OPENCV_NONFREE
            stitcher->setFeaturesFinder(makePtr<detail::SurfFeaturesFinderGpu>());
#else
            stitcher->setFeaturesFinder(makePtr<detail::OrbFeaturesFinder>());
#endif
            stitcher->setWarper(makePtr<SphericalWarperGpu>());
            stitcher->setSeamFinder(makePtr<detail::GraphCutSeamFinderGpu>());
        }
        else
#endif
        {
#ifdef HAVE_OPENCV_NONFREE
            stitcher->setFeaturesFinder(cv::makePtr<cv::detail::SurfFeaturesFinder>());
#else
            stitcher->setFeaturesFinder(cv::makePtr<cv::detail::OrbFeaturesFinder>());
#endif
            stitcher->setWarper(cv::makePtr<cv::SphericalWarper>());
            stitcher->setSeamFinder(cv::makePtr<cv::detail::GraphCutSeamFinder>(cv::detail::GraphCutSeamFinderBase::COST_COLOR));
        }
        
        stitcher->setExposureCompensator(cv::makePtr<cv::detail::BlocksGainCompensator>());
        stitcher->setBlender(cv::makePtr<cv::detail::MultiBandBlender>(try_use_gpu));
        
        return stitcher;
    }
} // namespace cv
