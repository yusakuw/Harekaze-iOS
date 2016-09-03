/**
 *
 * SettingsTableViewController.swift
 * Harekaze
 * Created by Yuki MIZUNO on 2016/08/06.
 * 
 * Copyright (c) 2016, Yuki MIZUNO
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 * 
 * 3. Neither the name of the copyright holder nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

import UIKit
import Material
import Crashlytics

class SettingsTableViewController: UITableViewController {

	// MARK: - Private instance fileds
	private let sectionHeaderHeight: CGFloat = 48
	private let sectionTitles = ["Chinachu", "Playback/Download", "Player"]
	private var statusBarView: MaterialView!
	private var closeButton: IconButton!

	// MARK: - Interface Builder outlets
	@IBOutlet weak var chinachuWUIAddressLabel: UILabel!
	@IBOutlet weak var chinachuAuthenticationLabel: UILabel!
	@IBOutlet weak var chinachuTranscodingLabel: UILabel!
	@IBOutlet weak var videoSizeLabel: UILabel!
	@IBOutlet weak var videoQualityLabel: UILabel!
	@IBOutlet weak var audioQualityLabel: UILabel!
	@IBOutlet weak var transcodeSwitch: MaterialSwitch!
	@IBOutlet weak var videoSizeTitleLabel: UILabel!
	@IBOutlet weak var videoQualityTitleLabel: UILabel!
	@IBOutlet weak var audioQualityTitleLabel: UILabel!
	@IBOutlet weak var oneFingerSwipeActionLabel: UILabel!

	// MARK: - View initialization

	override func viewDidLoad() {
        super.viewDidLoad()
		reloadSettingsValue()
		transcodeSwitch.on = ChinachuAPI.transcode

		// Set navigation title
		navigationItem.title = "Settings"
		navigationItem.titleLabel.textAlignment = .Left
		navigationItem.titleLabel.font = RobotoFont.mediumWithSize(20)
		navigationItem.titleLabel.textColor = MaterialColor.white

		// Set status bar
		statusBarView = MaterialView()
		statusBarView.zPosition = 3000
		statusBarView.restorationIdentifier = "StatusBarView"
		statusBarView.backgroundColor = MaterialColor.black.colorWithAlphaComponent(0.12)
		self.navigationController?.view.layout(statusBarView).top(0).horizontally().height(20)

		// Set navigation bar buttons
		closeButton = IconButton()
		closeButton.setImage(UIImage(named: "ic_close_white"), forState: .Normal)
		closeButton.setImage(UIImage(named: "ic_close_white"), forState: .Highlighted)
		closeButton.addTarget(self, action: #selector(handleCloseButton), forControlEvents: .TouchUpInside)

		navigationItem.leftControls = [closeButton]
    }

	// MARK: - View deinitialization
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		Answers.logCustomEventWithName("Config transcode info", customAttributes: [
			"transcode": ChinachuAPI.transcode,
			"video resolution": ChinachuAPI.videoResolution,
			"video bitrate": ChinachuAPI.videoBitrate,
			"audio bitrate": ChinachuAPI.audioBitrate
			])
	}

	// MARK: - Memory/resource management

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
	}

	// MARK: - Event handler

	internal func handleCloseButton() {
		self.dismissViewControllerAnimated(true, completion: nil)
	}

	func reloadSettingsValue() {
		chinachuWUIAddressLabel.text = ChinachuAPI.wuiAddress
		chinachuAuthenticationLabel.text = ChinachuAPI.username == "" ? "(none)" : ChinachuAPI.username

		chinachuTranscodingLabel.text = ChinachuAPI.transcode ? "MP4" : "(none)"
		videoSizeTitleLabel.textColor = ChinachuAPI.transcode ? MaterialColor.darkText.primary : MaterialColor.darkText.others
		videoQualityTitleLabel.textColor = ChinachuAPI.transcode ? MaterialColor.darkText.primary : MaterialColor.darkText.others
		audioQualityTitleLabel.textColor = ChinachuAPI.transcode ? MaterialColor.darkText.primary : MaterialColor.darkText.others
		videoSizeLabel.textColor = ChinachuAPI.transcode ? MaterialColor.darkText.secondary : MaterialColor.darkText.others
		videoQualityLabel.textColor = ChinachuAPI.transcode ? MaterialColor.darkText.secondary : MaterialColor.darkText.others
		audioQualityLabel.textColor = ChinachuAPI.transcode ? MaterialColor.darkText.secondary : MaterialColor.darkText.others

		switch ChinachuAPI.videoResolution {
		case "1920x1080":
			videoSizeLabel.text = "Full HD - 1080p"
		case "1280x720":
			videoSizeLabel.text = "HD - 720p"
		case "853x480":
			videoSizeLabel.text = "SD - 480p"
		case let resolution:
			videoSizeLabel.text = resolution
		}

		switch ChinachuAPI.videoBitrate {
		case let bitrate where bitrate >= 1024:
			videoQualityLabel.text = "H.264 \(Int(bitrate / 1024))Mbps"
		case let bitrate:
			videoQualityLabel.text = "H.264 \(bitrate)kbps"
		}

		audioQualityLabel.text = "AAC \(ChinachuAPI.audioBitrate)kbps"
		
		switch NSUserDefaults().integerForKey("OneFingerHorizontalSwipeMode") {
		case 0:
			oneFingerSwipeActionLabel.text = "Change playback speed"
		case 1:
			oneFingerSwipeActionLabel.text = "Seek +/- 30 seconds"
		default:
			oneFingerSwipeActionLabel.text = "No action"
		}
	}

	// MARK: - Interface Builder actions
	@IBAction func toggleTranscodingSwitch(sender: MaterialSwitch) {
		ChinachuAPI.transcode = sender.on
		reloadSettingsValue()
	}

	// MARK: - Layout methods

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		statusBarView.hidden = MaterialDevice.isLandscape && .iPhone == MaterialDevice.type
	}

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionTitles.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return 2
		case 1:
			return 4
		case 2:
			return 1
		default:
			return 0
		}
    }

	override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerView = UIView()
		let sectionLabel = UILabel()

		sectionLabel.text = sectionTitles[section]
		sectionLabel.font = RobotoFont.mediumWithSize(14)
		sectionLabel.textColor = MaterialColor.blue.accent1
		headerView.backgroundColor = MaterialColor.white
		headerView.layout(sectionLabel).topLeft(top: 16, left: 16).right(16).height(20)

		return headerView
	}

	override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return sectionHeaderHeight
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		switch (indexPath.section, indexPath.row) {
		case (0, 0):
			let wuiSelectionDialog = ChinachuWUISelectionViewController(title: "Select Chinachu WUI:")

			let cancelAction = MaterialAlertAction(title: "CANCEL", style: .Cancel, handler: {(action: MaterialAlertAction!) -> Void in
				wuiSelectionDialog.dismissViewControllerAnimated(true, completion: nil)
			})
			wuiSelectionDialog.addAction(cancelAction)

			presentViewController(wuiSelectionDialog, animated: true, completion: nil)
		case (0, 1):
			let chinachuAuthenticationDialog = ChinachuAuthenticationAlertViewController(title: "Authentication")
			
			let cancelAction = MaterialAlertAction(title: "CANCEL", style: .Cancel, handler: {(action: MaterialAlertAction!) -> Void in
				chinachuAuthenticationDialog.view.endEditing(false)
				chinachuAuthenticationDialog.dismissViewControllerAnimated(true, completion: nil)
			})
			chinachuAuthenticationDialog.addAction(cancelAction)

			let saveAction = MaterialAlertAction(title: "SAVE", style: .Default, handler: {(action: MaterialAlertAction!) -> Void in
				chinachuAuthenticationDialog.saveAuthentication()
				self.reloadSettingsValue()
				chinachuAuthenticationDialog.dismissViewControllerAnimated(true, completion: nil)
			})
			chinachuAuthenticationDialog.addAction(saveAction)

			presentViewController(chinachuAuthenticationDialog, animated: true, completion: nil)
		case (1, let row):
			if !ChinachuAPI.transcode {
				return
			}
			let title: String
			let mode: ValueSelectionMode
			switch row {
			case 1:
				title = "Select Video Size:"
				mode = .VideoSize
			case 2:
				title = "Select Video Quality:"
				mode = .VideoQuality
			case 3:
				title = "Select Audio Quality:"
				mode = .AudioQuality
			default:
				return
			}

			let wuiSelectionDialog = SettingValueSelectionViewController(title: title, mode: mode)

			let cancelAction = MaterialAlertAction(title: "CANCEL", style: .Cancel, handler: {(action: MaterialAlertAction!) -> Void in
				wuiSelectionDialog.dismissViewControllerAnimated(true, completion: nil)
			})
			wuiSelectionDialog.addAction(cancelAction)

			presentViewController(wuiSelectionDialog, animated: true, completion: nil)
		case (2, 0):
			let modeSelectionDialog = SettingValueSelectionViewController(title: "Select Swipe Mode:", mode: .OneFingerHorizontalSwipeMode)
			
			let cancelAction = MaterialAlertAction(title: "CANCEL", style: .Cancel, handler: {(action: MaterialAlertAction!) -> Void in
				modeSelectionDialog.dismissViewControllerAnimated(true, completion: nil)
			})
			modeSelectionDialog.addAction(cancelAction)
			
			presentViewController(modeSelectionDialog, animated: true, completion: nil)

		default:break
		}
	}

	// MARK: - Scroll view
	override func scrollViewDidScroll(scrollView: UIScrollView) {
		let offset = scrollView.contentOffset

		// Disable floating section header
		if offset.y <= sectionHeaderHeight && offset.y > 0 {
			scrollView.contentInset = UIEdgeInsets(top: -offset.y, left: 0, bottom: 0, right: 0)
		} else if offset.y >= sectionHeaderHeight {
			scrollView.contentInset = UIEdgeInsets(top: -sectionHeaderHeight, left: 0, bottom: 0, right: 0)
		}
	}


}
