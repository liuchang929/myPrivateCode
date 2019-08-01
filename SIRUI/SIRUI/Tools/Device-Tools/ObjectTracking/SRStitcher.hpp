//
//  SRStitcher.hpp
//  Stitcher
//
//  Created by sirui on 2017/2/19.
//  Copyright © 2017年 sirui. All rights reserved.
//

#ifndef SRStitcher_hpp
#define SRStitcher_hpp


namespace sr {
    
    class SRStitcher
    {
    public:
        enum { ORIG_RESOL = -1 };
        enum Status
        {
            OK = 0,
            ERR_NEED_MORE_IMGS = 1,
            ERR_HOMOGRAPHY_EST_FAIL = 2,
            ERR_CAMERA_PARAMS_ADJUST_FAIL = 3
        };
        
        // SRStitcher() {}
        /** @brief Creates a SRStitcher with the default parameters.
         
         @param try_use_gpu Flag indicating whether GPU should be used whenever it's possible.
         @return SRStitcher class instance.
         */
        static SRStitcher createDefault(bool try_use_gpu = false);
        
        double registrationResol() const { return registr_resol_; }
        void setRegistrationResol(double resol_mpx) { registr_resol_ = resol_mpx; }
        
        double seamEstimationResol() const { return seam_est_resol_; }
        void setSeamEstimationResol(double resol_mpx) { seam_est_resol_ = resol_mpx; }
        
        double compositingResol() const { return compose_resol_; }
        void setCompositingResol(double resol_mpx) { compose_resol_ = resol_mpx; }
        
        double panoConfidenceThresh() const { return conf_thresh_; }
        void setPanoConfidenceThresh(double conf_thresh) { conf_thresh_ = conf_thresh; }
        
        bool waveCorrection() const { return do_wave_correct_; }
        void setWaveCorrection(bool flag) { do_wave_correct_ = flag; }
        
        cv::detail::WaveCorrectKind waveCorrectKind() const { return wave_correct_kind_; }
        void setWaveCorrectKind(cv::detail::WaveCorrectKind kind) { wave_correct_kind_ = kind; }
        
        cv::Ptr<cv::detail::FeaturesFinder> featuresFinder() { return features_finder_; }
        const cv::Ptr<cv::detail::FeaturesFinder> featuresFinder() const { return features_finder_; }
        void setFeaturesFinder(cv::Ptr<cv::detail::FeaturesFinder> features_finder)
        { features_finder_ = features_finder; }
        
        cv::Ptr<cv::detail::FeaturesMatcher> featuresMatcher() { return features_matcher_; }
        const cv::Ptr<cv::detail::FeaturesMatcher> featuresMatcher() const { return features_matcher_; }
        void setFeaturesMatcher(cv::Ptr<cv::detail::FeaturesMatcher> features_matcher)
        { features_matcher_ = features_matcher; }
        
        const cv::UMat& matchingMask() const { return matching_mask_; }
        void setMatchingMask(const cv::UMat &mask)
        {
            CV_Assert(mask.type() == CV_8U && mask.cols == mask.rows);
            matching_mask_ = mask.clone();
        }
        
        cv::Ptr<cv::detail::BundleAdjusterBase> bundleAdjuster() { return bundle_adjuster_; }
        const cv::Ptr<cv::detail::BundleAdjusterBase> bundleAdjuster() const { return bundle_adjuster_; }
        void setBundleAdjuster(cv::Ptr<cv::detail::BundleAdjusterBase> bundle_adjuster)
        { bundle_adjuster_ = bundle_adjuster; }
        
        cv::Ptr<cv::WarperCreator> warper() { return warper_; }
        const cv::Ptr<cv::WarperCreator> warper() const { return warper_; }
        void setWarper(cv::Ptr<cv::WarperCreator> creator) { warper_ = creator; }
        
        cv::Ptr<cv::detail::ExposureCompensator> exposureCompensator() { return exposure_comp_; }
        const cv::Ptr<cv::detail::ExposureCompensator> exposureCompensator() const { return exposure_comp_; }
        void setExposureCompensator(cv::Ptr<cv::detail::ExposureCompensator> exposure_comp)
        { exposure_comp_ = exposure_comp; }
        
        cv::Ptr<cv::detail::SeamFinder> seamFinder() { return seam_finder_; }
        const cv::Ptr<cv::detail::SeamFinder> seamFinder() const { return seam_finder_; }
        void setSeamFinder(cv::Ptr<cv::detail::SeamFinder> seam_finder) { seam_finder_ = seam_finder; }
        
        cv::Ptr<cv::detail::Blender> blender() { return blender_; }
        const cv::Ptr<cv::detail::Blender> blender() const { return blender_; }
        void setBlender(cv::Ptr<cv::detail::Blender> b) { blender_ = b; }
        
        /** @overload */
        Status estimateTransform(cv::InputArrayOfArrays images);
        /** @brief These functions try to match the given images and to estimate rotations of each camera.
         
         @note Use the functions only if you're aware of the stitching pipeline, otherwise use
         SRStitcher::stitch.
         
         @param images Input images.
         @param rois Region of interest rectangles.
         @return Status code.
         */
        Status estimateTransform(cv::InputArrayOfArrays images, const std::vector<std::vector<cv::Rect> > &rois);
        
        Status getWrapImageAndMask(cv::InputArrayOfArrays &images, size_t &warpCnt);
        
        
        /** @overload */
        Status stitch(cv::InputArrayOfArrays images, cv::OutputArray pano);
        /** @brief These functions try to stitch the given images.
         
         @param images Input images.
         @param rois Region of interest rectangles.
         @param pano Final pano.
         @return Status code.
         */
        Status stitch(cv::InputArrayOfArrays images, const std::vector<std::vector<cv::Rect> > &rois, cv::OutputArray pano);
        
        std::vector<int> component() const { return indices_; }
        std::vector<cv::detail::CameraParams> cameras() const { return cameras_; }
        double workScale() const { return work_scale_; }
        
    private:
        //SRStitcher() {}
        
        Status matchImages();
        Status estimateCameraParams();
        
        double registr_resol_;
        double seam_est_resol_;
        double compose_resol_;
        double conf_thresh_;
        cv::Ptr<cv::detail::FeaturesFinder> features_finder_;
        cv::Ptr<cv::detail::FeaturesMatcher> features_matcher_;
        cv::UMat matching_mask_;
        cv::Ptr<cv::detail::BundleAdjusterBase> bundle_adjuster_;
        bool do_wave_correct_;
        cv::detail::WaveCorrectKind wave_correct_kind_;
        cv::Ptr<cv::WarperCreator> warper_;
        cv::Ptr<cv::detail::ExposureCompensator> exposure_comp_;
        cv::Ptr<cv::detail::SeamFinder> seam_finder_;
        cv::Ptr<cv::detail::Blender> blender_;
        
        std::vector<cv::UMat> imgs_;
        std::vector<std::vector<cv::Rect> > rois_;
        std::vector<cv::Size> full_img_sizes_;
        std::vector<cv::detail::ImageFeatures> features_;
        std::vector<cv::detail::MatchesInfo> pairwise_matches_;
        std::vector<cv::UMat> seam_est_imgs_;
        std::vector<int> indices_;
        std::vector<cv::detail::CameraParams> cameras_;
        double work_scale_;
        double seam_scale_;
        double seam_work_aspect_;
        double warped_image_scale_;
    };
    
    cv::Ptr<SRStitcher> createStitcher(bool try_use_gpu = false);
    
    //! @} stitching
    
} // namespace sr

#endif /* SRStitcher_hpp */
