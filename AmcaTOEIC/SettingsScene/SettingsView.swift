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
    @State private var showsPurchaseAlert: Bool = false
    @State private var showsRestoreAlert: Bool = false
    
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
            }
        )
    }
    
    
    private var headerView: some View {
        HStack(alignment: .center) {
            closeButton
            Spacer()
            Text("설정")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.colorTeal02)
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
        .tint(.colorTeal02)
        .frame(width: 32, height: 32) // 버튼의 크기를 32x32로 조정
    }
    
    private var purchaseUpgradeSection: some View {
        Section("결제 정보") {
            if isPurchased {
                HStack {
                    Spacer()
                    Button(action: {
                        
                    }, label: {
                        Text("정식 버전 이용중")
                            .fontWeight(.regular)
                            .foregroundStyle(Color.colorTeal02)
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
                            .foregroundStyle(Color.colorTeal02)
                    })
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.colorTeal03)
                }
                
                HStack {
                    Button(action: {
                        restorePurchase()
                    }, label: {
                        Text("구매기록 복원하기")
                            .fontWeight(.regular)
                            .foregroundStyle(Color.colorTeal02)
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
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.colorTeal03)
                }
            }
            
        }
        .onAppear {
            checkPurchaseStatus()
        }
    }
    
    private var resetProgressSection: some View {
        Section {
            HStack {
                Button(action: {
                    self.showingAlert = true
                }, label: {
                    Text("학습 기록 초기화")
                        .fontWeight(.regular)
                        .foregroundStyle(Color.colorTeal02)
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
                    .foregroundColor(.colorTeal03)
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
                        .foregroundStyle(Color.colorTeal02)
                })
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.colorTeal03)
            }
            
            HStack(alignment: .center) {
                Text("버전")
                    .foregroundStyle(Color.colorTeal02)
                Spacer()
                Text(AppStatus.fullVersion)
                    .foregroundStyle(Color.colorTeal02)
            }
        }
    }
    
    func checkPurchaseStatus() {
        isPurchased = IAPManager.shared.isProductPurchased(productIdentifier: .Sample_ID)
//        isPurchased = true
    }
    
    func restorePurchase() {
        IAPManager.shared.restorePurchases { _ in
            isPurchased = IAPManager.shared.isProductPurchased(productIdentifier: .Sample_ID)
            showsRestoreAlert = true
        }
    }
    

}


#Preview {
    SettingsView(resetProgressClosure: {})
}
