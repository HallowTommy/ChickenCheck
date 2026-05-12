import SwiftUI

struct CustomizeScene: View {
    @EnvironmentObject private var coop: CoopJournal

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    preview
                    Text("customize.subtitle")
                        .font(AppFont.body(14))
                        .foregroundStyle(AppColor.navyText.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    accessoryGrid
                    nameField
                    Text("customize.note")
                        .font(AppFont.caption(11))
                        .foregroundStyle(AppColor.navyText.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 22)
                        .padding(.bottom, 24)
                }
                .padding(.top, 8)
            }
            .appBackdrop()
            .navigationTitle("customize.title")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var preview: some View {
        ZStack(alignment: .bottom) {
            Image("customize_stage")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            ChickenView(pose: .idle, accessory: coop.accessory, size: 170)
                .offset(y: 6)
        }
        .padding(.horizontal, 22)
    }

    private var accessoryGrid: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        return LazyVGrid(columns: columns, spacing: 14) {
            ForEach(Accessory.allCases) { item in
                AccessoryTile(
                    item: item,
                    isOn: coop.accessory == item
                ) {
                    withAnimation(.bouncy(duration: 0.45, extraBounce: 0.2)) {
                        coop.switchAccessory(item)
                    }
                }
            }
        }
        .padding(.horizontal, 22)
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("customize.name.title")
                .font(AppFont.body(14, weight: .heavy))
                .foregroundStyle(AppColor.navyText)
            TextField(LocalizedStringKey("customize.name.placeholder"), text: Binding(
                get: { coop.chickenName },
                set: { coop.renameChicken(String($0.prefix(20))) }
            ))
            .font(AppFont.body(15))
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.white).shadow(color: AppColor.navyText.opacity(0.05), radius: 4, x: 0, y: 2))
        }
        .padding(.horizontal, 22)
    }
}

private struct AccessoryTile: View {
    let item: Accessory
    let isOn: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white)
                        .frame(height: 90)
                    ChickenView(pose: .idle, accessory: item, size: 70, isFloating: false)
                }
                Text(LocalizedStringKey(item.labelKey))
                    .font(AppFont.caption(12))
                    .foregroundStyle(.white)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity)
                    .background(
                        Capsule().fill(tileColor)
                    )
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(isOn ? AppColor.streakGold.opacity(0.2) : Color.white.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(isOn ? AppColor.streakGold : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(BouncyPressStyle())
    }

    private var tileColor: Color {
        switch item {
        case .none: return AppColor.navyText.opacity(0.4)
        case .bow: return AppColor.warmOrange
        case .hat: return AppColor.skyBlue
        case .glasses: return AppColor.grassGreen
        }
    }
}
