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
    
    ///진도 초기화를 실행할 클로저
    var resetProgressClosure: (()->Void)?
    
    init(resetProgressClosure: @escaping () -> Void) {
        self.resetProgressClosure = resetProgressClosure
    }
    
    var body: some View {
        
        VStack {
            HStack(alignment: .center) {
                closeButton
                Spacer()
                Text("설정")
                    .font(.system(size: 20,weight: .semibold))
                    .foregroundStyle(Color.colorTeal02)
                Spacer()
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 30, height: 30)
                
            }
            .padding(.horizontal, 16 )
            .padding(.vertical, 8 )
            
            List {
                Section {
                    
                    HStack {
                        Button(action: {
                            self.showingAlert = true
                        }, label: {
                            Text("학습 기록 초기화")
                                .fontWeight(.semibold)
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
                
                Section {
                    HStack {
                        Button(action: {
                            EmailHelper.shared
                                .sendEmail(subject: "[Swipe 한자] 문의 & 피드백",
                                           body:
                                   """
                                   Version: \(AppStatus.fullVersion)
                                   Device: \(AppStatus.getModelName())
                                   OS: \(AppStatus.getOsVersion())
                                   
                                   """,
                                           to: "anto.wg.yang@gmail.com"  )
                        }, label: {
                            Text("문의 & 피드백")
                                .fontWeight(.semibold)
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
            
        }
        .background(Color(red: 242/255, green: 242/255, blue: 248/255).ignoresSafeArea())
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
}


#Preview {
    SettingsView(resetProgressClosure: {})
}
