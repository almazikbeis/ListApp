import UIKit
import CoreData

protocol AddEditNoteDelegate {
    func didUpdateNotes()
}

class AddEditNoteViewController: UIViewController {

    var titleTextField = UITextField()
    var contentTextView = UITextView()
    var note: Note?
    var delegate: AddEditNoteDelegate?

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if let note = note {
            titleTextField.text = note.title
            contentTextView.text = note.content
        }
    }

    func setupUI() {
        view.backgroundColor = .systemBackground

        titleTextField.placeholder = "Title"
        titleTextField.borderStyle = .roundedRect
        view.addSubview(titleTextField)

        contentTextView.layer.borderWidth = 1
        contentTextView.layer.borderColor = UIColor.gray.cgColor
        contentTextView.layer.cornerRadius = 5
        view.addSubview(contentTextView)

        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        contentTextView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleTextField.heightAnchor.constraint(equalToConstant: 40),

            contentTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            contentTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveNote))
    }

    @objc func saveNote() {
        if let note = note {
            note.title = titleTextField.text
            note.content = contentTextView.text
            note.date = Date()
        } else {
            let newNote = Note(context: context)
            newNote.title = titleTextField.text
            newNote.content = contentTextView.text
            newNote.date = Date()
        }

        do {
            try context.save()
            delegate?.didUpdateNotes()
            navigationController?.popViewController(animated: true)
        } catch {
            print("Error saving note: \(error)")
        }
    }
}

