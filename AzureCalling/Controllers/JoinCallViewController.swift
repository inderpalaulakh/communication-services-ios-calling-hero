//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

class JoinCallViewController: UIViewController, UITextFieldDelegate {

    // MARK: Constants

    private let groupIdPlaceHolder: String = "ex. 4fe34380-81e5-11eb-a16e-6161a3176f61"
    private let teamsLinkPlaceHolder: String = "ex. https://teams.microsoft.com/..."

    // MARK: Properties

    var callingContext: CallingContext!

    private var joinCallType: JoinCallType = .groupCall

    // MARK: IBOutlets

    @IBOutlet weak var joinCallButton: UIRoundedButton!
    @IBOutlet weak var joinIdTextField: UITextField!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var groupIdButton: UIButton!
    @IBOutlet weak var meetingLinkButton: UIButton!

    // MARK: UIViewController events

    override func viewDidLoad() {
        super.viewDidLoad()

        joinIdTextField.delegate = self
        joinIdTextField.attributedPlaceholder = NSAttributedString(string: groupIdPlaceHolder,
                                                                   attributes: [.foregroundColor: UIColor.systemGray])
        updateJoinCallButton(forInput: nil)

        // Dismiss keyboard if tapping outside
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }

    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        updateJoinCallButton(forInput: updatedString)
        return true
    }

    // MARK: Private Functions

    private func updateJoinCallButton(forInput string: String?) {
        let isEmpty = string?.isEmpty ?? true
        joinCallButton.isEnabled = !isEmpty
    }

    // MARK: Navigation

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let joinId = joinIdTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        switch joinCallType {
        case .groupCall:
            guard UUID(uuidString: joinId) != nil else {
                promptInvalidJoinIdInput()
                return false
            }
        case .teamsMeeting:
            guard URL(string: joinId) != nil else {
                promptInvalidJoinIdInput()
                return false
            }
        }
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch segue.identifier {
        case "JoinCallToLobby":
            prepareSetupCall(destination: segue.destination)
        default:
            fatalError("Unexpected Segue Identifier: \(segue.identifier ?? "")")
        }
    }

    private func prepareSetupCall(destination: UIViewController) {
        guard let lobbyViewController = destination as? LobbyViewController else {
            fatalError("Unexpected destination: \(destination)")
        }

        lobbyViewController.callingContext = callingContext
        lobbyViewController.joinInput = joinIdTextField.text!
        lobbyViewController.joinCallType = joinCallType
    }

    private func promptInvalidJoinIdInput() {
        var alertMessgae = ""
        switch joinCallType {
        case .groupCall:
            alertMessgae = "The meeting ID entered is invalid. Please try again."
        case .teamsMeeting:
            alertMessgae = "The meeting link entered is invalid. Please try again."
        }
        let alert = UIAlertController(title: "Unable to join", message: alertMessgae, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: Actions

    @IBAction func selectedGroupCall(_ sender: Any) {
        joinIdTextField.removeFromSuperview()
        contentStackView.insertArrangedSubview(joinIdTextField, at: 1)
        joinIdTextField.placeholder = groupIdPlaceHolder
        joinCallType = .groupCall
        groupIdButton.isSelected = true
        meetingLinkButton.isSelected = false
    }

    @IBAction func selectedTeamsMeeting(_ sender: Any) {
        joinIdTextField.removeFromSuperview()
        contentStackView.insertArrangedSubview(joinIdTextField, at: 2)
        joinIdTextField.placeholder = teamsLinkPlaceHolder
        joinCallType = .teamsMeeting
        groupIdButton.isSelected = false
        meetingLinkButton.isSelected = true
    }
}
