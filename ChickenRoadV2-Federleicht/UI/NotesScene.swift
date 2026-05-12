import SwiftUI

struct NotesScene: View {
    @EnvironmentObject private var coop: CoopJournal
    @State private var sheet: NoteSheetMode?

    var body: some View {
        NavigationStack {
            Group {
                if coop.notes.isEmpty {
                    empty
                } else {
                    list
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .appBackdrop()
            .navigationTitle("notes.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { sheet = .create } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22, weight: .heavy))
                            .foregroundStyle(AppColor.warmOrange)
                    }
                }
            }
            .sheet(item: $sheet) { mode in
                NoteEditor(initial: editorSeed(mode)) { value, isNew in
                    if isNew {
                        coop.appendNote(value)
                    } else {
                        coop.updateNote(value)
                    }
                }
                .presentationDetents([.medium, .large])
            }
        }
    }

    private var list: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(coop.notes) { note in
                    Button { sheet = .edit(note.id) } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(LocalizedStringKey(note.category.titleKey))
                                    .font(AppFont.caption(11))
                                    .foregroundStyle(note.category.accentColor)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Capsule().fill(note.category.accentColor.opacity(0.18)))
                                Spacer()
                                Text(note.date, format: .dateTime.day().month())
                                    .font(AppFont.caption(11))
                                    .foregroundStyle(AppColor.navyText.opacity(0.5))
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(note.body.isEmpty ? NSLocalizedString("notes.empty.body", comment: "") : note.body)
                                    .font(AppFont.body(14))
                                    .foregroundStyle(AppColor.navyText)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(4)
                                if note.body.count > 120 {
                                    Text("notes.preview.read_more")
                                        .font(AppFont.caption(11))
                                        .foregroundStyle(note.category.accentColor)
                                }
                            }
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.white)
                                .shadow(color: AppColor.navyText.opacity(0.05), radius: 6, x: 0, y: 3)
                        )
                    }
                    .buttonStyle(BouncyPressStyle())
                    .swipeActions {
                        Button(role: .destructive) {
                            coop.removeNote(note.id)
                        } label: { Label("common.delete", systemImage: "trash") }
                    }
                }
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 8)
        }
    }

    private var empty: some View {
        EmptyHint(
            titleKey: "notes.empty.title",
            subtitleKey: "notes.empty.sub",
            actionTitleKey: "notes.add"
        ) { sheet = .create }
    }

    private func editorSeed(_ mode: NoteSheetMode) -> ChickenNote {
        switch mode {
        case .create: return ChickenNote()
        case .edit(let id): return coop.notes.first(where: { $0.id == id }) ?? ChickenNote()
        }
    }
}

enum NoteSheetMode: Identifiable {
    case create
    case edit(UUID)
    var id: String {
        switch self {
        case .create: return "create"
        case .edit(let id): return id.uuidString
        }
    }
}

private struct NoteEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State private var value: ChickenNote
    @State private var isNew: Bool
    let onSave: (ChickenNote, Bool) -> Void

    init(initial: ChickenNote, onSave: @escaping (ChickenNote, Bool) -> Void) {
        _value = State(initialValue: initial)
        _isNew = State(initialValue: initial.body.isEmpty)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("notes.editor.category") {
                    Picker("notes.editor.category", selection: $value.category) {
                        ForEach(NoteCategory.allCases) { cat in
                            Text(LocalizedStringKey(cat.titleKey)).tag(cat)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section("notes.editor.body") {
                    TextEditor(text: $value.body)
                        .frame(minHeight: 140)
                        .font(AppFont.body(15))
                }
                Section {
                    Text("\(value.body.count)/500")
                        .font(AppFont.caption(11))
                        .foregroundStyle(AppColor.navyText.opacity(0.55))
                }
            }
            .navigationTitle(isNew ? "notes.editor.new" : "notes.editor.edit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("common.cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("common.save") {
                        var trimmed = value
                        if trimmed.body.count > 500 { trimmed.body = String(trimmed.body.prefix(500)) }
                        onSave(trimmed, isNew)
                        dismiss()
                    }
                }
            }
        }
    }
}
