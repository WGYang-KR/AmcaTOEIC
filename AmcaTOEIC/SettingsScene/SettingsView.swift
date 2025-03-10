//
//  SettingsView.swift
//  SwipeHanja
//
//  Created by Anto-Yang on 5/4/24.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAlert = false
    
    @State private var isPurchased: Bool = false
    @State private var showsGuideAlert: Bool = false
    @State private var showsPurchaseAlert: Bool = false
    @State private var showsRestoreAlert: Bool = false
    @State private var showsRestoreAlertFailed: Bool = false
    
    ///진도 초기화를 실행할 클로저
    var resetProgressClosure: (()->Void)?
    
    init(resetProgressClosure: @escaping () -> Void) {
        self.resetProgressClosure = resetProgressClosure
    }
    
    var body: some View {
        ZStack {
            VStack {
                headerView
                settingsList
            }
            .background(Color.colorSystemListBackground)
        }
        .overlay(
            Group {
                if showsPurchaseAlert {
                    PurchasePopUpViewControllerWrapper(isPresented: $showsPurchaseAlert)
                        .background(Color.clear) // SwiftUI에서 반투명 배경 추가
                        .edgesIgnoringSafeArea(.all)
                }
                
                if showsGuideAlert {
                    GuidePopUpViewControllerWrapper(isPresented: $showsGuideAlert)
                        .background(Color.clear)
                        .edgesIgnoringSafeArea(.all)
                }
            }
        )
        .onReceive(NotificationCenter.default.publisher(for: NotiName.purchaseCompleted)) { _ in
            checkPurchaseStatus()
        }
    }
    
    
    private var headerView: some View {
        HStack(alignment: .center) {
            closeButton
            Spacer()
            Text("설정")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.textSecondary)
            Spacer()
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 30, height: 30)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    private var settingsList: some View {
        List {
            resetProgressSection
            purchaseUpgradeSection
            contactSection
        }
    }
    
    
    private var closeButton: some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Image(systemName: "xmark")
                .resizable() // 이미지 크기를 조정하기 위해 resizable modifier 추가
                .aspectRatio(contentMode: .fit) // 원본 이미지의 비율을 유지하도록 함
                .frame(height: 20) // 이미지의 크기를 24x24로 조정
        }
        .tint(.textSecondary)
        .frame(width: 32, height: 32) // 버튼의 크기를 32x32로 조정
    }
    
    private var purchaseUpgradeSection: some View {
        Section("결제 정보") {
            if isPurchased {
                HStack {
                    Spacer()
                    Button(action: {
                        
                    }, label: {
                        Text("정식 버전 구매 완료")
                            .fontWeight(.regular)
                            .foregroundStyle(Color.textTertiary)
                    })
                    .disabled(true)
                    Spacer()
                }
           
            } else {
                HStack {
                    Button(action: {
                        self.showsPurchaseAlert = true
                    }, label: {
                        Text("정식 버전 구매하기")
                            .fontWeight(.regular)
                            .foregroundStyle(Color.textSecondary)
                    })
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.textTertiary)
                }
                
                HStack {
                    Button(action: {
                        restorePurchase()
                    }, label: {
                        Text("구매기록 복원하기")
                            .fontWeight(.regular)
                            .foregroundStyle(Color.textSecondary)
                    })
                    .alert(isPresented: $showsRestoreAlert) {
                        Alert(
                            title: Text("구매기록이 복원되었습니다."),
                            dismissButton: .default(Text("확인"), action: {
                                showsRestoreAlert = false
                            })
                        )
                    }
                   
                    
                    Spacer()
                        .alert(isPresented: $showsRestoreAlertFailed) {
                            Alert(
                                title: Text("구매기록 복원에 실패했습니다."),
                                dismissButton: .default(Text("확인"), action: {
                                    showsRestoreAlertFailed = false
                                })
                            )
                        }
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.textTertiary)
                }
            }
            
        }
        .onAppear {
            checkPurchaseStatus()
        }
    }
    
    private var resetProgressSection: some View {
        Section("학습") {
            
            HStack {
                Button(action: {
                    self.showsGuideAlert = true
                }, label: {
                    Text("암키카드 학습법")
                        .fontWeight(.regular)
                        .foregroundStyle(Color.textSecondary)
                })
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.textTertiary)
            }
            
            HStack {
                Button(action: {
                    self.showingAlert = true
                }, label: {
                    Text("학습 기록 초기화")
                        .fontWeight(.regular)
                        .foregroundStyle(Color.textSecondary)
                })
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text("모든 학습기록을 초기화할까요?"),
                        primaryButton: .default(Text("확인"), action: {
                            resetProgressClosure?()
                        }),
                        secondaryButton: .cancel(Text("취소"))
                    )
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.textTertiary)
            }
        }
    }
    
    private var contactSection: some View {
        Section {
            HStack {
                Button(action: {
                    EmailHelper.shared
                        .sendEmail(subject: "[암카 토익] 문의 & 피드백",
                                   body: """
                                    Version: \(AppStatus.fullVersion)
                                    Device: \(AppStatus.getModelName())
                                    OS: \(AppStatus.getOsVersion())
                                    """,
                                   to: "anto.wg.yang@gmail.com")
                }, label: {
                    Text("문의 & 피드백")
                        .fontWeight(.regular)
                        .foregroundStyle(Color.textSecondary)
                })
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.textTertiary)
            }
            
            HStack(alignment: .center) {
                Text("버전")
                    .foregroundStyle(Color.textSecondary)
                Spacer()
                Text(AppStatus.fullVersion)
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }
    
    func checkPurchaseStatus() {
        isPurchased = IAPManager.shared.isProductPurchased()
    }
    
    func restorePurchase() {
        LoadingIndicator.showLoadingView()
        IAPManager.shared.restorePurchases { result in
            isPurchased = IAPManager.shared.isProductPurchased()
            LoadingIndicator.hideLoadingView()
            switch result {
            case .success:
                showsRestoreAlert = true
            case .failure:
                showsRestoreAlertFailed = true
            }
        }
    }

}


#Preview {
    SettingsView(resetProgressClosure: {})
}
