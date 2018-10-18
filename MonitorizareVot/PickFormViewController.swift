//  Created by Code4Romania

import Foundation
import UIKit

class PickFormViewController: RootViewController {
    
    // MARK: - iVars
    var sectionInfo: MVSectionInfo?
    var persistedSectionInfo: SectionInfo?
    private var localFormProvider = LocalFormProvider()
    private let dbSyncer = DBSyncer()
    @IBOutlet weak var TopLabel: UILabel!
    @IBOutlet weak var TopLabelNumber: UILabel!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        TopLabel.text = sectionInfo?.judet
        TopLabelNumber.text = sectionInfo?.sectie
        navigationItem.title = "Obserwacja"
        
        let count = dbSyncer.getUnsyncItemsCount()
        print("getUnsyncItemsCount")
        print(count)
    }

    // MARK: - IBActions
    @IBAction func selectFormA(_ sender: UITapGestureRecognizer) {
        pushFormViewController(type: "A")
    }
    
    @IBAction func selectFormB(_ sender: UITapGestureRecognizer) {
        pushFormViewController(type: "B")
    }

    @IBAction func selectFormC1(_ sender: UITapGestureRecognizer) {
        pushFormViewController(type: "C1")
    }
    
    @IBAction func selectFormC2(_ sender: UITapGestureRecognizer) {
        pushFormViewController(type: "C2")
    }
    
    @IBAction func selectFormCg(_ sender: UITapGestureRecognizer) {
        pushFormViewController(type: "Cg")
    }
    
    @IBAction func selectFormCp(_ sender: UITapGestureRecognizer) {
        pushFormViewController(type: "Cp")
    }

    @IBAction func selectFormCs(_ sender: UITapGestureRecognizer) {
        pushFormViewController(type: "Cs")
    }
    
    @IBAction func selectFormCw(_ sender: UITapGestureRecognizer) {
        pushFormViewController(type: "Cw")
    }
    
    @IBAction func selectFormD(_ sender: UITapGestureRecognizer) {
        pushFormViewController(type: "D")
    }
    
    @IBAction func selectNota(_ sender: UITapGestureRecognizer) {
        let addNoteViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddNoteViewController") as! AddNoteViewController
        addNoteViewController.sectionInfo = sectionInfo
        addNoteViewController.noteContainer = persistedSectionInfo
        self.navigationController?.pushViewController(addNoteViewController, animated: true)
    }
    
    @IBAction func changeStation(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func syncData(_ button: UIButton) {
        dbSyncer.syncUnsyncedData()
    }
    
    private func pushFormViewController(type: String) {
        let formViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FormViewController") as! FormViewController
        print("pushFormViewController")
        print(type)
        if let form = localFormProvider.getForm(named: type) {
            print("passed");
            var questions = [MVQuestion]()
            for aSection in form.sections {
                if let persistedQuestions = persistedSectionInfo?.questions as? Set<Question> {
                    let persistedQuestionsArray = Array(persistedQuestions)
                    for questionToAdd in aSection.questions {
                        let indexOfPersistedQuestionInSection = persistedQuestionsArray.index { (persistedQuestion: Question) -> Bool in
                            return persistedQuestion.id == questionToAdd.id
                        }
                        if let indexOfPersistedQuestionInSection = indexOfPersistedQuestionInSection {
                            let dbSyncer = DBSyncer()
                            let persistedQuestion = persistedQuestionsArray[indexOfPersistedQuestionInSection]
                            let parsedQuestions = dbSyncer.parseQuestions(questionsToParse: [persistedQuestion])
                            questions.append(parsedQuestions.first!)
                        }
                        else {
                            questions.append(questionToAdd)
                        }
                    }
                }
                else {
                    questions.append(contentsOf: aSection.questions)
                }
            }
            formViewController.questions = questions
            formViewController.form = type
            formViewController.sectionInfo = sectionInfo
            formViewController.persistedSectionInfo = persistedSectionInfo
            self.navigationController?.pushViewController(formViewController, animated: true)
        }
    }
}
