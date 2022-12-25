//
//  ViewController.swift
//  Words
//
//  Created by n on 29.07.2022.
//

import UIKit

class ViewController: UITableViewController {
   
    var allWords = [String]()
    var usedWords = [String]()
    
    var words = [Words]()
//MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(restartGame))
        let defaults = UserDefaults.standard
        if let savedWords = defaults.object(forKey: "savedWords") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                words = try jsonDecoder.decode([Words].self, from: savedWords)
            } catch {
                print("Failed to upload previous words.")
            }
        }
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        startGame()
    }

//MARK: - startGame
    func startGame() {
        if words.isEmpty {
            title = allWords.randomElement()
            let wordList = Words(currentWord: title!, entries: [String]())
            words.append(wordList)
            usedWords.append(title!)
            save()
            tableView.reloadData()
        } else {
            title = allWords.randomElement()
            usedWords = words[0].entries
            usedWords.append(title!)
            save()
        }

    }
//MARK: - restartGame
    @objc func restartGame() {
        title = allWords.randomElement()
        save()
        let wordList = Words(currentWord: title!, entries: [String]())
        usedWords.append(title!)
        words.append(wordList)
        tableView.reloadData()
    }
//MARK: - numberOfRows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
//MARK: - cellForRowAt
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
//MARK: - promptForAnswer
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
//MARK: - submit
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()

        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    usedWords.insert(lowerAnswer, at: 0)
                    words[0].entries = usedWords
                    save()
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    return
                } else {
                    showErrorMessage(errorMessage: "You can't just make them up, u know!", errorTitle: "Word not recognised")
                }
            } else {
                showErrorMessage(errorMessage: "Be more original!", errorTitle: "Word used already")
            }
        } else {
            guard let title = title?.lowercased() else {  return }
            showErrorMessage(errorMessage: "You can't spell that word from \(title)", errorTitle: "Word not possible")
        }
    }
//MARK: - isPossible
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        return true
    }
//MARK: - isOriginal
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
//MARK: - isReal
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        if word == title {
            return false
        } else if word.count < 3 {
            return false
        }
        
        return misspelledRange.location == NSNotFound 
    }
//MARK: - showErrorMessage
    func showErrorMessage(errorMessage: String, errorTitle: String) {
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
//MARK: - save
    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(words) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "savedWords")
        } else {
            print("Failed to save words.")
        }
    }
}

