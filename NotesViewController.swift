import UIKit
import CoreData

class NotesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, AddEditNoteDelegate {

    var tableView = UITableView(frame: .zero, style: .insetGrouped)
    var searchBar = UISearchBar()
    var notes: [Note] = []
    var filteredNotes: [Note] = []
    var sections: [String: [Note]] = [:]

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchNotes()
    }

    func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        navigationItem.title = "Notes"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.backgroundColor = .systemBackground

        // Настройка SearchBar
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        searchBar.backgroundColor = .systemBackground
        view.addSubview(searchBar)

        // Настройка TableView
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NoteTableViewCell.self, forCellReuseIdentifier: "NoteCell")
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        view.addSubview(tableView)

        // Констрейны
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 50),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Кнопка "Добавить"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNote))
    }

    @objc func addNote() {
        let addEditVC = AddEditNoteViewController()
        addEditVC.delegate = self
        navigationController?.pushViewController(addEditVC, animated: true)
    }

    func fetchNotes() {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        do {
            notes = try context.fetch(request)
            filteredNotes = notes
            groupNotesByDate()
            tableView.reloadData()
        } catch {
            print("Error fetching notes: \(error)")
        }
    }

    func groupNotesByDate() {
        sections = Dictionary(grouping: filteredNotes) { note in
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: note.date ?? Date())
        }
    }

    func didUpdateNotes() {
        fetchNotes()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.keys.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dateKey = Array(sections.keys.sorted())[section]
        return sections[dateKey]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(sections.keys.sorted())[section]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as! NoteTableViewCell
        let dateKey = Array(sections.keys.sorted())[indexPath.section]
        if let notesForDate = sections[dateKey] {
            let note = notesForDate[indexPath.row]
            cell.configure(with: note)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dateKey = Array(sections.keys.sorted())[indexPath.section]
        if let notesForDate = sections[dateKey] {
            let note = notesForDate[indexPath.row]
            let addEditVC = AddEditNoteViewController()
            addEditVC.note = note
            addEditVC.delegate = self
            navigationController?.pushViewController(addEditVC, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let dateKey = Array(sections.keys.sorted())[indexPath.section]
            if let notesForDate = sections[dateKey] {
                let noteToDelete = notesForDate[indexPath.row]
                context.delete(noteToDelete)
                do {
                    try context.save()
                    fetchNotes()
                } catch {
                    print("Error deleting note: \(error)")
                }
            }
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredNotes = notes
        } else {
            filteredNotes = notes.filter {
                ($0.title?.lowercased().contains(searchText.lowercased()) ?? false) ||
                ($0.content?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }
        groupNotesByDate()
        tableView.reloadData()
    }
}

