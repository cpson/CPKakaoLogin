//
//  CPKakaoLogin.swift
//  CPKakaoLogin
//
//  Created by 손창빈 on 2020/06/29.
//

import UIKit
import KakaoOpenSDK

protocol KakaoLoginDelegate {
    func onError(error: NSError?)
    func onSuccessWithToken(token: String)
    func onSuccessWithCredential(credential: Any)
}

enum KakaoLoginTypes {
    case KakaoTalk       // 카카오 톡 인증
    case KakaoStory      // 카카오 스토리 인증
    case KakaoAccount    // 카카오 계정 직접 입력
}

public class CPKakaoLogin: NSObject {
    
    private let UNKNOW_ERROR = 9999
    
    // delegate
    var delegate: KakaoLoginDelegate? = nil
    
    init(_ delegate: KakaoLoginDelegate? = nil) {
        self.delegate = delegate
    }
    
    /**
     AppDelegate에서 호출.
     */
    func applicationOpenWithKaKaoLogin(url: URL) -> Bool {
        if KOSession.isKakaoAccountLoginCallback(url) {
            return KOSession.handleOpen(url)
        }
        return false
    }
    
    func isAutomaticPeriodicRefresh(_ isAuto: Bool = true) {
        KOSession.shared()?.isAutomaticPeriodicRefresh = isAuto
    }
    
    func applicationDidEnterBackground() {
        KOSession.handleDidEnterBackground()
    }
    
    func applicationDidBecomeActive() {
        KOSession.handleDidBecomeActive()
    }
    
    /**
     deinit 시 delegate 해제.
     */
    deinit {
        delegate = nil
    }
    
    /**
     default : kakao talk
     */
    func startLoginWithAuthTypes(_ authTypes: [KakaoLoginTypes] = [.KakaoTalk]) {
        guard let kSession = KOSession.shared() else {
            return
        }
        let authTypes = self.transferAuthTypes(authTypes)
        
        kSession.close()
        kSession.open(completionHandler: { [weak self] error in
            if kSession.isOpen() {
                if let token = kSession.token?.accessToken {
                    self?.delegate?.onSuccessWithToken(token: token)
                } else {
                    let error = self?.makeError(message: "get accessToken fail")
                    self?.delegate?.onError(error: error)
                }
            } else {
                if let error = error as NSError? {
                    self?.delegate?.onError(error: error)
                    print("KAKAO login failed: \(error.localizedDescription)")
                } else {
                    self?.delegate?.onError(error: nil)
                    print("KAKAO login failed!!")
                }
            }
        }, authTypes: authTypes)
    }
    
    /**
     현재 기기에서만 로그아웃한다. 발급 받았던 토큰은 만료된다.
     */
    func logoutAndClose(_ completionHandler:@escaping ((_ success: Bool, _ error: NSError? ) -> Void) = { _, _ in }) {
        KOSession().logoutAndClose { success, error in
            if let error = error as NSError? {
                completionHandler(false, error)
                print("logoutAndClose Error : \(error.localizedDescription)")
            } else {
                completionHandler(true, nil)
            }
        }
    }
    
    /**
     연결 끊기 호출 시, 성공 또는 실패 시 이어질 동작을 정의해야 합니다.
     연결 끊기에 성공하면 앱과 사용자의 연결이 끊어지고 로그아웃되므로, 사용자를 로그인 화면으로 이동시키거나,
     화면을 로그인되지 않은 상태로 새로고침하는 등 후속 조치가 필요합니다.
     */
    func unlinkTask(_ completionHandler:@escaping ((_ success: Bool, _ error: NSError? ) -> Void) = { _, _ in }) {
        KOSessionTask.unlinkTask(completionHandler: { success, error in
            if let error = error as NSError? {
                completionHandler(false, error)
                print("unRegisterWithClear KAKAO unlinkTask Error : \(error.localizedDescription)")
            }
            KOSession.shared()?.close()
            completionHandler(true, nil)
        })
    }
    
    // MARK: - Private Methods
    private func transferAuthTypes(_ types: [KakaoLoginTypes]) -> [NSNumber] {
        var transResult = [NSNumber]()
        types.forEach { type in
            switch type {
            case .KakaoAccount:
                transResult.append(NSNumber(value: KOAuthType.account.rawValue))
                break
            case .KakaoStory:
                transResult.append(NSNumber(value: KOAuthType.story.rawValue))
                break
            case .KakaoTalk:
                transResult.append(NSNumber(value: KOAuthType.talk.rawValue))
                break
            }
        }
        return transResult
    }
    
    private func makeError(message: String) -> NSError {
        let message = "get accessToken fail"
        let detail = [NSLocalizedDescriptionKey : message]
        return NSError(domain: "CPKakaoLogin", code: UNKNOW_ERROR, userInfo: detail)
    }
}
